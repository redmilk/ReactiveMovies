//
//  BaseRequest.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 11.04.2021.
//

import Combine
import Foundation

struct NetworkingError: Error {
    let errorCode: Int
    
    static let unknown = NetworkingError(errorCode: 9999)
}


class BaseRequest {
    func request<D: Decodable>(with request: URLRequest, type: D.Type) -> AnyPublisher<D, Error> {
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: type.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
