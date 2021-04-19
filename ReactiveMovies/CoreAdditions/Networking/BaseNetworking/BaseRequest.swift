//
//  BaseRequest.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 11.04.2021.
//

import Combine
import Foundation

class BaseRequest {
    func request<D: Decodable>(
        with request: URLRequest,
        type: D.Type
    ) -> AnyPublisher<D, RequestError> {
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: type.self, decoder: JSONDecoder())
            .mapError({ (error) -> RequestError in
                switch error {
                case is DecodingError: return RequestError.parsing(description: "Parsing failure", error: error)
                case is URLError: return RequestError.network(description: "Network error", error: error as! URLError)
                default: return RequestError.unknown(error: error as NSError)
                }
            })
            .retry(1)
            .eraseToAnyPublisher()
    }
}
   
