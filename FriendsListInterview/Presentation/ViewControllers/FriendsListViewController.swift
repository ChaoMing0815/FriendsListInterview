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
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private var receivedInvitations: [Friend] = []
    private var friends: [Friend] = []
    
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
    
    func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        /// 初始狀態不顯示
        tableView.isHidden = true
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
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return receivedInvitations.count
        case 1: return friends.count
        default : return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let friend: Friend
        if indexPath.section == 0 {
            friend = receivedInvitations[indexPath.row]
            cell.textLabel?.text = "邀請：\(friend.name)"
        } else {
            friend = friends[indexPath.row]
            cell.textLabel?.text = friend.name
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return receivedInvitations.isEmpty ? nil : "收到的好友邀請"
        }
        return "好友"
    }
}
