//
//  FriendsAPIService.swift
//  FriendsListInterview
//
//  Created by 黃昭銘 on 2025/12/26.
//

import Foundation

protocol FriendsAPIService {
    func fetchFriends() async throws -> [FriendDTO]
}
