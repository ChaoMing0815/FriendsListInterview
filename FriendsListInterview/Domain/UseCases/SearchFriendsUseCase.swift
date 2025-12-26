//
//  SearchFriendsUseCase.swift
//  FriendsListInterview
//
//  Created by 黃昭銘 on 2025/12/26.
//

import Foundation

struct SearchFriendsUseCase {
    func searchFriends(query: String, in friends: [Friend]) -> [Friend] {
        guard !query.isEmpty else { return friends }
        
        return friends.filter {
            $0.name.localizedStandardContains(query)
        }
    }
}
