//
//  GetGuestSessionId.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 02.05.2021.
//

import Foundation

struct GetGuestSessionId: Decodable {

    let success: Bool
    let guestSessionId: String?
    let expiresAt: String?
    
    enum CodingKeys: String, CodingKey {
        case success
        case guestSessionId = "guest_session_id"
        case expiresAt = "expires_at"
    }
}
