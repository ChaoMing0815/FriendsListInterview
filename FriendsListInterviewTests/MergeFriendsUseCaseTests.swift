//
//  MergeFriendsUseCaseTests.swift
//  FriendsListInterviewTests
//
//  Created by 黃昭銘 on 2025/12/26.
//

import XCTest
@testable import FriendsListInterview

final class MergeFriendsUseCaseTests: XCTestCase {
    func test_mergeFriends_shouldKeepNewerFriend_whenFidDuplicated() {
        let olderFriend = mockFriend(fid: "001", updateTime: 100)
        let newerFriend = mockFriend(fid: "001", updateTime: 200)
        
        let expected: [Friend] = [newerFriend]
        let result = MergeFriendsUseCase().mergeFriends([olderFriend], [newerFriend])
        
        XCTAssertEqual(result, expected)
    }
    
    func test_mergeFriends_shouldKeepAllFriends_whenNoDuplicated() {
        let friends1: [Friend] = [
            mockFriend(fid: "001", updateTime: 100),
            mockFriend(fid: "003", updateTime: 300),
            mockFriend(fid: "004", updateTime: 400),
        ]
        
        let friends2: [Friend] = [
            mockFriend(fid: "002", updateTime: 200),
            mockFriend(fid: "005", updateTime: 500),
            mockFriend(fid: "006", updateTime: 600),
        ]
        
        let expected: [Friend] = [
            mockFriend(fid: "001", updateTime: 100),
            mockFriend(fid: "002", updateTime: 200),
            mockFriend(fid: "003", updateTime: 300),
            mockFriend(fid: "004", updateTime: 400),
            mockFriend(fid: "005", updateTime: 500),
            mockFriend(fid: "006", updateTime: 600),
        ]
        
        let result = MergeFriendsUseCase().mergeFriends(friends1, friends2)
        
        XCTAssertEqual(result.count, expected.count)
        XCTAssertEqual(Set(result.map(\.fid)), Set(expected.map(\.fid)))
    }
    
    func test_mergeFriends_shouldResolveDuplicates_forMultipleFids() {
        let friends1: [Friend] = [
            mockFriend(fid: "001", updateTime: 100),
            mockFriend(fid: "003", updateTime: 350),
            mockFriend(fid: "004", updateTime: 400),
            mockFriend(fid: "007", updateTime: 700)
        ]
        
        let friends2: [Friend] = [
            mockFriend(fid: "001", updateTime: 150),
            mockFriend(fid: "002", updateTime: 200),
            mockFriend(fid: "003", updateTime: 300),
            mockFriend(fid: "005", updateTime: 500)
        ]
        
        let expected: [Friend] = [
            mockFriend(fid: "001", updateTime: 150),
            mockFriend(fid: "002", updateTime: 200),
            mockFriend(fid: "003", updateTime: 350),
            mockFriend(fid: "004", updateTime: 400),
            mockFriend(fid: "005", updateTime: 500),
            mockFriend(fid: "007", updateTime: 700)
        ]
        
        let result = MergeFriendsUseCase().mergeFriends(friends1, friends2)
        
        XCTAssertEqual(Set(result.map(\.fid)), Set(expected.map(\.fid)))
        XCTAssertEqual(result.first(where: { $0.fid == "001" })?.updateDate, Date(timeIntervalSince1970: 150))
        XCTAssertEqual(result.first(where: { $0.fid == "003" })?.updateDate, Date(timeIntervalSince1970: 350))
    }
}


// MARK: - Factory Methods
private extension MergeFriendsUseCaseTests {
    func mockFriend(fid: String, updateTime: TimeInterval) -> Friend {
        Friend(
            name: "Tester\(fid)",
            status: .accepted,
            isTop: false,
            fid: fid,
            updateDate: Date(timeIntervalSince1970: updateTime)
        )
    }
}
