//
//  ErrorTypes.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 19.04.2021.
//

import Foundation

enum RequestError: Error {
    case invalidRequest
    case invalidResponse
    case parsing(message: String, error: Error)
    case network(message: String, error: URLError)
    case timeout(description: String)
    case dataLoadingError(statusCode: Int, data: Data)
    
    var errorDescription: String {
        switch self {
        case .network(let description, _): return description
        case .timeout(let description): return description
        case .parsing(let description, _): return description
        case .invalidRequest: return "Invalid request. Check URL or components."
        case .invalidResponse: return "Invalid response"
        case .dataLoadingError: return "Data loading error"
        }
    }
}

