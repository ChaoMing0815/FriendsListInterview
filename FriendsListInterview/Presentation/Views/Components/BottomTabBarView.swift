//
//  BottomTabBarView.swift
//  FriendsListInterview
//
//  Created by 黃昭銘 on 2025/12/30.
//

import Foundation
import UIKit

final class BottomTabBarView: UIView {
    
    // MARK: - UI
    private let moneyImageView = UIImageView()
    private let friendsImageView = UIImageView()
    private let koImageView = UIImageView()
    private let ledgerImageView = UIImageView()
    private let settingsImageView = UIImageView()
    
    /// 分隔線（不貼 top，要貼近 KO 圓圈）
    private let topDivider = UIView()
    private var dividerTopConstraint: NSLayoutConstraint!
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup
private extension BottomTabBarView {
    
    func setupViews() {
        backgroundColor = .white
        
        // 分隔線（設計稿那條淺色線）
        topDivider.backgroundColor = UIColor(white: 0, alpha: 0.06)
        topDivider.translatesAutoresizingMaskIntoConstraints = false
        addSubview(topDivider)
        
        [moneyImageView, friendsImageView, koImageView, ledgerImageView, settingsImageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.contentMode = .scaleAspectFit
            addSubview($0)
        }
        
        // assets
        moneyImageView.image = UIImage(named: "icTabbarProductsOff3")     // 28x46
        friendsImageView.image = UIImage(named: "icTabbarFriendsOn3")    // 28x46
        ledgerImageView.image = UIImage(named: "icTabbarManageOff3")     // 28x46
        settingsImageView.image = UIImage(named: "icTabbarSettingOff3")  // 28x46
        
        // KO 圖檔：85x68（含陰影外框）
        koImageView.image = UIImage(named: "icTabbarHomeOff")
        
        // 確保 KO 會蓋在分隔線上（避免線切到 KO）
        topDivider.layer.zPosition = 0
        koImageView.layer.zPosition = 1
    }
    
    func setupConstraints() {
        // Zeplin規格
        let sidePadding: CGFloat = 25
        let iconWidth: CGFloat = 28
        let iconHeight: CGFloat = 46
        
        // KO 圖檔實際尺寸（含陰影）
        let koWidth: CGFloat = 85
        let koHeight: CGFloat = 68
        
        // KO 圓圈本體 50x50，半徑 25
        let koCircleRadius: CGFloat = 25
        
        // 讓分隔線「切進圓圈」一點點，讓圓弧超出線（微調 2~6 都合理）
        let dividerOverlap: CGFloat = 6
        
        let spacingMoneyToFriends: CGFloat = 46
        let spacingFriendsToKO: CGFloat = 36
        let spacingKOToLedger: CGFloat = 35
        let spacingLedgerToSettings: CGFloat = 46
        
        // 分隔線：左右貼齊、1pt 高
        NSLayoutConstraint.activate([
            topDivider.leadingAnchor.constraint(equalTo: leadingAnchor),
            topDivider.trailingAnchor.constraint(equalTo: trailingAnchor),
            topDivider.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        // 關鍵：分隔線位置綁 KO 的 centerY
        // 位置 = KO 圓圈頂端( centerY - 25 ) 再往下 overlap 一點
        dividerTopConstraint = topDivider.topAnchor.constraint(
            equalTo: koImageView.centerYAnchor,
            constant: -koCircleRadius + dividerOverlap
        )
        dividerTopConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            // KO 一定置中（不做 offset，靠 85x68 的高度自然「高出來」）
            koImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            koImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            koImageView.widthAnchor.constraint(equalToConstant: koWidth),
            koImageView.heightAnchor.constraint(equalToConstant: koHeight),
            
            // 左兩顆
            friendsImageView.trailingAnchor.constraint(equalTo: koImageView.leadingAnchor, constant: -spacingFriendsToKO),
            friendsImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            friendsImageView.widthAnchor.constraint(equalToConstant: iconWidth),
            friendsImageView.heightAnchor.constraint(equalToConstant: iconHeight),
            
            moneyImageView.trailingAnchor.constraint(equalTo: friendsImageView.leadingAnchor, constant: -spacingMoneyToFriends),
            moneyImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            moneyImageView.widthAnchor.constraint(equalToConstant: iconWidth),
            moneyImageView.heightAnchor.constraint(equalToConstant: iconHeight),
            moneyImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: sidePadding),
            
            // 右兩顆
            ledgerImageView.leadingAnchor.constraint(equalTo: koImageView.trailingAnchor, constant: spacingKOToLedger),
            ledgerImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            ledgerImageView.widthAnchor.constraint(equalToConstant: iconWidth),
            ledgerImageView.heightAnchor.constraint(equalToConstant: iconHeight),
            
            settingsImageView.leadingAnchor.constraint(equalTo: ledgerImageView.trailingAnchor, constant: spacingLedgerToSettings),
            settingsImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            settingsImageView.widthAnchor.constraint(equalToConstant: iconWidth),
            settingsImageView.heightAnchor.constraint(equalToConstant: iconHeight),
            settingsImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -sidePadding),
        ])
        
        // 可選：強制其他 icon 在分隔線下方（保險，不加也通常 OK）
        NSLayoutConstraint.activate([
            moneyImageView.topAnchor.constraint(greaterThanOrEqualTo: topDivider.bottomAnchor, constant: 6),
            friendsImageView.topAnchor.constraint(greaterThanOrEqualTo: topDivider.bottomAnchor, constant: 6),
            ledgerImageView.topAnchor.constraint(greaterThanOrEqualTo: topDivider.bottomAnchor, constant: 6),
            settingsImageView.topAnchor.constraint(greaterThanOrEqualTo: topDivider.bottomAnchor, constant: 6),
        ])
    }
}
