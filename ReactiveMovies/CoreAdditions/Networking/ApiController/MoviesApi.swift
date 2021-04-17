//
//  MoviesApi.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 11.04.2021.
//

import Foundation
import Combine


struct Endpoints {
    static let baseUrlString = "https://api.themoviedb.org/3"
    static let genres = "/genre/movie/list"
    static let discover = "/discover/movie"
    static let movieDetails = "/movie/"
    static let images = "https://image.tmdb.org/t/p/w500/"
    
    static var baseUrl: URL {
        return URL(string: Endpoints.baseUrlString)!
    }
}

fileprivate struct Parameters {
    static let apiKey = "api_key"
    static let language = "language"
    static let page = "page"
    static let genres = "with_genres"
    static let sortBy = "sort_by"
}

fileprivate let languageSetting = "en-US"//"ru-RU"
fileprivate let averageVoteDesc = "vote_average.desc"
fileprivate let popularityDesc = "popularity.desc"

final class MoviesApi: BaseRequest {
    
    public func requestMoviesGenres() -> AnyPublisher<Genres, Error> {
        let params = RequestParametersAdapter(withBody: false,
                                              parameters: [(Parameters.apiKey, Constants.apiKey),
                                                           (Parameters.language, languageSetting)])
        let headers = RequestHeaderAdapter()
        let requestBuilder = RequestBuilder(baseUrl: Endpoints.baseUrl,
                                            pathComponent: Endpoints.genres,
                                            adapters: [headers, params],
                                            method: .get)
        
        return request(with: requestBuilder.request, type: Genres.self)
            .eraseToAnyPublisher()
    }
    
    public func requestMoviesWithQuery(page: Int, genres: String?) -> AnyPublisher<MovieQuery, Error> {
        let params = RequestParametersAdapter(withBody: false,
                                              parameters: [(Parameters.apiKey, Constants.apiKey),
                                                           (Parameters.language, languageSetting),
                                                           (Parameters.genres, genres),
                                                           (Parameters.page, page.description),
                                                           (Parameters.sortBy, popularityDesc)])
        let headers = RequestHeaderAdapter()
        let requestBuilder = RequestBuilder(baseUrl: Endpoints.baseUrl,
                                            pathComponent: Endpoints.discover,
                                            adapters: [headers, params],
                                            method: .get)
        
        return request(with: requestBuilder.request, type: MovieQuery.self)
            .eraseToAnyPublisher()
    }
    
    public func requestMovieDetails(movieId: Int) -> AnyPublisher<Movie, Error> {
        let params = RequestParametersAdapter(withBody: false,
                                              parameters: [(Parameters.apiKey, Constants.apiKey),
                                                           (Parameters.language, languageSetting)])
        let headers = RequestHeaderAdapter()
        let requestBuilder = RequestBuilder(baseUrl: Endpoints.baseUrl,
                                            pathComponent: Endpoints.movieDetails + movieId.description,
                                            adapters: [headers, params],
                                            method: .get)
        
        return request(with: requestBuilder.request, type: Movie.self)
            .eraseToAnyPublisher()
    }
    
}
