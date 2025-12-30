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
    
    // MARK: - UI Components
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    private let contentStackView = UIStackView()
    private let invitationsContainerView = UIView()
    private let invitationCollectionView = InvitationCollectionView()
    private let segmentContainerView = UIView()
    private let segmentView = FriendsSegmentView()
    
    private var invitationsHeightConstraint: NSLayoutConstraint?
    private var segmentHeightConstraint: NSLayoutConstraint?
    
    private var lastInvitationsHeight: CGFloat = 0
    private let defaultSegmentHeight: CGFloat = 37
    
    // FriendsList Related
    // 無好友情境 UI
    private let emptyView = EmptyStateView()
    
    // 有好友情境 UI
    private let tableView = UITableView(frame: .zero, style: .plain)
    private var receivedInvitations: [Friend] = []
    private var hasInvitations: Bool { !receivedInvitations.isEmpty }
    
    // 搜尋功能
    private let searchHeaderView = FriendsSearchHeaderView()
    private var allFriends: [Friend] = []
    private var filteredFriends: [Friend] = []
    private var searchKeyword: String = ""
    
    init(viewModel: FriendsListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupEmptyView()
        setupTableView()
        setupContentStackView()
        setupLoadingIndicator()
        setupDismissKeyboardGesture()
        bindViewModel()
        
        Task { await viewModel.loadFriends() }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeaderLayout()
    }
}

// MARK: - Helpers
private extension FriendsListViewController {
    // MARK: - Setup StackView
    func setupContentStackView() {
        view.addSubview(contentStackView)

        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        contentStackView.axis = .vertical
        contentStackView.alignment = .fill
        contentStackView.distribution = .fill
        contentStackView.spacing = 0

        configureInvitationsCollectionView()
        configureSegmentPlaceholder()

        contentStackView.addArrangedSubview(invitationsContainerView)
        contentStackView.addArrangedSubview(segmentContainerView)
        contentStackView.addArrangedSubview(tableView)
        
        contentStackView.isHidden = true
    }
    
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
    
