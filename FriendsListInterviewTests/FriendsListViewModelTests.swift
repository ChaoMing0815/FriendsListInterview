//
//  FriendsListViewModelTests.swift
//  FriendsListInterviewTests
//
//  Created by 黃昭銘 on 2025/12/28.
//

import XCTest
@testable import FriendsListInterview

@MainActor
final class FriendsListViewModelTests: XCTestCase {
    // MARK: - Test Empty Scenario
    func test_loadFriends_emptyScenario_returnsEmpty_andRequestsFriendList4() async {
        // Given
        let repository = MockFriendsRepository()
        repository.stub[APIConstants.friendList4] = []
        
        let sut = makeSUT(scenario: .empty, repository: repository)
        
        var states: [FriendsListState] = []
        sut.onStateChanged = { states.append($0) }
        
        // When
        await sut.loadFriends()
        
        // Then
        XCTAssertEqual(repository.requestedEndpoints, [APIConstants.friendList4])
        
        /// 初始狀態應為 .loading
        guard let firstState = states.first else {
            XCTFail("Expected at least one state but got none.")
            return
        }
        
        if case .loading = firstState {
            // ok
        } else {
            XCTFail("Expected first state to be .loading, but got \(firstState)")
        }
        
        /// 最後狀態應為 .empty
        if case .empty = sut.state {
            // ok
        } else {
            XCTFail("Expected final state to be .empty, but got \(sut.state)")
        }
    }
    
    // MARK: - Test Friends With Invites Scenario
    func test_loadFriends_friendsWithInvitesScenario_returnsFriends_andRequestsFriendList3() async {
        // Given
        let repository = MockFriendsRepository()
        repository.stub[APIConstants.friendList3] = [
            makeFriend(fid: "001", status: .receivedInvitation),
            makeFriend(fid: "002", status: .accepted),
            makeFriend(fid: "003", status: .sentInvitation)
        ]
        
        let sut = makeSUT(scenario: .friendsWithInvites, repository: repository)
        
        // When
        await sut.loadFriends()
        
        // Then
        XCTAssertEqual(repository.requestedEndpoints, [APIConstants.friendList3])
        
        guard case let .content(receivedInvitation, friends) = sut.state else {
            return XCTFail("Expected .content, but got \(sut.state)")
        }
        
        /// 應出現待回覆好友邀請名單
        XCTAssertEqual(receivedInvitation.count, 1)
        XCTAssertEqual(receivedInvitation.first?.status, .receivedInvitation)
        
        /// 好友清單中應包含已接受邀請及已發送邀請
        XCTAssertEqual(friends.count, 2)
        XCTAssertTrue(friends.allSatisfy({ $0.status == .accepted || $0.status == .sentInvitation }))
    }
    
    // MARK: - Test Friends Only Scenario
    func test_loadFriends_friendsOnlyScenario_mergesAndDeduplicatesFriends_requestFriendList1And2() async {
        // Given
        let repository = MockFriendsRepository()
        repository.stub[APIConstants.friendList1] = [
            makeFriend(fid: "001", status: .accepted),
            makeFriend(fid: "002", status: .accepted)
        ]
        repository.stub[APIConstants.friendList2] = [
            makeFriend(fid: "001", status: .accepted),
            makeFriend(fid: "003", status: .sentInvitation)
        ]
        
        let sut = makeSUT(scenario: .friendsOnly, repository: repository)
        
        // When
        await sut.loadFriends()
        
        // Then
        XCTAssertEqual(
            Set(repository.requestedEndpoints),
            Set([APIConstants.friendList1, APIConstants.friendList2])
        )
        
        guard case let .content(receivedInvitations, friends) = sut.state else {
            return XCTFail("Expected .content, but got \(sut.state)")
        }
        
        /// 無好友邀請
        XCTAssertEqual(receivedInvitations.count, 0)
        
        /// 應呈現合併且去重複的結果
        XCTAssertEqual(friends.count, 3)
        let fids = Set(friends.map { $0.fid })
        XCTAssertEqual(fids, Set(["001", "002", "003"]))
    }
    
    // MARK: - Test Search Friends
    func test_searchFriends_shouldUpdateState_basedOnSearchResult_andRestoreOnEmptyQuery() async {
        // Given
        let repository = MockFriendsRepository()
        repository.stub[APIConstants.friendList3] = [
            makeFriend(fid: "001", name: "王大明", status: .receivedInvitation),
            makeFriend(fid: "002", name: "李小白", status: .accepted),
            makeFriend(fid: "003", name: "王小紅", status: .accepted)
        ]
        
        let sut = makeSUT(scenario: .friendsWithInvites, repository: repository)
        
        await sut.loadFriends()
        
        /// 前置測試 load 應該成功
        guard case .content = sut.state else {
            return XCTFail("Expected .content after load")
        }
        
        // When
        /// 輸入搜尋字串
        sut.searchFriends(query: "小紅")
        
        // Then
        guard case let .content(_, friendsAfterSearch) = sut.state else {
            return XCTFail("Expected .content after search")
        }
        /// 應顯示過濾結果
        XCTAssertEqual(friendsAfterSearch.count, 1)
        XCTAssertEqual(friendsAfterSearch.first?.name, "王小紅")
        
        // When
        /// 清空搜尋字串
        sut.searchFriends(query: "")
        
        // Then
        guard case let .content(receivedInvitationsRestored, friendsRestored) = sut.state else {
            return XCTFail("Expected .content after restore")
        }
        /// 應恢復原清單
        XCTAssertEqual(receivedInvitationsRestored.count, 1)
        XCTAssertEqual(friendsRestored.count, 2)
    }
}

// MARK: - Helpers
@MainActor
private extension FriendsListViewModelTests {
    func makeSUT(scenario: Scenario, repository: FriendsRepository) -> FriendsListViewModel {
        FriendsListViewModel(
            scenario: scenario,
            mergeUseCase: MergeFriendsUseCase(),
            searchUseCase: SearchFriendsUseCase(),
            repository: repository
        )
    }
    
    func makeFriend(fid: String, name: String = "Name-\(UUID().uuidString)", status: FriendStatus) -> Friend {
        Friend(name: name, status: status, isTop: false, fid: fid, updateDate: Date(timeIntervalSince1970: 0))
    }
}

// MARK: - MockRepository
final class MockFriendsRepository: FriendsRepository {
    var stub: [String: [Friend]] = [:]
    private(set) var requestedEndpoints: [String] = []
    
    func fetchFriends(endpoint: String) async throws -> [Friend] {
        requestedEndpoints.append(endpoint)
        return stub[endpoint] ?? []
    }
}
