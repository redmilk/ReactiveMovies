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
    static let apiKey = "ed13542fcfbf6b6bd02fb2723a0495ff" // TODO: put in keychain
    static let languageEn = "en-US" ///"ru-RU"
    static let languageRu = "ru-RU" ///"ru-RU"
    static let sortByAverageVoteDesc = "vote_average.desc"
    static let sortByPopularityDesc = "popularity.desc"
}
/// Request endpoints
fileprivate enum Endpoints {
    static let baseUrlString = "https://api.themoviedb.org/3" // TODO: refactor to URL and components
    static let genres = "/genre/movie/list"
    static let discover = "/discover/movie"
    static let movieDetails = "/movie/"
    static let search = "/search/movie"
    static var baseUrl: URL {
        return URL(string: Endpoints.baseUrlString)!
    }
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
    private let httpClient: HTTPClientType
    
    init(httpClient: HTTPClientType) {
        self.httpClient = httpClient
    }
    
    func searchMovies(_ query: String, page: Int?, year: String?) -> AnyPublisher<MovieQuery, Error> {
        let params = RequestParametersAdapter(
            withBody: false,
            parameters: [
                Param(Keys.apiKey, Values.apiKey),
                Param(Keys.language, Values.languageEn),
                Param(Keys.page, page?.description),
                Param(Keys.query, query),
            ])
        let headers = RequestHeaderAdapter()
        let requestBuilder = RequestBuilder(
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
            withBody: false,
            parameters: [
                Param(Keys.apiKey, Values.apiKey),
                Param(Keys.language, Values.languageEn),
            ])
        let headers = RequestHeaderAdapter()
        let requestBuilder = RequestBuilder(baseUrl: Endpoints.baseUrl,
                                            pathComponent: Endpoints.genres,
                                            adapters: [headers, params],
                                            method: .get)
        
        return httpClient
            .request(with: requestBuilder.request)
            .eraseToAnyPublisher()
    }
    
    func requestMoviesWithQuery(page: Int, genres: String?) -> AnyPublisher<MovieQuery, Error> {
        let params = RequestParametersAdapter(
            withBody: false,
            parameters: [
                Param(Keys.apiKey, Values.apiKey),
                Param(Keys.language, Values.languageEn),
                Param(Keys.page, page.description),
                Param(Keys.sortBy, Values.sortByPopularityDesc),
            ])
        let headers = RequestHeaderAdapter()
        let requestBuilder = RequestBuilder(
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
            withBody: false,
            parameters: [
                Param(Keys.apiKey, Values.apiKey),
                Param(Keys.language, Values.languageEn),
            ])
        let headers = RequestHeaderAdapter()
        let requestBuilder = RequestBuilder(
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
