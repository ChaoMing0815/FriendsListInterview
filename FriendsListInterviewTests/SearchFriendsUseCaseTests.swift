//
//  SearchFriendsUseCaseTests.swift
//  FriendsListInterviewTests
//
//  Created by 黃昭銘 on 2025/12/26.
//

import XCTest
@testable import FriendsListInterview

final class SearchFriendsUseCaseTests: XCTestCase {
    func test_searchFriends_returnsAllFriends_whenQueryEmpty() {
       let friendsList: [Friend] = [
            mockFriend(name: "A", fid: "1", updateTime: 100),
            mockFriend(name: "B", fid: "2", updateTime: 200),
            mockFriend(name: "C", fid: "3", updateTime: 300),
        ]
        
        let expected: [Friend] = friendsList
        let result = SearchFriendsUseCase().searchFriends(query: "", in: friendsList)
        
        XCTAssertEqual(result.map(\.fid), expected.map(\.fid))
    }
    
    func test_searchFriends_returnsMatchedFriend() {
        let friendsList: [Friend] = [
            mockFriend(name: "王大明", fid: "1", updateTime: 100),
            mockFriend(name: "李小白", fid: "2", updateTime: 200),
            mockFriend(name: "王小明", fid: "3", updateTime: 300)
        ]
        
        let expected: [Friend] = [friendsList[1]]
        let result = SearchFriendsUseCase().searchFriends(query: "小白", in: friendsList)
        
        XCTAssertEqual(result.map(\.fid), expected.map(\.fid))
    }
    
    func test_searchFriends_returnsMultipleResults_whenMultipleMatches() {
        let friendsList: [Friend] = [
            mockFriend(name: "王大明", fid: "1", updateTime: 100),
            mockFriend(name: "李小白", fid: "2", updateTime: 200),
            mockFriend(name: "王小明", fid: "3", updateTime: 300),
            mockFriend(name: "獅子王", fid: "4", updateTime: 400)
        ]
        
        let expected: [Friend] = [friendsList[0], friendsList[2], friendsList[3]]
        let result = SearchFriendsUseCase().searchFriends(query: "王", in: friendsList)
        
        XCTAssertEqual(result.map(\.fid), expected.map(\.fid))
    }
    
    func test_searchFriends_returnsMatchedFriend_whenQueryContainsSpaces() {
        let friendsList: [Friend] = [
            mockFriend(name: "王大明", fid: "1", updateTime: 100),
            mockFriend(name: "李小白", fid: "2", updateTime: 200),
            mockFriend(name: "王小明", fid: "3", updateTime: 300)
        ]
        
        let expected: [Friend] = [friendsList[1]]
        let result = SearchFriendsUseCase().searchFriends(query: "小\t白 ", in: friendsList)
        
        XCTAssertEqual(result.map(\.fid), expected.map(\.fid))
    }
    
    func test_searchFriends_returnsEmpty_whenNoMatch() {
        let friendsList: [Friend] = [
            mockFriend(name: "王大明", fid: "1", updateTime: 100),
            mockFriend(name: "李小白", fid: "2", updateTime: 200),
            mockFriend(name: "王小明", fid: "3", updateTime: 300)
        ]
        
        let result = SearchFriendsUseCase().searchFriends(query: "不存在的名字", in: friendsList)
        
        XCTAssertTrue(result.isEmpty)
    }
}

// MARK: - Factory Methods
private extension SearchFriendsUseCaseTests {
    func mockFriend(name: String, fid: String, updateTime: TimeInterval) -> Friend {
        return Friend(
            name: name,
            status: .accepted,
            isTop: false,
            fid: fid,
            updateDate: Date(timeIntervalSince1970: updateTime)
        )
    }
}
