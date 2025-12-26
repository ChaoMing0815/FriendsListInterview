//
//  SearchFriendsUseCase.swift
//  FriendsListInterview
//
//  Created by 黃昭銘 on 2025/12/26.
//

import Foundation

struct SearchFriendsUseCase {
    func searchFriends(query: String, in friends: [Friend]) -> [Friend] {
        /// 避免輸入空白鍵導致無法判讀
        let keyword = normalize(query)
        
        /// 清空搜尋欄後回傳原來好友清單
        guard !keyword.isEmpty else { return friends }
        
        /// 使用修飾後的關鍵字進行篩選
        return friends.filter { $0.name.localizedStandardContains(keyword) }
    }
}

// MARK: - Helpers
private extension SearchFriendsUseCase {
    func normalize(_ text: String) -> String {
        text
            .components(separatedBy: .whitespacesAndNewlines)
            .joined(separator: "")
    }
}
