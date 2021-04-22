//
//  BaseRequest.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 11.04.2021.
//

import Combine
import Foundation
import UIKit

class NetworkService {
    static let shared = NetworkService()
    private let cache = ImageCacher()
    private let session = URLSession(configuration: .ephemeral)

    func request<D: Decodable>(with request: URLRequest) -> AnyPublisher<D, Error> {
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .handleEvents(receiveOutput: { formatPrint(urlString: $0.response.url?.absoluteString, keyWord: "discover") })
            .mapError { _ in RequestError.invalidRequest }
            .flatMap { data, response -> AnyPublisher<Data, Error> in
                guard let response = response as? HTTPURLResponse else {
                    return Fail(error: RequestError.invalidResponse)
                        .eraseToAnyPublisher()
                }
                guard 200..<300 ~= response.statusCode else {
                    let error = RequestError.dataLoadingError(statusCode: response.statusCode, data: data)
                    return Fail(error: error)
                        .eraseToAnyPublisher()
                }
                return Just(data)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .decode(type: D.self, decoder: JSONDecoder())
            .mapError({ error -> Error in
                switch error {
                case is DecodingError: return RequestError.parsing(message: "Parsing failure", error: error)
                case is URLError: return RequestError.network(message: "Network error", error: error as! URLError)
                default:
                    if (error as NSError).code == -1001 {
                        return RequestError.timeout(description: "Request time out")
                    }
                    return error
                }
            })
            .eraseToAnyPublisher()
    }
    
    func loadImage(from url: URL) -> AnyPublisher<UIImage?, Never> {
        if let image = cache[url] {
            return Just(image).eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { data, response in UIImage(data: data) }
            .catch { _ in Just(nil) }
            .handleEvents(receiveOutput: { [unowned self] image in
                guard let image = image else { return }
                cache[url] = image
            })
            .eraseToAnyPublisher()
    }
}

fileprivate func formatPrint(urlString: String?, keyWord: String) {
    guard let urlString = urlString else { return }
    guard urlString.contains(keyWord) else { return }
    print("🏁🏁🏁 " + urlString)
}
   
