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
    
    // MARK: - Output for VC
    @Published var movies: ([MovieDetailsCollectionData], Int)?
    @Published var movieDetails: MovieDetailsCollectionData?

    // MARK: - Input from VC
    @Published var selectedScroll: IndexPath?
    
    // MARK: - Required dependencies
    private let initialMovies: [MovieQueryElement]
    private let initialMovieIndexForDisplayDetail: Int
    private let movieService: MovieService
    
    // MARK: - Combine
    private let errors = PassthroughSubject<Error, Never>()
    private var subscriptions = Set<AnyCancellable>()
    @Published private var indexMovieRequiredExtraInfo: Int?
    
    init(initialMovie: [MovieQueryElement], initialIndex: Int, movieService: MovieService) {
        self.initialMovies = initialMovie
        self.movieService = movieService
        self.initialMovieIndexForDisplayDetail = initialIndex
        
        movies = (initialMovie.wrapped, initialIndex)
        
        $selectedScroll
            .compactMap { $0?.row }
            .removeDuplicates()
            .print("👁‍🗨👁‍🗨👁‍🗨", to: DebugOutputStreamLogger())
            .compactMap { [unowned self] in self.movies?.0[$0].movieQuery?.id }
            .setFailureType(to: RequestError.self)
            .flatMap ({ index -> AnyPublisher<Movie, RequestError> in
                self.movieService.requestMovieDetailsWithMovieId(index)
            })
            .sink(receiveCompletion: { [unowned self] completion in
                if case .failure(let error) = completion {
                    self.errors.send(error)
                }
            }, receiveValue: { [unowned self] movie in
                self.movies?.0[selectedScroll!.row].movie = movie
                let updated = self.movies?.0[selectedScroll!.row]
                self.movieDetails = updated
            })
            .store(in: &subscriptions)
        
    }
    
}
