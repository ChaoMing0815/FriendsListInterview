//
//  ScenarioSelectorViewController.swift
//  FriendsListInterview
//
//  Created by 黃昭銘 on 2025/12/29.
//

import Foundation
import UIKit

@MainActor
final class ScenarioSelectorViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupButtons()
    }
}

// MARK: - Helpers And Factory Methods
private extension ScenarioSelectorViewController {
    func makeButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return button
    }
    
    func setupButtons() {
        let emptyButton: UIButton = makeButton(title: "情境：無好友")
        let friendsOnlyButton: UIButton = makeButton(title: "情境：有好友但無邀請")
        let friendsWithInvitesButton: UIButton = makeButton(title: "情境：有好友且有邀請")
        
        emptyButton.addTarget(self, action: #selector(emptyTapped), for: .touchUpInside)
        friendsOnlyButton.addTarget(self, action: #selector(friendsOnlyTapped), for: .touchUpInside)
        friendsWithInvitesButton.addTarget(self, action: #selector(friendsWithInvitesTapped), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [emptyButton, friendsOnlyButton, friendsWithInvitesButton])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: - Button Functions
private extension ScenarioSelectorViewController {
    func pushToFriendsListController(with scenario: Scenario) {
        let repository = DefaultFriendsRepository(service: DefaultFriendsAPIService())
        
        let viewModel = FriendsListViewModel(
            scenario: scenario,
            mergeUseCase: MergeFriendsUseCase(),
            searchUseCase: SearchFriendsUseCase(),
            repository: repository
        )
        
        let listViewController = FriendsListViewController(viewModel: viewModel)
        let containerViewController = FriendsContainerViewController(contentViewController: listViewController)
        navigationController?.pushViewController(containerViewController, animated: true)
    }
    
    @objc func emptyTapped() {
        pushToFriendsListController(with: .empty)
    }
    
    @objc func friendsOnlyTapped() {
        pushToFriendsListController(with: .friendsOnly)
    }
    
    @objc func friendsWithInvitesTapped() {
        pushToFriendsListController(with: .friendsWithInvites)
    }
}
