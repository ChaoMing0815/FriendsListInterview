//
//  FriendsHeaderView.swift
//  FriendsListInterview
//
//  Created by 黃昭銘 on 2025/12/29.
//

import Foundation
import UIKit

final class FriendsHeaderView: UIView {
    private let label: UILabel = {
        let l = UILabel()
        l.text = "Header Placeholder"
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }
}

