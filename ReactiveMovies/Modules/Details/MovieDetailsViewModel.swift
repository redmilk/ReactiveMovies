//
//  MovieDetailsViewModel.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 16.04.2021.
//

import Foundation
import Combine

final class MoviewDetailsViewModel {
    
    var movie: AnyPublisher<Movie, Never> {
        return _movie.compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    private let initialMovie: MovieQueryElement
    private let movieService: MovieService
    private var subscriptions = Set<AnyCancellable>()
    private let _movie = CurrentValueSubject<Movie?, Never>(nil)
    private let errors = PassthroughSubject<Error, Never>()
    
    init(initialMovie: MovieQueryElement, movieService: MovieService) {
        self.initialMovie = initialMovie
        self.movieService = movieService
        
        movieService
            .requestMovieDetails(with: initialMovie.id!)
            .print()
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errors.send(error)
                }
            }, receiveValue: { movie in
                self._movie.send(movie)
            })
            .store(in: &subscriptions)
    }
    
}
