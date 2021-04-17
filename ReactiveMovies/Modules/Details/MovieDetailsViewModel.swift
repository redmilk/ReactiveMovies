//
//  MovieDetailsViewModel.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 16.04.2021.
//

import Foundation
import Combine

fileprivate extension Array where Element == MovieQueryElement {
    var wrapped: [MovieDetailsCollectionData] {
        return self.map { MovieDetailsCollectionData(movieQuery: $0, movie: nil) }
    }
}

final class MoviewDetailsViewModel {
    
    var movies: AnyPublisher<([MovieDetailsCollectionData], Int), Never> {
        return _movies.compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    var movieDetail: AnyPublisher<MovieDetailsCollectionData, Never> {
        return _movieDetails.compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    @Published var selectedScroll: IndexPath?
    
    private let initialMovie: [MovieQueryElement]
    private let initialIndex: Int
    private let movieService: MovieService
    
    private var subscriptions = Set<AnyCancellable>()
    private let _movies = CurrentValueSubject<([MovieDetailsCollectionData], Int)?, Never>(nil)
    private let _movieDetails = CurrentValueSubject<MovieDetailsCollectionData?, Never>(nil)
    private let errors = PassthroughSubject<Error, Never>()
    
    init(initialMovie: [MovieQueryElement], initialIndex: Int, movieService: MovieService) {
        self.initialMovie = initialMovie
        self.movieService = movieService
        self.initialIndex = initialIndex
        
        _movies.send((initialMovie.wrapped, initialIndex))
        
        $selectedScroll
            .compactMap { $0?.row }
            .removeDuplicates()
            .print("👁‍🗨👁‍🗨👁‍🗨", to: DebugOutputStreamLogger())
            .compactMap { [unowned self] in self._movies.value?.0[$0].movieQuery?.id }
            .flatMap { [unowned self] (index: Int) -> AnyPublisher<Movie, Error> in
                self.movieService.requestMovieDetails(with: index)
            }
            .eraseToAnyPublisher()
            .sink(receiveCompletion: { [unowned self] completion in
                if case .failure(let error) = completion {
                    self.errors.send(error)
                }
            }, receiveValue: { [unowned self] movie in
                self._movies.value?.0[selectedScroll!.row].movie = movie
                let updated = self._movies.value?.0[selectedScroll!.row]
                self._movieDetails.send(updated)
            })
            .store(in: &subscriptions)
        
    }
    
}
