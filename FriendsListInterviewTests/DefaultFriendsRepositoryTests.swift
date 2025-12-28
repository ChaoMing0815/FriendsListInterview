//
//  DefaultFriendsRepositoryTests.swift
//  FriendsListInterviewTests
//
//  Created by 黃昭銘 on 2025/12/27.
//

import XCTest
@testable import FriendsListInterview

final class DefaultFriendsRepositoryTests: XCTestCase {
    func test_fetchFriends_mapFriendDTOsToFriends() async throws {
        let service = MockFriendsAPIService()
        service.result = .success([
            mockFriendDTO(name: "黃靖僑", status: 1, isTop: "0", fid: "001", updateDate: "2019/08/02"),
            mockFriendDTO(name: "翁勳儀", status: 1, isTop: "1", fid: "002", updateDate: "2019/08/01"),
            mockFriendDTO(name: "林宜真", status: 1, isTop: "0", fid: "012", updateDate: "2019/08/01")
        ])
        
        let repository = DefaultFriendsRepository(service: service)
        let friends = try await repository.fetchFriends(endpoint: APIConstants.friendList2)
        
        XCTAssertEqual(service.receivedEndpoint, APIConstants.friendList2)
        XCTAssertEqual(friends.count, 3)
        
        /// 測試 DTO -> Domain Model 是否轉換成功
        let a = try XCTUnwrap(friends.first(where: { $0.fid == "001" }))
        XCTAssertEqual(a.name, "黃靖僑")
        XCTAssertEqual(a.fid, "001")
        XCTAssertEqual(a.status, .accepted)
        XCTAssertEqual(a.isTop, false)
        
        /// 測試日期字串是否轉換成功
        let expectedDate = makeDate("2019/08/02")
        XCTAssertEqual(a.updateDate, expectedDate)
        
        /// 其他條件測試
        let b = try XCTUnwrap(friends.first(where: { $0.fid == "002" }))
        XCTAssertEqual(b.name, "翁勳儀")
        XCTAssertEqual(b.fid, "002")
        XCTAssertEqual(b.status, .accepted)
        XCTAssertEqual(b.isTop, true)
    }
    
    func test_fetchFriends_throwsError_whenServiceFails() async {
        enum DummyError: Error { case fail }
        
        let service = MockFriendsAPIService()
        service.result = .failure(DummyError.fail)
        
        let repository = DefaultFriendsRepository(service: service)
        
        do {
            _ = try await repository.fetchFriends(endpoint: APIConstants.friendList1)
            XCTFail("Expected throw error, but succeeded.")
        } catch let error as DummyError {
            switch error { case .fail: break }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

// MARK: - Mock FriendsAPIService
final class MockFriendsAPIService: FriendsAPIService {
    var result: Result<[FriendDTO], Error> = .success([])
    private(set) var receivedEndpoint: String?
    
    func fetchFriends(endpoint: String) async throws -> [FriendDTO] {
        receivedEndpoint = endpoint
        return try result.get()
    }
}

// MARK: - Helpers
private extension DefaultFriendsRepositoryTests {
    // MARK: - Make MockDTO
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
    
    // MARK: - DateFormatter
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    func makeDate(_ string: String) -> Date {
        return Self.dateFormatter.date(from: string) ?? .distantPast
    }
}
