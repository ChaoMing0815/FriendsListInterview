//
//  InvitationCardView.swift
//  FriendsListInterview
//
//  Created by 黃昭銘 on 2025/12/30.
//

import Foundation
import UIKit

final class InvitationCardView: UIView {
    // MARK: - Callback
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
        button.setImage(UIImage(named: "btnFriendsAgree"), for: .normal)
        button.tintColor = .systemPink
        button.layer.cornerRadius = 15
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let declineButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "btnFriendsDelet"), for: .normal)
        button.tintColor = .systemGray3
        button.layer.cornerRadius = 15
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let shadowContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = false
        return view
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        clipsToBounds = false
        setupLayout()
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout Subviews
    override func layoutSubviews() {
        super.layoutSubviews()
        shadowContainer.layoutIfNeeded()

        shadowContainer.layer.shadowColor = UIColor.black.cgColor
        shadowContainer.layer.shadowOpacity = 0.12
        shadowContainer.layer.shadowOffset = CGSize(width: 0, height: 4)
        shadowContainer.layer.shadowRadius = 10
        shadowContainer.layer.shadowPath = UIBezierPath(
            roundedRect: shadowContainer.bounds,
            cornerRadius: 12
        ).cgPath
    }

    // MARK: - Configure
    func configure(name: String, avatar: UIImage? = nil) {
        nameLabel.text = name
        avatarView.image = avatar ?? UIImage(systemName: "person.crop.circle.fill")
    }

    // MARK: - Reset
    func reset() {
        avatarView.image = nil
        nameLabel.text = nil
        subtitleLabel.text = "邀請你成為好友 ：）"
        onAcceptTapped = nil
        onDeclineTapped = nil
    }
}

// MARK: - Helpers
private extension InvitationCardView {

    func setupLayout() {
        let buttonStack = makeStackView(
            axis: .horizontal,
            spacing: 15,
            alignment: .center,
            arrangedSubviews: [acceptButton, declineButton]
        )

        let textStack = makeStackView(
            axis: .vertical,
            spacing: 2,
            alignment: .leading,
            arrangedSubviews: [nameLabel, subtitleLabel]
        )

        let rootStack = makeStackView(
            axis: .horizontal,
            spacing: 15,
            alignment: .center,
            arrangedSubviews: [avatarView, textStack, spacer(), buttonStack]
        )

        addSubview(shadowContainer)
        shadowContainer.addSubview(cardView)
        cardView.addSubview(rootStack)

        NSLayoutConstraint.activate([
            // 卡片本體固定高度 70（你 Zeplin 的規格）
            shadowContainer.topAnchor.constraint(equalTo: topAnchor),
            shadowContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            shadowContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            shadowContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            shadowContainer.heightAnchor.constraint(equalToConstant: 70),

            cardView.topAnchor.constraint(equalTo: shadowContainer.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: shadowContainer.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: shadowContainer.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: shadowContainer.bottomAnchor),

            rootStack.topAnchor.constraint(equalTo: cardView.topAnchor),
            rootStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 15),
            rootStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -15),
            rootStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),

            avatarView.widthAnchor.constraint(equalToConstant: 40),
            avatarView.heightAnchor.constraint(equalToConstant: 40),

            acceptButton.widthAnchor.constraint(equalToConstant: 30),
            acceptButton.heightAnchor.constraint(equalToConstant: 30),
            declineButton.widthAnchor.constraint(equalToConstant: 30),
            declineButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    func setupActions() {
        acceptButton.addTarget(self, action: #selector(didTapAccept), for: .touchUpInside)
        declineButton.addTarget(self, action: #selector(didTapDecline), for: .touchUpInside)
    }

    @objc func didTapAccept() { onAcceptTapped?() }
    @objc func didTapDecline() { onDeclineTapped?() }

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
