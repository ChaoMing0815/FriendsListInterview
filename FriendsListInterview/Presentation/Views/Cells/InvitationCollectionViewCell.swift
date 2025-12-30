//
//  InvitationCollectionViewCell.swift
//  FriendsListInterview
//
//  Created by 黃昭銘 on 2025/12/30.
//

import Foundation
import UIKit

final class InvitationCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier: String = "InvitationCollectionViewCell"

    // MARK: - Callback
    var onAcceptTapped: (() -> Void)?
    var onDeclineTapped: (() -> Void)?

    // MARK: - UI
    private let cardView = InvitationCardView()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupCallbacks()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        cardView.reset()
        onAcceptTapped = nil
        onDeclineTapped = nil
    }

    // MARK: - Configure
    func configure(name: String, avatar: UIImage? = nil) {
        cardView.configure(name: name, avatar: avatar)
    }
}

// MARK: - Helpers
private extension InvitationCollectionViewCell {

    func setupLayout() {
        contentView.backgroundColor = .clear
        backgroundColor = .clear

        contentView.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // cell 內部不做左右 30，因為左右 30 會交給 collection view 的 section inset
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    func setupCallbacks() {
        cardView.onAcceptTapped = { [weak self] in self?.onAcceptTapped?() }
        cardView.onDeclineTapped = { [weak self] in self?.onDeclineTapped?() }
    }
}
