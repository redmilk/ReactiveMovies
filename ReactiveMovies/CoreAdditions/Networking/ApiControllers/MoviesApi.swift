//
//  MoviesApi.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 11.04.2021.
//

import Foundation
import Combine

/// Request parameter keys
fileprivate enum Keys {
    static let language = "language"
    static let page = "page"
    static let withGenres = "with_genres"
    static let sortBy = "sort_by"
    static let apiKey = "api_key"
    static let query = "query"
}
/// Request parameter values
fileprivate enum Values {
    static let languageEn = "en-US"
    static let languageRu = "ru-RU"
    static let sortByAverageVoteDesc = "vote_average.desc"
    static let sortByPopularityDesc = "popularity.desc"
    static var apiKey: String { Constants.apiKey }
}
/// Request endpoints
fileprivate enum Endpoints {
    static let genres = "/genre/movie/list"
    static let discover = "/discover/movie"
    static let movieDetails = "/movie/"
    static let search = "/search/movie"
    static var baseUrl: URL { Constants.baseUrl }
}

// MARK: - MoviesApi Protocol

protocol MoviesApiType {
    func searchMovies(_ query: String, page: Int?, year: String?) -> AnyPublisher<MovieQuery, Error>
    func requestMoviesGenres() -> AnyPublisher<Genres, Error>
    func requestMoviesWithQuery(page: Int, genres: String?) -> AnyPublisher<MovieQuery, Error>
    func requestMovieDetails(movieId: Int) -> AnyPublisher<Movie, Error>
}

// MARK: - MoviesApi

struct MoviesApi: MoviesApiType {
    private let httpClient: HTTPClient
    
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    func searchMovies(_ query: String,
                      page: Int?,
                      year: String?
    ) -> AnyPublisher<MovieQuery, Error> {
        let params = RequestParametersAdapter(
            query: [
                Param(Keys.apiKey, Values.apiKey),
                Param(Keys.language, Values.languageEn),
                Param(Keys.page, page?.description),
                Param(Keys.query, query),
            ])
        let headers = RequestHeaderAdapter()
        var requestBuilder = RequestBuilder(
            baseUrl: Endpoints.baseUrl,
            pathComponent: Endpoints.search,
            adapters: [headers, params],
            method: .get
        )
        return httpClient
            .request(with: requestBuilder.request)
            .eraseToAnyPublisher()
    }
    
    func requestMoviesGenres() -> AnyPublisher<Genres, Error> {
        let params = RequestParametersAdapter(
            query: [
                Param(Keys.apiKey, Values.apiKey),
                Param(Keys.language, Values.languageEn),
            ])
        let headers = RequestHeaderAdapter()
        var requestBuilder = RequestBuilder(baseUrl: Endpoints.baseUrl,
                                            pathComponent: Endpoints.genres,
                                            adapters: [headers, params],
                                            method: .get)
        
        return httpClient
            .request(with: requestBuilder.request)
            .eraseToAnyPublisher()
    }
    
    func requestMoviesWithQuery(page: Int,
                                genres: String?
    ) -> AnyPublisher<MovieQuery, Error> {
        let params = RequestParametersAdapter(
            query: [
                Param(Keys.apiKey, Values.apiKey),
                Param(Keys.language, Values.languageEn),
                Param(Keys.page, page.description),
                Param(Keys.sortBy, Values.sortByPopularityDesc),
            ])
        let headers = RequestHeaderAdapter()
        var requestBuilder = RequestBuilder(
            baseUrl: Endpoints.baseUrl,
            pathComponent: Endpoints.discover,
            adapters: [headers, params],
            method: .get
        )
        
        return httpClient
            .request(with: requestBuilder.request)
            .eraseToAnyPublisher()
    }
    
    func requestMovieDetails(movieId: Int) -> AnyPublisher<Movie, Error> {
        let params = RequestParametersAdapter(
            query: [
                Param(Keys.apiKey, Values.apiKey),
                Param(Keys.language, Values.languageEn),
            ])
        let headers = RequestHeaderAdapter()
        var requestBuilder = RequestBuilder(
            baseUrl: Endpoints.baseUrl,
            pathComponent: Endpoints.movieDetails + movieId.description,
            adapters: [headers, params],
            method: .get
        )
        
        return httpClient
            .request(with: requestBuilder.request)
            .eraseToAnyPublisher()
    }
}
