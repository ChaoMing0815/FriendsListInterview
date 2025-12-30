//
//  ToolsBarView.swift
//  FriendsListInterview
//
//  Created by 黃昭銘 on 2025/12/30.
//

import Foundation
import UIKit

final class ToolsBarView: UIView {
    // MARK: - Callbacks
    // 滿足設計圖 UI 需求，ToolsBar 取代預設 NavigationBar ，自訂返回按鈕
    var onBackTapped: (() -> Void)?
    
    // MARK: - UI Components
    private let backButton = UIButton(type: .custom)
    private let atmButton = UIButton(type: .custom)
    private let transferButton = UIButton(type: .custom)
    private let scanButton = UIButton(type: .custom)
    
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
private extension ToolsBarView {
    func setupViews() {
        backgroundColor = .clear
        
        configureSystemBackButton()
        configureIconButton(atmButton, assetName: "icNavPinkWithdraw")
        configureIconButton(transferButton, assetName: "icNavPinkTransfer")
        configureIconButton(scanButton, assetName: "icNavPinkScan")
        
        addSubview(backButton)
        addSubview(atmButton)
        addSubview(transferButton)
        addSubview(scanButton)
        
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            backButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 18),
            backButton.heightAnchor.constraint(equalToConstant: 18),
            
            // icATM: leading 20, size 24x24
            atmButton.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 5),
            atmButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            atmButton.widthAnchor.constraint(equalToConstant: 24),
            atmButton.heightAnchor.constraint(equalToConstant: 24),
            
            // ic轉帳: 在 icATM 右邊 20
            transferButton.leadingAnchor.constraint(equalTo: atmButton.trailingAnchor, constant: 20),
            transferButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            transferButton.widthAnchor.constraint(equalToConstant: 24),
            transferButton.heightAnchor.constraint(equalToConstant: 24),
            
            // ic掃碼: trailing 20
            scanButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            scanButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            scanButton.widthAnchor.constraint(equalToConstant: 24),
            scanButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    @objc private func didTapBack() {
        onBackTapped?()
    }
}

// MARK: - Private Helpers
private extension ToolsBarView {
    func configureIconButton(_ button: UIButton, assetName: String) {
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // 現階段不做互動，但用 button 承載語意
        button.isUserInteractionEnabled = false
        
        // iOS 15+：用 configuration 取代舊的 adjustsImageWhenHighlighted
        var config = UIButton.Configuration.plain()
        config.contentInsets = .zero
        config.imagePadding = 0
        config.baseBackgroundColor = .clear
        config.background.backgroundColor = .clear
        config.image = UIImage(named: assetName)
        button.configuration = config
        
        // 關掉 highlighted 的視覺反應
        //（等同舊的 adjustsImageWhenHighlighted = false）
        button.configurationUpdateHandler = { btn in
            // 不論狀態都維持一致（避免系統自動變暗/變透明）
            btn.alpha = 1
        }
    }
    
    func configureSystemBackButton() {
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.isUserInteractionEnabled = true
        
        var config = UIButton.Configuration.plain()
        config.contentInsets = .zero
        config.imagePadding = 0
        config.baseBackgroundColor = .clear
        config.background.backgroundColor = .clear
        config.image = UIImage(systemName: "chevron.left")
        backButton.configuration = config
        backButton.tintColor = .label
        
        backButton.configurationUpdateHandler = { btn in
            btn.alpha = 1
        }
    }
}
