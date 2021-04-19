//
//  MovieService.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 16.04.2021.
//

import Foundation
import Combine

final class MovieService {
    
    private let moviesApi = MoviesApi()
    
    func requestGenres() -> AnyPublisher<Genres, RequestError> {
        return moviesApi
            .requestMoviesGenres()
            .eraseToAnyPublisher()
    }
    
    func queryMovies(page: Int, genres: String? = nil) -> AnyPublisher<MovieQuery, RequestError> {
        return moviesApi
            .requestMoviesWithQuery(page: page, genres: genres)
            .eraseToAnyPublisher()
    }
    
    func requestMovieDetailsWithMovieId(_ id: Int) -> AnyPublisher<Movie, RequestError> {
        return moviesApi
            .requestMovieDetails(movieId: id)
            .eraseToAnyPublisher()
    }
    
    func filteredMovies(_ movies: [MovieQueryElement], searchText: String?) -> [MovieQueryElement] {
        guard let searchText = searchText, !searchText.isEmpty else {
            return movies
        }
        return movies.filter { item in
            item.title!.lowercased().contains(searchText.lowercased())
        }
    }
    
    func filteredMovies(_ movies: [MovieQueryElement], by genre: Genre?) -> [MovieQueryElement] {
        guard let genre = genre else { return movies }
        return movies.filter { ($0.genreIDS ?? []).contains(genre.id) }
    }
    
}
