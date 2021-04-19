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



fileprivate let languageSetting = "en-US"//"ru-RU"
fileprivate let averageVoteDesc = "vote_average.desc"
fileprivate let popularityDesc = "popularity.desc"

final class MoviesApi: BaseRequest {
    private let apiKeyValue = "ed13542fcfbf6b6bd02fb2723a0495ff" /// TODO: put in keychain
    
    /// Parameters keys
    private let kLanguage = "language"
    private let kPage = "page"
    private let kGenres = "with_genres"
    private let kSortBy = "sort_by"
    private let kApiKey = "api_key"
    
    public func requestMoviesGenres() -> AnyPublisher<Genres, RequestError> {
        let params = RequestParametersAdapter(
            withBody: false,
            parameters: [
                Params(title: kApiKey, value: apiKeyValue),
                Params(title: kLanguage, value: languageSetting),
            ])
        let headers = RequestHeaderAdapter()
        let requestBuilder = RequestBuilder(baseUrl: Endpoints.baseUrl,
                                            pathComponent: Endpoints.genres,
                                            adapters: [headers, params],
                                            method: .get)
        
        return request(with: requestBuilder.request, type: Genres.self)
            .eraseToAnyPublisher()
    }
    
    /// Get movies by genre
    func requestMoviesWithQuery(
        page: Int,
        genres: String?
    ) -> AnyPublisher<MovieQuery, RequestError> {
        
        let params = RequestParametersAdapter(
            withBody: false,
            parameters: [
                Params(title: kApiKey, value: apiKeyValue),
                Params(title: kLanguage, value: languageSetting),
                Params(title: kPage, value: page.description),
                Params(title: kSortBy, value: popularityDesc),
            ])
        let headers = RequestHeaderAdapter()
        let requestBuilder = RequestBuilder(
            baseUrl: Endpoints.baseUrl,
            pathComponent: Endpoints.discover,
            adapters: [headers, params],
            method: .get
        )
        
        return request(with: requestBuilder.request, type: MovieQuery.self)
            .eraseToAnyPublisher()
    }
    
    /// Get details of movie with id
    func requestMovieDetails(
        movieId: Int
    ) -> AnyPublisher<Movie, RequestError> {
        
        let params = RequestParametersAdapter(
            withBody: false,
            parameters: [
                Params(title: kApiKey, value: apiKeyValue),
                Params(title: kLanguage, value: languageSetting),
            ])
        let headers = RequestHeaderAdapter()
        let requestBuilder = RequestBuilder(
            baseUrl: Endpoints.baseUrl,
            pathComponent: Endpoints.movieDetails + movieId.description,
            adapters: [headers, params],
            method: .get
        )
        
        return request(with: requestBuilder.request, type: Movie.self)
        .eraseToAnyPublisher()
    }
    
}
