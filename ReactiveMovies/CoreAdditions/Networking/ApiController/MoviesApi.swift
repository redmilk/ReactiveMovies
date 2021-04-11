//
//  MoviesApi.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 11.04.2021.
//

import Foundation
import Combine

fileprivate let language = "en-US"

fileprivate struct Endpoints {
    static let baseUrlString = "https://api.themoviedb.org/3/"
    static let genres = "genre/movie/list"
}

final class MoviesApi: BaseRequest {
    
    public func requestMoviesGenres() -> AnyPublisher<Genres, Error> {
        let params = RequestParametersAdapter(withBody: false,
                                              parameters: [("api_key", Constants.apiKey),
                                                           ("language", language)])
        let headers = RequestHeaderAdapter()
        let requestBuilder = RequestBuilder(baseUrl: baseUrl,
                                            pathComponent: Endpoints.genres,
                                            adapters: [headers, params],
                                            method: .get)
        
        return request(with: requestBuilder.request, type: Genres.self)
            .eraseToAnyPublisher()
    }
    
}

// MARK: - Private

private extension MoviesApi {
    var baseUrl: URL {
        return URL(string: Endpoints.baseUrlString)!
    }
}
