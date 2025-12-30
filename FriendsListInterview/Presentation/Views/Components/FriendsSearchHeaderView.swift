//
//  FriendsSearchHeaderView.swift
//  FriendsListInterview
//
//  Created by 黃昭銘 on 2025/12/30.
//

import Foundation
import UIKit

final class FriendsSearchHeaderView: UIView {
    // MARK: - UI Components
    private let searchBackgroundView = UIView()
    private let searchIconImageView = UIImageView()
    private let textField = UITextField()

    private let addFriendButton = UIButton(type: .custom)

    // MARK: - Callback
    var onTextChanged: ((String) -> Void)?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public
    func setText(_ text: String) {
        textField.text = text
    }
}

// MARK: - Setup
private extension FriendsSearchHeaderView {
    func setupViews() {
        backgroundColor = .clear

        configureSearchBackgroundView()
        configureSearchIconImageView()
        configureTextField()
        configureAddFriendButton()

        addSubview(searchBackgroundView)
        addSubview(addFriendButton)

        searchBackgroundView.addSubview(searchIconImageView)
        searchBackgroundView.addSubview(textField)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            // Whole header height：由外部 tableHeaderView frame 決定（建議 56 or 60）
            // 這裡不鎖死高度，避免之後微調時要改兩邊。

            // Add friend button
            addFriendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            addFriendButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            addFriendButton.widthAnchor.constraint(equalToConstant: 24),
            addFriendButton.heightAnchor.constraint(equalToConstant: 24),

            // Search background (search bar)
            searchBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            searchBackgroundView.trailingAnchor.constraint(equalTo: addFriendButton.leadingAnchor, constant: -15),
            searchBackgroundView.centerYAnchor.constraint(equalTo: centerYAnchor),
            searchBackgroundView.heightAnchor.constraint(equalToConstant: 36),

            // Search icon: 14x14, leading 11, centerY
            searchIconImageView.leadingAnchor.constraint(equalTo: searchBackgroundView.leadingAnchor, constant: 11),
            searchIconImageView.centerYAnchor.constraint(equalTo: searchBackgroundView.centerYAnchor),
            searchIconImageView.widthAnchor.constraint(equalToConstant: 14),
            searchIconImageView.heightAnchor.constraint(equalToConstant: 14),

            // TextField start: 8pt from icon
            textField.leadingAnchor.constraint(equalTo: searchIconImageView.trailingAnchor, constant: 8),
            textField.trailingAnchor.constraint(equalTo: searchBackgroundView.trailingAnchor, constant: -12),
            textField.centerYAnchor.constraint(equalTo: searchBackgroundView.centerYAnchor),
            textField.heightAnchor.constraint(equalToConstant: 22)
        ])
    }

    func setupActions() {
        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }

    @objc func textDidChange() {
        onTextChanged?(textField.text ?? "")
    }
}

// MARK: - Private Helpers
private extension FriendsSearchHeaderView {
    func configureSearchBackgroundView() {
        searchBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        searchBackgroundView.backgroundColor = UIColor(white: 0.92, alpha: 1)
        searchBackgroundView.layer.cornerRadius = 18
        searchBackgroundView.clipsToBounds = true
    }

    func configureSearchIconImageView() {
        searchIconImageView.translatesAutoresizingMaskIntoConstraints = false
        searchIconImageView.image = UIImage(named: "icSearchBarSearchGray")
        searchIconImageView.contentMode = .scaleAspectFit
    }

    func configureTextField() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .none
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .search
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no

        let placeholder = "想轉一筆給誰呢？"
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .regular),
            .foregroundColor: UIColor.secondaryLabel
        ]
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attrs)

        textField.font = .systemFont(ofSize: 14, weight: .regular)
        textField.textColor = .label
    }

    func configureAddFriendButton() {
        addFriendButton.translatesAutoresizingMaskIntoConstraints = false
        addFriendButton.setImage(UIImage(named: "icBtnAddFriends"), for: .normal)
        addFriendButton.imageView?.contentMode = .scaleAspectFit

        // 目前先不做互動（但維持 button 語意）
        addFriendButton.isUserInteractionEnabled = false
    }
}
