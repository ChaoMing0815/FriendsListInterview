//
//  MergeFriendsUseCase.swift
//  FriendsListInterview
//
//  Created by 黃昭銘 on 2025/12/26.
//

import Foundation

struct MergeFriendsUseCase {
    func mergeFriends(_ first: [Friend], _ second: [Friend]) -> [Friend] {
        /// 當 fid 相同時，保留更新日期較新者
        var friendsById: [String: Friend] = [:]
        
        for friend in first + second {
            if let existedFriend = friendsById[friend.fid] {
                if friend.updateDate > existedFriend.updateDate {
                    friendsById[friend.fid] = friend
                }
            } else {
                friendsById[friend.fid] = friend
            }
        }
        
        return Array(friendsById.values)
    }
}


