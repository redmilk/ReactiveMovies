//
//  GetSessionId.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 01.05.2021.
//

import Foundation

struct GetSessionId: Decodable {
    let success: Bool
    let sessionId: String?
    
    enum CodingKeys: String, CodingKey {
        case success
        case sessionId = "session_id"
    }
}