    // MARK: - Setup TableView
    func setupTableView() {
        tableView.backgroundColor = .white
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
        tableView.register(FriendCell.self, forCellReuseIdentifier: FriendCell.reuseIdentifier)
        
        // Add SearchTextField
        tableView.tableHeaderView = searchHeaderView
        tableView.keyboardDismissMode = .onDrag
        updateTableHeaderLayout()
        searchHeaderView.onTextChanged = { [weak self] text in
            self?.searchKeyword = text
            self?.applySearchFilter()
        }
        
        // 點擊搜尋上移及復原
        searchHeaderView.onBeginEditing = { [weak self] in
            self?.setSearchPinned(true, animated: true)
        }
        searchHeaderView.onEndEditing = { [weak self] in
            self?.setSearchPinned(false, animated: true)
        }
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
    
    // MARK: - ViewModel Binding
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
            contentStackView.isHidden = true
            emptyView.isHidden = true
         
        case .empty:
            loadingIndicator.stopAnimating()
            contentStackView.isHidden = true
            emptyView.isHidden = false
            
        case let .content(receivedInvitations, friends):
            loadingIndicator.stopAnimating()
            contentStackView.isHidden = false
            emptyView.isHidden = true

            self.allFriends = friends
            applySearchFilter()
            
            self.receivedInvitations = receivedInvitations
            invitationCollectionView.update(invitations: receivedInvitations)
            
            if receivedInvitations.isEmpty {
                invitationsHeightConstraint?.constant = 0
            } else {
                invitationCollectionView.setDisplayMode(.expanded, animated: false)
            }
        }
    }
    
    func presentPlaceholderAlert() {
        let alert = UIAlertController(title: "提示", message: "功能尚未實作", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func updateTableHeaderLayout() {
        let width = view.bounds.width
        searchHeaderView.frame = CGRect(x: 0, y: 0, width: width, height: 56)
        tableView.tableHeaderView = searchHeaderView
    }
    
    // MARK: - Search Related Functions
    func applySearchFilter() {
        let keyword = searchKeyword.trimmingCharacters(in: .whitespacesAndNewlines)

        if keyword.isEmpty {
            filteredFriends = allFriends
        } else {
            filteredFriends = allFriends.filter { friend in
                friend.name.localizedCaseInsensitiveContains(keyword)
            }
        }
        tableView.reloadData()
    }
    
    private func setupDismissKeyboardGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false // 重要：不影響 cell 點擊
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func setSearchPinned(_ pinned: Bool, animated: Bool) {
        let apply = {
            (self.parent as? FriendsContainerViewController)?
                .setHeaderCollapsed(pinned, animated: false)
            
            if pinned {
                self.invitationsHeightConstraint?.constant = 0
                self.segmentHeightConstraint?.constant = 0
                let y = -self.tableView.adjustedContentInset.top
                self.tableView.setContentOffset(CGPoint(x: 0, y: y), animated: false)
            } else {
                self.segmentHeightConstraint?.constant = self.defaultSegmentHeight
                let shouldShowInvites = !self.receivedInvitations.isEmpty
                self.invitationsHeightConstraint?.constant = shouldShowInvites ? self.lastInvitationsHeight : 0
            }
            
            self.view.layoutIfNeeded()
            self.parent?.view.layoutIfNeeded()
        }
        
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut]) { apply() }
        } else {
            apply()
        }
    }

    // MARK: - Setup PlaceHolder
    func configureInvitationsCollectionView() {
        invitationsContainerView.backgroundColor = .clear

        invitationsContainerView.addSubview(invitationCollectionView)
        invitationCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            invitationCollectionView.topAnchor.constraint(equalTo: invitationsContainerView.topAnchor),
            invitationCollectionView.leadingAnchor.constraint(equalTo: invitationsContainerView.leadingAnchor),
            invitationCollectionView.trailingAnchor.constraint(equalTo: invitationsContainerView.trailingAnchor),
            invitationCollectionView.bottomAnchor.constraint(equalTo: invitationsContainerView.bottomAnchor)
        ])

        if invitationsHeightConstraint == nil {
            invitationsHeightConstraint = invitationsContainerView.heightAnchor.constraint(equalToConstant: 0)
            invitationsHeightConstraint?.isActive = true
        }
        
        invitationCollectionView.onPreferredHeightChanged = { [weak self] height, animated in
            guard let self else { return }
            self.lastInvitationsHeight = height
            self.invitationsHeightConstraint?.constant = height
            
            if animated {
                UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.2, options: [.curveEaseInOut]) {
                    self.view.layoutIfNeeded()
                }
            } else {
                self.view.layoutIfNeeded()
            }
        }
        
        invitationCollectionView.onAcceptTapped = { [weak self] _ in
            self?.presentPlaceholderAlert()
        }
        invitationCollectionView.onDeclineTapped = { [weak self] _ in
            self?.presentPlaceholderAlert()
        }
    }

    func configureSegmentPlaceholder() {
        segmentContainerView.backgroundColor = .clear
       
        segmentContainerView.subviews.forEach { $0.removeFromSuperview() }
        
        segmentContainerView.addSubview(segmentView)
        segmentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            segmentView.topAnchor.constraint(equalTo: segmentContainerView.topAnchor),
            segmentView.leadingAnchor.constraint(equalTo: segmentContainerView.leadingAnchor),
            segmentView.trailingAnchor.constraint(equalTo: segmentContainerView.trailingAnchor),
            segmentView.bottomAnchor.constraint(equalTo: segmentContainerView.bottomAnchor)
        ])
        
        if segmentHeightConstraint == nil {
            segmentHeightConstraint = segmentContainerView.heightAnchor.constraint(equalToConstant: 37)
            segmentHeightConstraint?.isActive = true
        }
    }
}

// MARK: - UITableViewDelegate and UITableViewDataSource
extension FriendsListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredFriends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FriendCell.reuseIdentifier, for: indexPath) as! FriendCell
        let friend = filteredFriends[indexPath.row]
        cell.configure(name: friend.name, status: friend.status, isTop: friend.isTop)
        cell.onTransferTapped = { [weak self] in self?.presentPlaceholderAlert() }
        cell.onMoreTapped = { [weak self] in self?.presentPlaceholderAlert() }
        return cell
    }
}
