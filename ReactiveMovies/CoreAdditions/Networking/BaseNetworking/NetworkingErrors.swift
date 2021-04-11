//
//  ApplicationErrors.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 11.04.2021.
//

import Foundation

struct NetworkingError: Error {
    let errorCode: Int
    
    static let unknown = NetworkingError(errorCode: 9999)
}
