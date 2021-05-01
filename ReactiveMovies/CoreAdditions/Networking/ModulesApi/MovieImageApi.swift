//
//  MovieImageApi.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 01.05.2021.
//

import Combine
import UIKit.UIImage

fileprivate enum ImageEndpointURL {
    static let small = URL(string: "https://image.tmdb.org/t/p/w154/")!
    static let large = URL(string: "https://image.tmdb.org/t/p/w500/")!
}

protocol MovieImageApiType {
    func loadImage(_ path: String, size: MovieImageApi.ImageSize) -> AnyPublisher<UIImage?, Never>
}

struct MovieImageApi: MovieImageApiType {
    enum ImageSize {
        case small
        case large
    }
    
    private let cache: ImageCacher
    
    init(cache: ImageCacher = ImageCacher()) {
        self.cache = cache
    }
    
    // MARK: - API
    
    func loadImage(
        _ path: String,
        size: ImageSize = ImageSize.large
    ) -> AnyPublisher<UIImage?, Never> {
        let imageSizeUrl = size == .large ? ImageEndpointURL.large : ImageEndpointURL.small
        let imageUrl = imageSizeUrl.appendingPathComponent(path)
        return loadImage(from: imageUrl)
            .eraseToAnyPublisher()
    }
}

// MARK: - Private

private extension MovieImageApi {
    func loadImage(from url: URL) -> AnyPublisher<UIImage?, Never> {
        if let image = cache[url] {
            return Just(image).eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { data, response in UIImage(data: data) }
            .catch { _ in Just(nil) }
            .handleEvents(receiveOutput: { /*[unowned self]*/ image in
                /*guard let image = image else { return }*/
                cache[url] = image
            })
            .eraseToAnyPublisher()
    }
}
