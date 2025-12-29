//
//  EmptyStateView.swift
//  FriendsListInterview
//
//  Created by 黃昭銘 on 2025/12/29.
//

import Foundation
import UIKit

final class EmptyStateView: UIView {
    // MARK: - UI
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "person.fill")
        imageView.tintColor = .systemGray3
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "就從加好友開始吧 ：）"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "與好友們一起用 KOKO 聊起來！\n還能互相收付款、發紅包喔 :)"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let addFriendButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "加好友"
        config.cornerStyle = .capsule
        config.baseBackgroundColor = .systemGreen
        config.baseForegroundColor = .white
        config.image = UIImage(systemName: "person.badge.plus")
        config.imagePadding = 8
        config.imagePlacement = .trailing
        let button = UIButton(configuration: config)
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return button
    }()
    
    private let hintLabel: UILabel = {
        let label = UILabel()
        label.text = "幫助好友更快找到你？設定 KOKO ID"
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Callbacks
    var onAddFriendTapped: (() -> Void)?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        addFriendButton.addTarget(self, action: #selector(addFriendButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup Layout
private extension EmptyStateView {
    func setupLayout() {
        let contentStack = UIStackView(arrangedSubviews: [
            imageView,
            titleLabel,
            subtitleLabel,
            addFriendButton,
            hintLabel
        ])
        contentStack.axis = .vertical
        contentStack.alignment = .center
        contentStack.spacing = 12
        
        addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 160),
            imageView.widthAnchor.constraint(equalToConstant: 240),
            
            contentStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            contentStack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 24),
            contentStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -24),
            
            addFriendButton.widthAnchor.constraint(equalToConstant: 220)
        ])
    }
}

// MARK: - Button Functions
private extension EmptyStateView {
    @objc func addFriendButtonTapped() {
        onAddFriendTapped?()
    }
}
