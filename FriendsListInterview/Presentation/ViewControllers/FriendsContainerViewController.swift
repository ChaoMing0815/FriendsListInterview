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
    private let bottomTabBarView = BottomTabBarView()
    
    private var headerHeightConstraint: NSLayoutConstraint!
    private var defaultHeaderHeight: CGFloat = 0
    private var bottomTabBarHeightConstraint: NSLayoutConstraint!
    
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 計算 Header 高度
        guard defaultHeaderHeight == 0 else { return }

           let targetSize = CGSize(
               width: view.bounds.width,
               height: UIView.layoutFittingCompressedSize.height
           )

           let height = headerView.systemLayoutSizeFitting(
               targetSize,
               withHorizontalFittingPriority: .required,
               verticalFittingPriority: .fittingSizeLevel
           ).height

           defaultHeaderHeight = height
           headerHeightConstraint.constant = height
    }
    
    // MARK: - Public APIs
    func setHeaderCollapsed(_ collapsed: Bool, animated: Bool) {
        if !collapsed, defaultHeaderHeight == 0 {
                // fallback：至少回到目前 header 的「已知高度」
                defaultHeaderHeight = headerView.systemLayoutSizeFitting(
                    CGSize(width: view.bounds.width, height: UIView.layoutFittingCompressedSize.height),
                    withHorizontalFittingPriority: .required,
                    verticalFittingPriority: .fittingSizeLevel
                ).height
            }

        headerHeightConstraint.constant = collapsed ? 0 : defaultHeaderHeight
        
        let apply = { self.view.layoutIfNeeded() }
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut], animations: apply)
        } else {
            apply()
        }
    }
}

// MARK: - Helpers
private extension FriendsContainerViewController {
    func setupLayout() {
        view.addSubview(headerView)
        view.addSubview(containerView)
        view.addSubview(bottomTabBarView)
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        bottomTabBarView.translatesAutoresizingMaskIntoConstraints = false
        
        headerHeightConstraint = headerView.heightAnchor.constraint(equalToConstant: 160)
        headerHeightConstraint.isActive = true
        
        bottomTabBarHeightConstraint = bottomTabBarView.heightAnchor.constraint(equalToConstant: 83) // 依 Zeplin（常見 83 含 safe area）
        bottomTabBarHeightConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            bottomTabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomTabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomTabBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            containerView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomTabBarView.topAnchor)
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

