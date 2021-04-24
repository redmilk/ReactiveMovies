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
            .handleEvents(receiveOutput: { formatPrint(urlString: $0.response.url?.absoluteString,
                                                       keyWord: "discover") })
            .mapError { $0 }
            .flatMap ({ data, response -> AnyPublisher<Data, Error> in
                guard let httpResponse = response as? HTTPURLResponse else {
                    return .fail(RequestError.unknown)
                }
                guard  200..<300 ~= httpResponse.statusCode else {
                    return .fail(httpResponse.statusCode == 401 ?
                                    RequestError.unauthorized :
                                    RequestError.api(httpResponse.statusCode))
                }
                return Just(data).setFailureType(to: Error.self).eraseToAnyPublisher()
            })
            .decode(type: D.self, decoder: JSONDecoder())
            .mapError { error -> Error in
                switch error {
                case is DecodingError: return RequestError.parsing("Parsing failure", error)
                case is URLError: return RequestError.network("URL request error", error as! URLError)
                case is RequestError: return error
                default: return (error as NSError).code == -1001 ?
                    RequestError.timeout :
                    RequestError.unknown
                }
            }
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

