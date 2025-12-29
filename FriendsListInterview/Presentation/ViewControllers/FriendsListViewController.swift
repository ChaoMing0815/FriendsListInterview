//
//  FriendsListViewController.swift
//  FriendsListInterview
//
//  Created by 黃昭銘 on 2025/12/29.
//

import Foundation
import UIKit

@MainActor
final class FriendsListViewController: UIViewController {
    
    private let viewModel: FriendsListViewModel
    
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    
    // 無好友情境 UI
    private let emptyView = EmptyStateView()
    
    // 有好友情境 UI
    private let tableView = UITableView(frame: .zero, style: .plain)
    private var receivedInvitations: [Friend] = []
    private var friends: [Friend] = []
    private var hasInvitations: Bool { !receivedInvitations.isEmpty }
    
    init(viewModel: FriendsListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupEmptyView()
        setupTableView()
        setupLoadingIndicator()
        bindViewModel()
        
        Task { await viewModel.loadFriends() }
    }
}

// MARK: - Helpers
private extension FriendsListViewController {
    // MARK: - View For Empty State
    func setupEmptyView() {
        view.addSubview(emptyView)
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        /// 初始狀態不顯示
        emptyView.isHidden = true
        
        emptyView.onAddFriendTapped = { [weak self] in
            // TODO: - 加好友功能
            self?.presentPlaceholderAlert()
        }
    }
    
    // MARK: - TableView For State With Friends
    func setupTableView() {
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
        
        tableView.backgroundColor = .systemGroupedBackground
        tableView.clipsToBounds = false
        
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        tableView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        tableView.sectionHeaderTopPadding = 0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 76
        
        // DataSource And Delegate
        tableView.dataSource = self
        tableView.delegate = self
        
        // Cell Registration
        tableView.register(InvitationCell.self, forCellReuseIdentifier: InvitationCell.reuseIdentifier)
        tableView.register(FriendCell.self, forCellReuseIdentifier: FriendCell.reuseIdentifier)
        
        /// 初始狀態不顯示
        tableView.isHidden = true
    }
    
    // MARK: - TableView Section Type
    func sectionType(for section: Int) -> SectionType {
        if hasInvitations { return section == 0 ? .invitations : .friends }
        return .friends
    }
    
    enum SectionType {
        case invitations
        case friends
    }
    
    func setupLoadingIndicator() {
        view.addSubview(loadingIndicator)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func bindViewModel() {
        viewModel.onStateChanged = { [weak self] state in
            self?.apply(state: state)
        }
        apply(state: viewModel.state)
    }
    
    func apply(state: FriendsListState) {
        switch state {
        case .loading:
            loadingIndicator.startAnimating()
            emptyView.isHidden = true
            tableView.isHidden = true
         
        case .empty:
            loadingIndicator.stopAnimating()
            emptyView.isHidden = false
            tableView.isHidden = true
            
        case let .content(receivedInvitations, friends):
            loadingIndicator.stopAnimating()
            emptyView.isHidden = true
            tableView.isHidden = false
            
            self.receivedInvitations = receivedInvitations
            self.friends = friends
            tableView.reloadData()
        }
    }
    
    func presentPlaceholderAlert() {
        let alert = UIAlertController(title: "提示", message: "功能尚未實作", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate and UITableViewDataSource
extension FriendsListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return hasInvitations ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if hasInvitations {
            return section == 0 ?  receivedInvitations.count : friends.count
        } else {
            return friends.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sectionType(for: indexPath.section) {
        case .invitations:
            let cell = tableView.dequeueReusableCell(withIdentifier: InvitationCell.reuseIdentifier, for: indexPath) as! InvitationCell
            let friend = receivedInvitations[indexPath.row]
            cell.configure(name: friend.name)
            cell.onAcceptTapped = { [weak self] in
                self?.presentPlaceholderAlert()
            }
            cell.onDeclineTapped = { [weak self] in
                self?.presentPlaceholderAlert()
            }
            return cell
        case .friends:
            let cell = tableView.dequeueReusableCell(withIdentifier: FriendCell.reuseIdentifier, for: indexPath) as! FriendCell
            let friend = friends[indexPath.row]
            cell.configure(name: friend.name, status: friend.status, isTop: friend.isTop)
            cell.onTransferTapped = { [weak self] in
                self?.presentPlaceholderAlert()
            }
            cell.onMoreTapped = { [weak self] in
                self?.presentPlaceholderAlert()
            }
            return cell
        }
    }
    
    // MARK: - HeaderView For TableView
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch sectionType(for: section) {
        case .invitations:
            return "邀請"
        case .friends:
            return "好友"
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }

}
