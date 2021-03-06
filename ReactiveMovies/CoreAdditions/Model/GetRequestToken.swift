//
//  GetRequestToken.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 01.05.2021.
//

import Foundation

struct GetRequestToken: Decodable {
    let success: Bool
    let requestToken: String?
    let expiresAt: String?
    
    enum CodingKeys: String, CodingKey {
        case success
        case requestToken = "request_token"
        case expiresAt = "expires_at"
    }
}
