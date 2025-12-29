//
//  FriendsListViewModel.swift
//  FriendsListInterview
//
//  Created by 黃昭銘 on 2025/12/27.
//

import Foundation

@MainActor
final class FriendsListViewModel: FriendsListViewModelProtocol {
    // MARK: - Output
    private(set) var state: FriendsListState = .loading {
        didSet { onStateChanged?(state) }
    }
    var onStateChanged: ((FriendsListState) -> Void)?
    
    // MARK: - Dependencies
    private let scenario: Scenario
    private let mergeUseCase: MergeFriendsUseCase
    private let searchUseCase: SearchFriendsUseCase
    private let repository: FriendsRepository
    
    // MARK: - Init
    init(
        scenario: Scenario,
        mergeUseCase: MergeFriendsUseCase,
        searchUseCase: SearchFriendsUseCase,
        repository: FriendsRepository
        ) {
        self.scenario = scenario
        self.mergeUseCase = mergeUseCase
        self.searchUseCase = searchUseCase
        self.repository = repository
        }
   
    // MARK: - Stored Properties
    private var allFriends: [Friend] = []
   
    // MARK: - Public API
    func loadFriends() async {
        state = .loading
        
        do {
            let loaded: [Friend]
            
            switch scenario {
            case .empty:
                loaded = try await repository.fetchFriends(endpoint: APIConstants.friendList4)
            
            case .friendsOnly:
                async let f1 = repository.fetchFriends(endpoint: APIConstants.friendList1)
                async let f2 = repository.fetchFriends(endpoint: APIConstants.friendList2)
                let (a, b) = try await (f1, f2)
                loaded = mergeUseCase.mergeFriends(a, b)
                
            case .friendsWithInvites:
                loaded = try await repository.fetchFriends(endpoint: APIConstants.friendList3)
            }
            allFriends = loaded
            updateState(with: loaded)
            
        } catch {
            allFriends = []
            updateState(with: [])
        }
    }
    
    func searchFriends(query: String) {
        let searchResult = searchUseCase.searchFriends(query: query, in: allFriends)
        updateState(with: searchResult)
    }
}

// MARK: - Helpers
private extension FriendsListViewModel {
    func updateState(with friends: [Friend]) {
        guard !friends.isEmpty else {
            state = .empty
            return
        }
        
        let receivedInvitations = friends.filter { $0.status == .receivedInvitation }
        let friendsAndSentInvitations = friends.filter { $0.status == .accepted || $0.status == .sentInvitation }
        
        state = .content(receivedInvitations: receivedInvitations, friends: friendsAndSentInvitations)
    }
}
