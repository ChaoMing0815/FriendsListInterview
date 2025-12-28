//
//  DefaultFriendsRepository.swift
//  FriendsListInterview
//
//  Created by 黃昭銘 on 2025/12/27.
//

import Foundation

final class DefaultFriendsRepository: FriendsRepository {
    private let service: FriendsAPIService
    
    init(service: FriendsAPIService) {
        self.service = service
    }
    
    func fetchFriends(endpoint: String) async throws -> [Friend] {
        let dtos = try await self.service.fetchFriends(endpoint: endpoint)
        let friends = dtos.map { $0.toDomain() }
        return friends
    }
}
