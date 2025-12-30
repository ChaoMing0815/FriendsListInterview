//
//  FriendsHeaderView.swift
//  FriendsListInterview
//
//  Created by 黃昭銘 on 2025/12/29.
//

import Foundation
import UIKit

final class FriendsHeaderView: UIView {
    // MARK: - UI Components
    private let toolsBarView = ToolsBarView()
    private let userInfoView = UserInfoView()

    var onBackTapped: (() -> Void)?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        
        toolsBarView.onBackTapped = { [weak self] in self?.onBackTapped?() }

        // Demo data for UI preview (no API required)
        userInfoView.configure(name: "蔡國泰", kokoID: "Mike")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup
private extension FriendsHeaderView {
    func setupViews() {
        backgroundColor = UIColor(red: 252/255, green: 252/255, blue: 252/255, alpha: 1)

        addSubview(toolsBarView)
        addSubview(userInfoView)
    }

    func setupConstraints() {
        toolsBarView.translatesAutoresizingMaskIntoConstraints = false
        userInfoView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // ToolsBar
            toolsBarView.topAnchor.constraint(equalTo: topAnchor),
            toolsBarView.leadingAnchor.constraint(equalTo: leadingAnchor),
            toolsBarView.trailingAnchor.constraint(equalTo: trailingAnchor),
            toolsBarView.heightAnchor.constraint(equalToConstant: 44),

            // UserInfo
            userInfoView.topAnchor.constraint(equalTo: toolsBarView.bottomAnchor),
            userInfoView.leadingAnchor.constraint(equalTo: leadingAnchor),
            userInfoView.trailingAnchor.constraint(equalTo: trailingAnchor),
            userInfoView.heightAnchor.constraint(equalToConstant: 64),

        ])
    }
}

