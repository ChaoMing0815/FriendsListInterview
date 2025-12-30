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
        imageView.image = UIImage(named: "imgFriendsEmpty")
        imageView.tintColor = .systemGray3
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "就從加好友開始吧 ：）"
        label.font = .systemFont(ofSize: 21, weight: .semibold)
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
        config.baseBackgroundColor = .systemGreen
        config.baseForegroundColor = .white

        config.image = UIImage(named: "icAddFriendWhite")
        config.imagePlacement = .trailing
        config.imagePadding = 8
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 8)

        var title = AttributedString("加好友")
        title.font = .systemFont(ofSize: 14, weight: .semibold)
        config.attributedTitle = title
        let button = UIButton(configuration: config)
        button.heightAnchor.constraint(equalToConstant: 24).isActive = true
        return button
    }()
    
    private let hintLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    // MARK: - Callbacks
    var onAddFriendTapped: (() -> Void)?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        configureAddFriendButton()
        configureHintLabel()
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
        
        // 設定 Zeplin 佈局參數
        contentStack.spacing = 0
        contentStack.setCustomSpacing(41, after: imageView)
        contentStack.setCustomSpacing(8, after: titleLabel)
        contentStack.setCustomSpacing(20, after: subtitleLabel)
        contentStack.setCustomSpacing(37, after: addFriendButton)
        
        addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 172),
            imageView.widthAnchor.constraint(equalToConstant: 245),
            
            contentStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            contentStack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 24),
            contentStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -24)
        ])
        
        addFriendButton.widthAnchor.constraint(equalToConstant: 192).isActive = true
        addFriendButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func configureAddFriendButton() {
        addFriendButton.layer.shadowColor = UIColor.systemGreen.cgColor
        addFriendButton.layer.shadowOpacity = 0.25
        addFriendButton.layer.shadowRadius = 6
        addFriendButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        addFriendButton.layer.masksToBounds = false
    }
    
    func configureHintLabel() {
        let full = "幫助好友更快找到你？設定 KOKO ID"
        let linkText = "設定 KOKO ID"
        let attr = NSMutableAttributedString(string: full)

        let fullRange = NSRange(location: 0, length: (full as NSString).length)
        attr.addAttributes([
            .font: UIFont.systemFont(ofSize: 13),
            .foregroundColor: UIColor.secondaryLabel
        ], range: fullRange)

        let linkRange = (full as NSString).range(of: linkText)
        attr.addAttributes([
            .foregroundColor: UIColor.systemBlue,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ], range: linkRange)

        hintLabel.attributedText = attr
    }
}

// MARK: - Button Functions
private extension EmptyStateView {
    @objc func addFriendButtonTapped() {
        onAddFriendTapped?()
    }
}
