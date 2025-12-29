//
//  FriendsListViewModelProtocol.swift
//  FriendsListInterview
//
//  Created by 黃昭銘 on 2025/12/27.
//

import Foundation

protocol FriendsListViewModelProtocol {
    var state: FriendsListState { get }
    var onStateChanged: ((FriendsListState) -> Void)? { get set }
    
    @MainActor
    func loadFriends() async
    
    @MainActor
    func searchFriends(query: String)
}


