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
    
    private let emptyView = EmptyStateView()
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    
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
        
        emptyView.onAddFriendTapped = { [weak self] in
            // TODO: - 加好友功能
            self?.presentPlaceholderAlert()
        }
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
            
        case .empty:
            loadingIndicator.stopAnimating()
            emptyView.isHidden = false
            
        case .content:
            loadingIndicator.stopAnimating()
            emptyView.isHidden = true
        }
    }
    
    func presentPlaceholderAlert() {
        let alert = UIAlertController(title: "提示", message: "功能尚未實作", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
