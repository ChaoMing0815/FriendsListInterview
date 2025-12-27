//
//  DefaultFriendsRepositoryTests.swift
//  FriendsListInterviewTests
//
//  Created by 黃昭銘 on 2025/12/27.
//

import XCTest
@testable import FriendsListInterview

final class DefaultFriendsRepositoryTests: XCTestCase {
    func test_fetchFriends_shouldMapFriendDTOsToFriends() async throws {
        let service = MockFriendsAPIService()
        service.result = .success([
            mockFriendDTO(name: "AAA", status: 1, isTop: "1", fid: "1", updateDate: "20001122"),
            mockFriendDTO(name: "BBB", status: 2, isTop: "0",fid: "2", updateDate: "20001123"),
            mockFriendDTO(name: "CCC", status: 1, isTop: "1",fid: "3", updateDate: "20001124")
        ])
        
        let repository = DefaultFriendsRepository(service: service)
        let friends = try await repository.fetchFriends()
        
        XCTAssertEqual(friends.count, 3)
        
        /// 測試 DTO -> Domain Model 是否轉換成功
        let a = try XCTUnwrap(friends.first(where: { $0.fid == "1" }))
        XCTAssertEqual(a.name, "AAA")
        XCTAssertEqual(a.fid, "1")
        XCTAssertEqual(a.status, .accepted)
        XCTAssertEqual(a.isTop, true)
        
        /// 測試日期字串是否轉換成功
        let expectedDate = makeDate("20001122")
        XCTAssertEqual(a.updateDate, expectedDate)
        
        /// 其他條件測試
        let b = try XCTUnwrap(friends.first(where: { $0.fid == "2" }))
        XCTAssertEqual(b.name, "BBB")
        XCTAssertEqual(b.fid, "2")
        XCTAssertEqual(b.status, .sentInvitation)
        XCTAssertEqual(b.isTop, false)
    }
    
    func test_fetchFriends_shouldThrowError_whenServiceFails() async {
        enum DummyError: Error { case fail }
        
        let service = MockFriendsAPIService()
        service.result = .failure(DummyError.fail)
        
        let repository = DefaultFriendsRepository(service: service)
        
        do {
            _ = try await repository.fetchFriends()
            XCTFail("Expected throw error, but succeeded.")
        } catch {
            XCTAssertTrue(error is DummyError)
        }
    }
}

// MARK: - Mock FriendsAPIService
final class MockFriendsAPIService: FriendsAPIService {
    var result: Result<[FriendDTO], Error> = .success([])
    
    func fetchFriends() async throws -> [FriendDTO] {
        try result.get()
    }
}

// MARK: - Helpers
private extension DefaultFriendsRepositoryTests {
    func mockFriendDTO(name: String, status: Int, isTop: String, fid: String, updateDate: String) -> FriendDTO {
        let dto = FriendDTO(
            name: name,
            status: status,
            isTop: isTop,
            fid: fid,
            updateDate: updateDate
        )
        return dto
    }
    
    func makeDate(_ yyyymmdd: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.date(from: yyyymmdd) ?? .distantPast
    }
}
