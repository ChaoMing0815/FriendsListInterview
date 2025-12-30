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
    
    private var transferTrailingToContentConstraint: NSLayoutConstraint!
    private var transferTrailingToPendingConstraint: NSLayoutConstraint!
    
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
        let imageView = UIImageView(image: UIImage(named: "icFriendsStar"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.alpha = 0 /// 預設不顯示
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
        var config = UIButton.Configuration.bordered()
        var title = AttributedString("轉帳")
        title.font = .systemFont(ofSize: 14, weight: .semibold)
        config.attributedTitle = title
        
        config.baseForegroundColor = .systemPink
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
        
        config.background.strokeColor = .systemPink
        config.background.strokeWidth = 1
        config.background.cornerRadius = 2
        config.background.backgroundColor = .clear
        
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let pendingButton: UIButton = {
        var config = UIButton.Configuration.bordered()
        var title = AttributedString("邀請中")
        title.font = .systemFont(ofSize: 14, weight: .semibold)
        config.attributedTitle = title
        
        config.baseForegroundColor = .systemGray
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
        
        config.background.strokeColor = .systemGray
        config.background.strokeWidth = 1
        config.background.cornerRadius = 2
        config.background.backgroundColor = .clear
        
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let moreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "icFriendsMore"),for: .normal)
        button.tintColor = .systemGray3
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        preservesSuperviewLayoutMargins = true
        contentView.preservesSuperviewLayoutMargins = true
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
        topStarView.alpha = 0
        transferButton.isHidden = false
        pendingButton.isHidden = true
        moreButton.isHidden = false
        onTransferTapped = nil
        onMoreTapped = nil
        
        transferTrailingToContentConstraint.isActive = true
        transferTrailingToPendingConstraint.isActive = false
        
        transferButton.isUserInteractionEnabled = true
        pendingButton.isUserInteractionEnabled = false
        moreButton.isUserInteractionEnabled = true
    }
    
    // MARK: - Configure
    func configure(name: String, status: FriendStatus, isTop: Bool, avatar: UIImage? = nil) {
        nameLabel.text = name
        avatarImageView.image = avatar ?? UIImage(systemName: "person.crop.circle.fill")
        avatarImageView.tintColor = .systemGray3
        topStarView.alpha = isTop ? 1 : 0
        
        switch status {
        case .accepted:
            transferTrailingToContentConstraint.isActive = true
            transferTrailingToPendingConstraint.isActive = false
            
            transferButton.isHidden = false
            pendingButton.isHidden = true
            moreButton.isHidden = false
            
            transferButton.isUserInteractionEnabled = true
            moreButton.isUserInteractionEnabled = true
            pendingButton.isUserInteractionEnabled = false

        case .sentInvitation:
            transferTrailingToContentConstraint.isActive = false
            transferTrailingToPendingConstraint.isActive = true
            
            transferButton.isHidden = false
            pendingButton.isHidden = false
            moreButton.isHidden = true
            
            transferButton.isUserInteractionEnabled = true
            pendingButton.isUserInteractionEnabled = false
            moreButton.isUserInteractionEnabled = false
   
        case .receivedInvitation:
            transferTrailingToContentConstraint.isActive = true
            transferTrailingToPendingConstraint.isActive = false
            
            transferButton.isHidden = true
            pendingButton.isHidden = true
            moreButton.isHidden = true
            
            transferButton.isUserInteractionEnabled = false
            pendingButton.isUserInteractionEnabled = false
            moreButton.isUserInteractionEnabled = false
        }
        contentView.setNeedsLayout()
    }
}

// MARK: - Helpers
private extension FriendCell {
    // MARK: - Setup Layout
    func setupLayout() {
        let leftStack = makeStackView(axis: .horizontal, spacing: 0, alignment: .center, arrangedSubviews: [topStarView, avatarImageView, nameLabel])
        
        
        contentView.addSubview(leftStack)
        contentView.addSubview(transferButton)
        contentView.addSubview(pendingButton)
        contentView.addSubview(moreButton)
        
        leftStack.setCustomSpacing(6, after: topStarView)
        leftStack.setCustomSpacing(15, after: avatarImageView)
        
        transferTrailingToContentConstraint = transferButton.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor, constant: -53)
        transferTrailingToPendingConstraint =
            transferButton.trailingAnchor.constraint(equalTo: pendingButton.leadingAnchor, constant: -10)
        
        NSLayoutConstraint.activate([
            leftStack.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor, constant: 10),
            leftStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            avatarImageView.widthAnchor.constraint(equalToConstant: 40),
            avatarImageView.heightAnchor.constraint(equalToConstant: 40),
            
            topStarView.widthAnchor.constraint(equalToConstant: 14),
            topStarView.heightAnchor.constraint(equalToConstant: 14),
            
            nameLabel.heightAnchor.constraint(equalToConstant: 22),
            
            moreButton.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor, constant: -10),
            moreButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            moreButton.widthAnchor.constraint(equalToConstant: 18),
            moreButton.heightAnchor.constraint(equalToConstant: 18),
            
            pendingButton.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor, constant: -10),
            pendingButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            pendingButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
            pendingButton.heightAnchor.constraint(equalToConstant: 24),
            
            transferButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            transferButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 47),
            transferButton.heightAnchor.constraint(equalToConstant: 24),
            
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: transferButton.leadingAnchor, constant: -8)
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
