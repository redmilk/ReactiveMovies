//
//  ImageFetcher.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 19.04.2021.
//

import Combine
import Foundation
import UIKit

final class ImageFetcher {
    
    private let cache = ImageCacher()
    private let loadingQueue = DispatchQueue(label: "image-loading-queue",
                                             qos: .userInitiated,
                                             attributes: .concurrent)
    
    func loadImage(
        from url: URL
    ) -> AnyPublisher<UIImage?, Never> {
        if let image = cache[url] {
            return Just(image).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { (data, response) -> UIImage? in return UIImage(data: data) }
            .catch { error in return Just(nil) }
            .handleEvents(receiveOutput: {[unowned self] image in
                guard let image = image else { return }
                self.cache[url] = image
            })
            .subscribe(on: loadingQueue)
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
