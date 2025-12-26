//
//  FriendDTO.swift
//  FriendsListInterview
//
//  Created by 黃昭銘 on 2025/12/26.
//

import Foundation

// MARK: - Response DTO
struct FriendsResponseDTO: Codable {
    let response: [FriendDTO]
}

// MARK: - Item DTO
struct FriendDTO: Codable {
    let name: String
    let status: Int
    let isTop: String
    let fid: String
    let updateDate: String
}

// MARK: - DTO to Domain
extension FriendDTO {
    func toDomain() -> Friend {
        Friend(
            name: name,
            status: FriendStatus(rawValue: status) ?? .accepted,
            isTop: isTop == "1" ,
            fid: fid,
            updateDate: Self.dateFormatter.date(from: updateDate) ?? .distantPast
        )
    }
}

// MARK: - Parsing Date
private extension FriendDTO {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}
