//
//  InvitationCollectionView.swift
//  FriendsListInterview
//
//  Created by 黃昭銘 on 2025/12/30.
//

import Foundation
import UIKit

final class InvitationCollectionView: UIView {
    // MARK: - Data
    private var invitations: [Friend] = []

    // MARK: - Callback
    var onAcceptTapped: ((Friend) -> Void)?
    var onDeclineTapped: ((Friend) -> Void)?

    // MARK: - UI
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)

        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.showsHorizontalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.dataSource = self
        view.delegate = self
        view.register(InvitationCollectionViewCell.self,
                      forCellWithReuseIdentifier: InvitationCollectionViewCell.reuseIdentifier)
        return view
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public
    func update(invitations: [Friend]) {
        self.invitations = invitations
        collectionView.reloadData()
    }
}

// MARK: - Helpers
private extension InvitationCollectionView {
    func setupLayout() {
        addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: - UICollectionViewDataSource
extension InvitationCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        invitations.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: InvitationCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as! InvitationCollectionViewCell

        let friend = invitations[indexPath.item]
        cell.configure(name: friend.name)

        cell.onAcceptTapped = { [weak self] in
            self?.onAcceptTapped?(friend)
        }

        cell.onDeclineTapped = { [weak self] in
            self?.onDeclineTapped?(friend)
        }

        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension InvitationCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 卡片高度 70，左右 inset 由 sectionInset 控制
        // 寬度先做滿版（扣掉左右 30 + 30）
        let width = collectionView.bounds.width - 60
        return CGSize(width: width, height: 70)
    }
}
