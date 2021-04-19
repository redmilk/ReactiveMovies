//
//  ErrorTypes.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 19.04.2021.
//

import Foundation


enum RequestError: Error {
    case parsing(description: String, error: Error)
    case network(description: String, error: URLError)
    case requestTimeout(description: String)
    case unknown(description: String, error: NSError)
  //case session(description String, Response)
    
    var errorDescription: String {
        switch self {
        case .network(let description, _): return description
        case .requestTimeout(let description): return description
        case .parsing(let description, _): return description
        case .unknown(let description, _): return description
        }
    }
}
