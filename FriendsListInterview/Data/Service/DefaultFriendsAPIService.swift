//
//  DefaultFriendsAPIService.swift
//  FriendsListInterview
//
//  Created by 黃昭銘 on 2025/12/27.
//

import Foundation

// MARK: - APIServiceError
enum FriendsAPIServiceError: Error {
    case invalidURL
    case invalidResponse
    case httpStatusCode(Int)
    case emptyData
    case decodingError(Error)
}

// MARK: - Implemetation of FriendsAPIService
final class DefaultFriendsAPIService: FriendsAPIService {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let friendsURL: URL
    
    init( url: URL, session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.friendsURL = url
        self.session = session
        self.decoder = decoder
    }
    
    func fetchFriends() async throws -> [FriendDTO] {
        let (data, response) = try await session.data(from: friendsURL)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw FriendsAPIServiceError.invalidResponse
        }
        
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw FriendsAPIServiceError.httpStatusCode(httpResponse.statusCode)
        }
        
        guard !data.isEmpty else {
            throw FriendsAPIServiceError.emptyData
        }
        
        do {
            let decoded = try decoder.decode(FriendsResponseDTO.self, from: data)
            return decoded.response
        } catch {
            throw FriendsAPIServiceError.decodingError(error)
        }
    }
}
