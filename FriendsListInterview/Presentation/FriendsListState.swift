//
//  FriendsListState.swift
//  FriendsListInterview
//
//  Created by 黃昭銘 on 2025/12/27.
//

import Foundation

enum FriendsListState {
    case loading
    case empty /// 無好友
    case content(
        receivedInvitations: [Friend], /// status = 0, 接收到的好友邀請
        friends: [Friend] /// 包含 status = 1 已成為好友, status = 2 已邀請成為好友
    )
}
