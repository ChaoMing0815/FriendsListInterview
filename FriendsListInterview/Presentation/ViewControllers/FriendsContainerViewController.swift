//
//  FriendsContainerViewController.swift
//  FriendsListInterview
//
//  Created by 黃昭銘 on 2025/12/29.
//

import Foundation
import UIKit

@MainActor
final class FriendsContainerViewController: UIViewController {
    
    private let headerView = FriendsHeaderView()
    private let containerView = UIView()
    private let contentViewController: UIViewController
    
    init(contentViewController: UIViewController) {
        self.contentViewController = contentViewController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        embed(contentViewController, in: containerView)
    }
}

// MARK: - Helpers
private extension FriendsContainerViewController {
    func setupLayout() {
        view.addSubview(headerView)
        view.addSubview(containerView)
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 160),
            
            containerView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func embed(_ viewController: UIViewController, in container: UIView) {
        addChild(viewController)
        container.addSubview(viewController.view)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            viewController.view.topAnchor.constraint(equalTo: container.topAnchor),
            viewController.view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        viewController.didMove(toParent: self)
    }
}

