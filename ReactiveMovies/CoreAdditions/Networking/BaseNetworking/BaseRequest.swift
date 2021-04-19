//
//  BaseRequest.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 11.04.2021.
//

import Combine
import Foundation
import UIKit

class BaseRequest {
    
    static let shared = BaseRequest()
    
    private let cache = ImageCacher()
    private let loadingQueue = DispatchQueue(label: "image-loading-queue", qos: .userInitiated, attributes: .concurrent)
    
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
    
    func loadImage(
        from url: URL
    ) -> AnyPublisher<UIImage?, Never> {
        
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
            .subscribe(on: loadingQueue)
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
   
