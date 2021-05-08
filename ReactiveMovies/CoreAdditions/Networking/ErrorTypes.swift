//
//  ErrorTypes.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 19.04.2021.
//

import Foundation
import Combine

enum RequestError: Error, LocalizedError, Equatable {
    case invalidToken
    case signInRequired
    case nilResponse(URLRequest)
    case api(Int, URLRequest)
    case network(String, URLError)
    case parsing(String, Error)
    case timeout(URLRequest)
    case unknown(Error)
    
    var errorDescription: String {
        switch self {
        case .invalidToken: return "Access token is invalid"
        case .signInRequired: return "Sign In required. Display authentication screen"
        case .nilResponse(let request): return "HTTPURLResponse is nil. URL \(String(describing: request.url?.absoluteString))"
        case .network(let description, let error): return description + ". " + (error.localizedDescription)
        case .timeout(let request): return "Request time out. URL \(String(describing: request.url?.absoluteString))"
        case .api(let code, let request) where code == 403: return "Resource forbidden. URL \(String(describing: request.url?.absoluteString))"
        case .api(let code, let request) where code == 404: return "Resource not found. URL \(String(describing: request.url?.absoluteString))"
        case .api(let code, let request) where 405..<500 ~= code: return "Client error. URL \(String(describing: request.url?.absoluteString))"
        case .api(let code, let request) where 500..<600 ~= code: return "Server error. URL \(String(describing: request.url?.absoluteString))"
        case .api(let code, let request): return "Api error: \(code.description). URL \(String(describing: request.url?.absoluteString))"
        case .parsing(let description, _): return description
        case .unknown(let error): return "Unknown error. Error \((error as NSError).code), \((error as NSError).localizedDescription)"
        }
    }
    
    static func == (lhs: RequestError, rhs: RequestError) -> Bool {
        lhs.errorDescription == rhs.errorDescription
    }
}





