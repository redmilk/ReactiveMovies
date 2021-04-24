//
//  ErrorTypes.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 19.04.2021.
//

import Foundation
import Combine

enum RequestError: Error, LocalizedError {
    
    case api(Int)
    case network(String, URLError)
    case parsing(String, Error)
    case unauthorized
    case timeout
    case unknown
    
    var errorDescription: String {
        switch self {
        case .network(let description, let error): return description + ". " + (error.localizedDescription)
        case .timeout: return "Request time out"
        case .api(let code) where code == 403: return "Resource forbidden"
        case .api(let code) where code == 404: return "Resource not found"
        case .api(let code) where 405..<500 ~= code: return "Client error"
        case .api(let code) where 500..<600 ~= code: return "Server error"
        case .api(let code): return "Api error: \(code.description)"
        case .parsing(let description, _): return description
        case .unauthorized: return "Unauthorized"
        case .unknown: return "Unknown error"
        }
    }
}





