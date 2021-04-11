//
//  BaseRequest.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 11.04.2021.
//

import Combine
import Foundation

class BaseRequest {
    func request<D: Decodable>(with request: URLRequest, type: D.Type) -> AnyPublisher<D, Error> {
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .map(\.data)
            //.handleEvents(receiveOutput: { print(String(data: $0, encoding: .utf8)!) })
            .decode(type: type.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
