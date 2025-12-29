//
//  FriendCell.swift
//  FriendsListInterview
//
//  Created by 黃昭銘 on 2025/12/29.
//

import UIKit

final class FriendCell: UITableViewCell {
    
    static let reuseIdentifier: String = "FriendCell"
    
    var onTransferTapped: (() -> Void)?
    var onMoreTapped: (() -> Void)?
    
    // MARK: - UI
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let topStarView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "star.fill"))
        imageView.tintColor = .systemYellow
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
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
    
    private let transferButton: UIButton = {
        var config = UIButton.Configuration.plain()
            config.title = "轉帳"
            config.baseForegroundColor = .systemPink
            config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)

            let button = UIButton(configuration: config)
            button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
            button.layer.cornerRadius = 6
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.systemPink.cgColor
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
    }()
    
    private let pendingLabel: UILabel = {
        let label = UILabel()
        label.text = "邀請中"
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.layer.cornerRadius = 6
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.systemGray4.cgColor
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    private let moreButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        button.setImage(UIImage(systemName: "ellipsis", withConfiguration:  config),for: .normal)
        button.tintColor = .systemGray3
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupLayout()
        setActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.image = nil
        nameLabel.text = nil
        topStarView.isHidden = true
        transferButton.isHidden = false
        pendingLabel.isHidden = true
        moreButton.isHidden = false
        onTransferTapped = nil
        onMoreTapped = nil
    }
    
    // MARK: - Configure
    func configure(name: String, status: FriendStatus, isTop: Bool, avatar: UIImage? = nil) {
        nameLabel.text = name
        avatarImageView.image = avatar ?? UIImage(systemName: "person.crop.circle.fill")
        topStarView.isHidden = !isTop
        
        switch status {
        case .accepted:
            transferButton.isHidden = false
            pendingLabel.isHidden = true
            moreButton.isHidden = false
       
        case .sentInvitation:
            transferButton.isHidden = false
            pendingLabel.isHidden = false
            moreButton.isHidden = true
            
        case .receivedInvitation:
            transferButton.isHidden = true
            pendingLabel.isHidden = true
            moreButton.isHidden = true
        }
    }
}

// MARK: - Helpers
private extension FriendCell {
    // MARK: - Setup Layout
    func setupLayout() {
        let leftStack = makeStackView(axis: .horizontal, spacing: 10, alignment: .center, arrangedSubviews: [topStarView, avatarImageView, nameLabel])
        
        let rightStack = makeStackView(axis: .horizontal, spacing: 8, alignment: .center, arrangedSubviews: [transferButton, pendingLabel, moreButton])
        
        let rootStack = makeStackView(axis: .horizontal, spacing: 12, alignment:  .center, arrangedSubviews: [leftStack, spacer(), rightStack])
        
        contentView.addSubview(rootStack)
        
        NSLayoutConstraint.activate([
            rootStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            rootStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            rootStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            rootStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            avatarImageView.widthAnchor.constraint(equalToConstant: 40),
            avatarImageView.heightAnchor.constraint(equalToConstant: 40),
            
            topStarView.widthAnchor.constraint(equalToConstant: 16),
            topStarView.heightAnchor.constraint(equalToConstant: 16),
            
            pendingLabel.heightAnchor.constraint(equalToConstant: 32),
            pendingLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            
            moreButton.widthAnchor.constraint(equalToConstant: 32),
            moreButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    // Set Button Actions
    func setActions() {
        transferButton.addTarget(self, action: #selector(didTapTransfer), for: .touchUpInside)
        moreButton.addTarget(self, action: #selector(didTapMore), for: .touchUpInside)
    }
    
    @objc func didTapTransfer() { onTransferTapped?() }
    @objc func didTapMore() { onMoreTapped?() }
    
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
