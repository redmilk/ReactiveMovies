//
//  ErrorTypes.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 19.04.2021.
//

import Foundation
import Combine

enum RequestError: Error {
    case invalidRequest
    case invalidResponse
    case parsing(message: String, error: Error)
    case network(message: String, error: URLError)
    case timeout(description: String)
    case dataLoadingError(statusCode: Int, data: Data)
    case unauthorized
    
    var errorDescription: String {
        switch self {
        case .network(let description, let error): return description + ". " + (error.localizedDescription)
        case .timeout(let description): return description
        case .parsing(let description, _): return description
        case .invalidRequest: return "Invalid request. Check URL or components."
        case .invalidResponse: return "Invalid response"
        case .dataLoadingError: return "Data loading error"
        case .unauthorized: return "Unauthorized"
        }
    }
}

enum APIError: Error, LocalizedError {
    case unknown, apiError(reason: String), parserError(reason: String), networkError(from: URLError)

    var errorDescription: String? {
        switch self {
        case .unknown: return "Unknown error"
        case .apiError(let reason),
             .parserError(let reason): return reason
        case .networkError(let from): return from.localizedDescription
        }
    }
}


func fetch(url: URL) -> AnyPublisher<Data, APIError> {
    let request = URLRequest(url: url)
    
    return URLSession.DataTaskPublisher(request: request, session: .shared)
        .tryMap { data, response in
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.unknown
            }
            if (httpResponse.statusCode == 401) {
                throw APIError.apiError(reason: "Unauthorized");
            }
            if (httpResponse.statusCode == 403) {
                throw APIError.apiError(reason: "Resource forbidden");
            }
            if (httpResponse.statusCode == 404) {
                throw APIError.apiError(reason: "Resource not found");
            }
            if (405..<500 ~= httpResponse.statusCode) {
                throw APIError.apiError(reason: "client error");
            }
            if (500..<600 ~= httpResponse.statusCode) {
                throw APIError.apiError(reason: "server error");
            }
            return data
        }
        .mapError { error in
            if let error = error as? APIError {
                return error
            }
            if let urlerror = error as? URLError {
                return APIError.networkError(from: urlerror)
            }
            return APIError.unknown
        }
        .eraseToAnyPublisher()
}

