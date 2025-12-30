//
//  UserInfoView.swift
//  FriendsListInterview
//
//  Created by 黃昭銘 on 2025/12/30.
//

import Foundation
import UIKit

final class UserInfoView: UIView {
    // MARK: - UI Components
    private let nameLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let chevronButton = UIButton(type: .system)
    private let avatarImageView = UIImageView()

    private let textContainerView = UIView()
    private let subtitleRowStackView = UIStackView()
    private let textStackView = UIStackView()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configure
    /// Layout-only view, data is injected by caller (ViewController / HeaderView).
    func configure(name: String, kokoID: String) {
        nameLabel.text = name
        subtitleLabel.text = "KOKO ID : \(kokoID)"
    }
}

// MARK: - Setup
private extension UserInfoView {
    func setupViews() {
        backgroundColor = UIColor(red: 252/255, green: 252/255, blue: 252/255, alpha: 1)

        configureNameLabel()
        configureSubtitleLabel()
        configureChevronButton()
        configureAvatarImageView()

        configureSubtitleRowStackView()
        configureTextStackView()

        addSubview(textContainerView)
        textContainerView.addSubview(textStackView)

        addSubview(avatarImageView)
    }

    func setupConstraints() {
        textContainerView.translatesAutoresizingMaskIntoConstraints = false
        let preferredTrailing = textContainerView.trailingAnchor
            .constraint(equalTo: avatarImageView.leadingAnchor, constant: -12)
        preferredTrailing.priority = .defaultHigh
        preferredTrailing.isActive = true
        
        // 上限：絕對不能超過 avatar（防止重疊）
        let maxTrailing = textContainerView.trailingAnchor
            .constraint(lessThanOrEqualTo: avatarImageView.leadingAnchor, constant: -12)
        maxTrailing.priority = .required
        maxTrailing.isActive = true
        
        NSLayoutConstraint.activate([
            // Text container (left aligned area)
            textContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            textContainerView.centerYAnchor.constraint(equalTo: centerYAnchor),

            // Avatar (right aligned)
            avatarImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            avatarImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 52),
            avatarImageView.heightAnchor.constraint(equalToConstant: 52),

            // Avoid overlapping: text container should not exceed avatar leading
            textContainerView.trailingAnchor.constraint(lessThanOrEqualTo: avatarImageView.leadingAnchor, constant: -12),

            // Text stack inside container
            textStackView.topAnchor.constraint(equalTo: textContainerView.topAnchor),
            textStackView.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor),
            textStackView.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor),
            textStackView.bottomAnchor.constraint(equalTo: textContainerView.bottomAnchor),

            // Chevron size
            chevronButton.widthAnchor.constraint(equalToConstant: 16),
            chevronButton.heightAnchor.constraint(equalToConstant: 16),

            // Label heights (依你提供的標注固定高度)
            nameLabel.heightAnchor.constraint(equalToConstant: 18),
            subtitleLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
}

// MARK: - Private Helpers
private extension UserInfoView {
    func configureNameLabel() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        nameLabel.textColor = .systemGray
        nameLabel.numberOfLines = 1
        nameLabel.setContentHuggingPriority(.required, for: .vertical)
        nameLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

    }

    func configureSubtitleLabel() {
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 1
        subtitleLabel.setContentHuggingPriority(.required, for: .vertical)
        subtitleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        subtitleLabel.lineBreakMode = .byTruncatingTail
        subtitleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    func configureChevronButton() {
        chevronButton.translatesAutoresizingMaskIntoConstraints = false
        chevronButton.setContentHuggingPriority(.required, for: .horizontal)
        chevronButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        let image = UIImage(named: "icInfoBackDeepGray")?.withRenderingMode(.alwaysOriginal)
        chevronButton.setImage(image, for: .normal)
        chevronButton.tintColor = .secondaryLabel

        // 不做互動（但保留 UIButton 身份）
        chevronButton.isUserInteractionEnabled = false
    }

    func configureAvatarImageView() {
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 26

        // Placeholder avatar（之後可換 assets）
        avatarImageView.image = UIImage(systemName: "person.crop.circle.fill")?.withRenderingMode(.alwaysTemplate)
        avatarImageView.tintColor = .tertiaryLabel
    }

    func configureSubtitleRowStackView() {
        subtitleRowStackView.translatesAutoresizingMaskIntoConstraints = false
        subtitleRowStackView.axis = .horizontal
        subtitleRowStackView.alignment = .center
        subtitleRowStackView.distribution = .fill
        subtitleRowStackView.spacing = 4 // 「緊貼」的感覺：label 和 > 間距先小一點，之後可再微調
        subtitleRowStackView.setContentHuggingPriority(.required, for: .horizontal)
        subtitleRowStackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        subtitleRowStackView.addArrangedSubview(subtitleLabel)
        subtitleRowStackView.addArrangedSubview(chevronButton)
    }

    func configureTextStackView() {
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        textStackView.axis = .vertical
        textStackView.alignment = .leading
        textStackView.distribution = .fill
        textStackView.spacing = 8

        textStackView.addArrangedSubview(nameLabel)
        textStackView.addArrangedSubview(subtitleRowStackView)
    }
}
