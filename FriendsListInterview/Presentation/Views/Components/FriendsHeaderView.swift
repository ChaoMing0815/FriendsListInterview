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
    private let friendsSegmentView = FriendsSegmentView()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()

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
        addSubview(friendsSegmentView)
    }

    func setupConstraints() {
        toolsBarView.translatesAutoresizingMaskIntoConstraints = false
        userInfoView.translatesAutoresizingMaskIntoConstraints = false
        friendsSegmentView.translatesAutoresizingMaskIntoConstraints = false

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

            // Segment
            friendsSegmentView.topAnchor.constraint(equalTo: userInfoView.bottomAnchor),
            friendsSegmentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            friendsSegmentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            friendsSegmentView.heightAnchor.constraint(equalToConstant: 37),

            // Bottom
            friendsSegmentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

