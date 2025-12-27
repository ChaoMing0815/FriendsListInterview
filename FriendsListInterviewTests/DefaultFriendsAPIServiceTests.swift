//
//  DefaultFriendsAPIServiceTests.swift
//  FriendsListInterviewTests
//
//  Created by 黃昭銘 on 2025/12/27.
//

import XCTest
@testable import FriendsListInterview

final class DefaultFriendsAPIServiceTests: XCTestCase {
    // MARK: - Reset handler after each test
    override func tearDown() {
          MockURLProtocol.requestHandler = nil
          super.tearDown()
      }
    
    /// 測試是否正確傳回DTO
    func test_fetchFriends_returnsResponseAndDecodedData_whenSuccess() async throws {
        let json = """
            { "response": [
                { "name": "AAA", "status": 1, "isTop": "1", "fid": "001", "updateDate": "20001122"}
            ] }
            """.data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil)!
            return (json, response)
        }
        
        let service = DefaultFriendsAPIService(
            url: URL(string: "https://servicetest.com")!,
            session: makeMockURLSession(),
            decoder: JSONDecoder()
        )
        
        let dtos = try await service.fetchFriends()
        
        XCTAssertEqual(dtos.count, 1)
        XCTAssertEqual(dtos.first?.fid, "001")
        XCTAssertEqual(dtos.first?.name, "AAA")
    }
    
    func test_fetchFriends_throwsError_whenStatusCodeIsNot2XX() async {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil)!
            return (Data(), response)
        }
        
        let service = DefaultFriendsAPIService(
            url: URL(string: "https://servicetest.com")!,
            session: makeMockURLSession(),
            decoder: JSONDecoder()
        )
        
        do {
            _ = try await service.fetchFriends()
            XCTFail("Expected httpStatusCode error, but succeeded.")
        } catch let error as FriendsAPIServiceError {
            if case .httpStatusCode(500) = error {
                XCTAssertTrue(true)
            } else {
                XCTFail("Expected .httpStatusCode(500), but got \(error)")
            }
        } catch {
            XCTFail("Expected FriendsAPIServiceError, but got \(error)")
        }
    }
    
    func test_fetchFriends_throwsError_whenFailedToDecodeData() async throws {
        let invalidJson = """
                { "wrongKey": [] } 
            """.data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil)!
            return (invalidJson, response)
        }
        
        let service = DefaultFriendsAPIService(
            url: URL(string: "https://servicetest.com")!,
            session: makeMockURLSession(),
            decoder: JSONDecoder()
        )
        
        do {
            _ = try await service.fetchFriends()
            XCTFail("Expected decoing error, but succeeded.")
        } catch let error as FriendsAPIServiceError {
            if case .decodingError(_) = error {
                XCTAssertTrue(true)
            } else {
                XCTFail("Expected decodingError, but got \(error)")
            }
        } catch {
            XCTFail("Expected FriendsAPIServiceError, but got \(error)")
        }
    }
}

// MARK: - Mock URLProtocol
final class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (Data, URLResponse))?
    
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    
    override func startLoading() {
        guard let handler = Self.requestHandler else {
            XCTFail("MockURLProtocol.requestHandler not set")
            return
        }
        
        do {
            let (data, response) = try handler(self.request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {}
}

// MARK: - Make MockURLSession
private extension DefaultFriendsAPIServiceTests {
    func makeMockURLSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: config)
    }
}
