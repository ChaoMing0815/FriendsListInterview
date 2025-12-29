//
//  InvitationCell.swift
//  FriendsListInterview
//
//  Created by 黃昭銘 on 2025/12/29.
//

import Foundation
import UIKit

final class InvitationCell: UITableViewCell {
    
    static let reuseIdentifier: String = "InvitationCell"
    
    var onAcceptTapped: (() -> Void)?
    var onDeclineTapped: (() -> Void)?
    
    // MARK: - UI
    private let avatarView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        label.text = "邀請你成為好友 ：）"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    private let acceptButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "checkmark"), for: .normal)
        button.tintColor = .systemPink
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemPink.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let declineButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .systemGray3
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray3.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let cardView: UIView = {
       let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.clipsToBounds = false
        clipsToBounds = false
        selectionStyle = .none
        setupLayout()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarView.image = nil
        nameLabel.text = nil
        onAcceptTapped = nil
        onDeclineTapped = nil
    }
    
    // MARK: - Configure
    func configure(name: String, avatar: UIImage? = nil) {
        nameLabel.text = name
        avatarView.image = avatar ?? UIImage(systemName: "person.crop.circle.fill")
    }
}

// MARK: - Helpers
private extension InvitationCell {
    // MARK: - Setup Layout
    func setupLayout() {
        let buttonStack = makeStackView(
            axis: .horizontal,
            spacing: 8,
            alignment: .center,
            arrangedSubviews: [acceptButton, declineButton])
        
        let textStack = makeStackView(
            axis: .vertical,
            spacing: 4,
            alignment: .leading,
            arrangedSubviews: [nameLabel, subtitleLabel])
        
        let rootStack = makeStackView(
            axis: .horizontal,
            spacing: 12,
            alignment: .center,
            arrangedSubviews: [avatarView, textStack, spacer(), buttonStack])
        
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        
        contentView.addSubview(cardView)
        cardView.addSubview(rootStack)
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            rootStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            rootStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            rootStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            rootStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            
            avatarView.widthAnchor.constraint(equalToConstant: 40),
            avatarView.heightAnchor.constraint(equalToConstant: 40),
            
            acceptButton.widthAnchor.constraint(equalToConstant: 40),
            acceptButton.heightAnchor.constraint(equalToConstant: 40),
            declineButton.widthAnchor.constraint(equalToConstant: 40),
            declineButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    // MARK: - Set Button Actions
    func setupActions() {
        acceptButton.addTarget(self, action: #selector(didTapAccept), for: .touchUpInside)
        declineButton.addTarget(self, action: #selector(didTapDecline), for: .touchUpInside)
    }
    
    @objc private func didTapAccept() { onAcceptTapped?() }
    @objc private func didTapDecline() { onDeclineTapped?() }
    
    func makeStackView(
        axis: NSLayoutConstraint.Axis,
        spacing: CGFloat = 0,
        alignment: UIStackView.Alignment = .fill,
        arrangedSubviews: [UIView]
    ) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.axis = axis
        stackView.spacing = spacing
        stackView.alignment = alignment
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }

    func spacer() -> UIView {
        let view = UIView()
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return view
    }
}
