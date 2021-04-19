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
    case unknown(error: NSError)
  //case session(description String, Response)
}
