//
//  FriendsSegmentView.swift
//  FriendsListInterview
//
//  Created by 黃昭銘 on 2025/12/30.
//

import Foundation
import UIKit

final class FriendsSegmentView: UIView {
    
    // MARK: - UI Components
    private let friendsLabel = UILabel()
    private let chatLabel = UILabel()
    
    private let stackView = UIStackView()
    private let underlineView = UIView()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup
private extension FriendsSegmentView {
    func setupViews() {
        backgroundColor = .clear
        
        configureFriendsLabel()
        configureChatLabel()
        configureStackView()
        configureUnderlineView()
        
        addSubview(stackView)
        addSubview(underlineView)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            // Section height: 37pt
            heightAnchor.constraint(equalToConstant: 37),
            
            // StackView: leading 30 (延續 header 左邊界風格，可依你 header 規劃再調)
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            // Underline: width 20, height 4, 文字到底線 6
            underlineView.widthAnchor.constraint(equalToConstant: 20),
            underlineView.heightAnchor.constraint(equalToConstant: 4),
            underlineView.centerXAnchor.constraint(equalTo: friendsLabel.centerXAnchor),
            underlineView.topAnchor.constraint(equalTo: friendsLabel.bottomAnchor, constant: 6)
        ])
    }
}

// MARK: - Private Helpers
private extension FriendsSegmentView {
    func configureFriendsLabel() {
        friendsLabel.translatesAutoresizingMaskIntoConstraints = false
        friendsLabel.text = "好友"
        friendsLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        friendsLabel.textColor = .label
        friendsLabel.numberOfLines = 1
        
        NSLayoutConstraint.activate([
            friendsLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
    
    func configureChatLabel() {
        chatLabel.translatesAutoresizingMaskIntoConstraints = false
        chatLabel.text = "聊天"
        chatLabel.font = .systemFont(ofSize: 13, weight: .regular)
        chatLabel.textColor = .secondaryLabel
        chatLabel.numberOfLines = 1
        
        NSLayoutConstraint.activate([
            chatLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
    
    func configureStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 36
        
        stackView.addArrangedSubview(friendsLabel)
        stackView.addArrangedSubview(chatLabel)
    }
    
    func configureUnderlineView() {
        underlineView.translatesAutoresizingMaskIntoConstraints = false
        underlineView.backgroundColor = .systemPink
        underlineView.layer.cornerRadius = 2
        underlineView.clipsToBounds = true
    }
}
