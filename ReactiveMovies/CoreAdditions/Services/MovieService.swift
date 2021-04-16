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
    
    func requestGenres() -> AnyPublisher<Genres, Error> {
        return moviesApi
            .requestMoviesGenres()
            .eraseToAnyPublisher()
//            .sink(receiveCompletion: { [weak self] completion in
//                if case .failure(let error) = completion {
//                    self?.errors.send(error)
//                }
//            },
//            receiveValue: { [weak self] genres in
//                let wrapedGenres = genres.dataSourceWrapper
//                self?.genres.value.append(contentsOf: wrapedGenres)
//            })
//            .store(in: &subscriptions)
    }
    
    func queryMovies(page: Int, genres: String? = nil) -> AnyPublisher<MovieQuery, Error> {
        return moviesApi
            .requestMoviesWithQuery(page: page, genres: genres)
            .eraseToAnyPublisher()
//            .sink(receiveCompletion: { [unowned self] completion in
//                if case .failure(let error) = completion {
//                    self.errors.send(error)
//                }
//            },
//            receiveValue: { [weak self] movies in
//                let wrapedMovies = movies.dataSourceWrapper
//                self.movies.value.append(contentsOf: wrapedMovies)
//            })
//            .store(in: &subscriptions)
    }
    
    func filteredMovies(_ movies: [MovieQueryElement], searchText: String?) -> [MovieQueryElement] {
        guard let searchText = searchText, !searchText.isEmpty else {
            return movies
        }
        return movies.filter { item in
            item.title!.lowercased().contains(searchText.lowercased())
        }
    }
    
}
