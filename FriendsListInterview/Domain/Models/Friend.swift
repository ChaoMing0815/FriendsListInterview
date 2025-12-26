//
//  Friend.swift
//  FriendsListInterview
//
//  Created by 黃昭銘 on 2025/12/26.
//

import Foundation

struct Friend: Equatable {
    let name: String
    let status: FriendStatus  /// 好友狀態
    let isTop: Bool  /// 是否標注星號
    let fid: String
    let updateDate: Date
}

enum FriendStatus: Int {
    case receivedInvitation = 0  /// 邀請中的好友 = 0
    case accepted = 1  /// 已接受的好友 = 1
    case sentInvitation = 2  /// 等待回覆邀請的好友 = 2
}
