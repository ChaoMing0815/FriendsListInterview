//
//  InvitationCollectionView.swift
//  FriendsListInterview
//
//  Created by 黃昭銘 on 2025/12/30.
//

import Foundation
import UIKit

final class InvitationCollectionView: UIView {
    // MARK: - Display Mode
    enum DisplayMode {
        case expanded
        case collapsed
    }
    
    private(set) var displayMode: DisplayMode = .expanded
    private var backgroundTap: UITapGestureRecognizer?
    
    /// 顯示模式所需常數
    private let maxExpandedVisibleCount: Int = 5
    private let itemHeight: CGFloat = 70
    private let lineSpacing: CGFloat = 10
    private let topInset: CGFloat = 8
    private let bottomInset: CGFloat = 8
    /// 收合時第二張露出的高度（之後做縮小/堆疊再調）
    private let collapsedSecondPeek: CGFloat = 24
    
    // 外部 ViewController 更新高度 constraint 使用
    var onPreferredHeightChanged: ((CGFloat, Bool) -> Void)?
    
    // MARK: - Data
    private var invitations: [Friend] = []

    // MARK: - Callback
    var onAcceptTapped: ((Friend) -> Void)?
    var onDeclineTapped: ((Friend) -> Void)?

    // MARK: - UI
    private let layout = UICollectionViewFlowLayout()
    private lazy var collectionView: UICollectionView = {
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 8, left: 30, bottom: 8, right: 30)

        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.showsVerticalScrollIndicator = false
        
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
        collectionView.layoutIfNeeded()
        notifyPreferredHeightChanged(animated: false)
    }
    
    func setDisplayMode(_ mode: DisplayMode, animated: Bool) {
        guard displayMode != mode else { return }
        displayMode = mode
        
        layout.minimumLineSpacing = (mode == .collapsed) ? -60 : lineSpacing
        
        if animated {
            // 通知外部會變化高度
            self.notifyPreferredHeightChanged(animated: true)
            
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut]) {
                self.layout.invalidateLayout()
                self.collectionView.performBatchUpdates(nil) // 讓 layout 變更有動畫
                self.applyCollapsedTransformsIfNeeded()
            }
        } else {
            layout.invalidateLayout()
            collectionView.performBatchUpdates(nil)
            notifyPreferredHeightChanged(animated: false)
            applyCollapsedTransformsIfNeeded()
        }
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
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        addGestureRecognizer(tap)
        backgroundTap = tap
    }
    
    // MARK: - Expand And Collapse Related Functions
    func notifyPreferredHeightChanged(animated: Bool) {
        let height = preferredHeight(for: displayMode)
        onPreferredHeightChanged?(height, animated)
    }

    func preferredHeight(for mode: DisplayMode) -> CGFloat {
        guard !invitations.isEmpty else { return 0 }

        switch mode {
        case .expanded:
            let visibleCount = min(invitations.count, maxExpandedVisibleCount)
            return expandedHeight(forVisibleCount: visibleCount)

        case .collapsed:
            return collapsedHeight()
        }
    }

    func expandedHeight(forVisibleCount count: Int) -> CGFloat {
        let contentHeight =
            topInset
            + CGFloat(count) * itemHeight
            + CGFloat(max(0, count - 1)) * lineSpacing
            + bottomInset
        return contentHeight
    }

    func collapsedHeight() -> CGFloat {
        // 第一張完整 + 第二張露角（peek）
        return topInset + itemHeight + collapsedSecondPeek + bottomInset
    }
    
    func applyCollapsedTransformsIfNeeded() {
        let isCollapsed = (displayMode == .collapsed)
        
        for cell in collectionView.visibleCells {
            guard let indexPath = collectionView.indexPath(for: cell) else { continue }
            
            if isCollapsed {
                if indexPath.item == 0 {
                    cell.transform = .identity
                    cell.layer.zPosition = 2
                    cell.isUserInteractionEnabled = true
                } else {
                    cell.transform = CGAffineTransform(scaleX: 0.90, y: 0.90)
                        .translatedBy(x: 0, y: 8)
                    cell.layer.zPosition = 1
                    cell.isUserInteractionEnabled = false
                }
            } else {
                cell.transform = .identity
                cell.layer.zPosition = 0
                cell.isUserInteractionEnabled = true
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
extension InvitationCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch displayMode {
           case .expanded:
               return invitations.count
           case .collapsed:
               return min(invitations.count, 2)
           }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: InvitationCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as! InvitationCollectionViewCell

        let friend = invitations[indexPath.item]
        cell.configure(name: friend.name)
        
        cell.onAcceptTapped = { [weak self] in self?.onAcceptTapped?(friend) }
        cell.onDeclineTapped = { [weak self] in self?.onDeclineTapped?(friend) }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        applyCollapsedTransformsIfNeeded()
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

// MARK: - UIGestureRecognizerDelegate
extension InvitationCollectionView: UIGestureRecognizerDelegate {
    @objc private func didTapBackground() {
        let next: DisplayMode = (displayMode == .collapsed) ? .expanded : .collapsed
        setDisplayMode(next, animated: true)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let point = touch.location(in: collectionView)
        // 點到任何 cell 都不要觸發（包含 cell 上的按鈕）
        if collectionView.indexPathForItem(at: point) != nil {
            return false
        }
        return true
    }
}
