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
    // MARK: - Return scroll value for home VC
    @Published var selectedScrollItemRowIndex: Int?
    
    /// Dependencies
    private let initialMovies: [MovieQueryElement]
    private let initialMovieIndexForDisplayDetail: Int
    private let movieService: MovieService
    private let coordinator: MovieDetailsCoordinator
    /// Combine internal
    @Published private var indexMovieRequiredExtraInfo: Int?
    private let errors = PassthroughSubject<RequestError, Never>()
    private var subscriptions = Set<AnyCancellable>()
    
    
    init(
        initialMovie: [MovieQueryElement],
        initialIndex: Int,
        movieService: MovieService,
        coordinator: MovieDetailsCoordinator
    ) {
        self.initialMovies = initialMovie
        self.movieService = movieService
        self.initialMovieIndexForDisplayDetail = initialIndex
        self.coordinator = coordinator
        
        movies = (initialMovie.wrapped, initialIndex)
        
        $selectedScrollItemRowIndex
            .compactMap { $0 }
            .removeDuplicates()
            //.print("👁‍🗨👁‍🗨👁‍🗨", to: DebugOutputStreamLogger())
            .compactMap { [unowned self] in movies?.0[$0].movieQuery?.id }
            .setFailureType(to: RequestError.self)
            .flatMap ({ [unowned self] index -> AnyPublisher<Movie, RequestError> in
                self.movieService.requestMovieDetailsWithMovieId(index)
            })
            .sink(receiveCompletion: { [unowned self] completion in
                if case .failure(let error) = completion {
                    errors.send(error)
                }
            }, receiveValue: { [unowned self] movie in
                self.movies?.0[selectedScrollItemRowIndex!].movie = movie
                let updated = self.movies?.0[selectedScrollItemRowIndex!]
                self.movieDetails = updated
            })
            .store(in: &subscriptions)
        
        errors
            .receive(on: DispatchQueue.main)
            .flatMap({ error in
                coordinator.showAlert(title: "Ooops", message: error.errorDescription)
            })
            .sink(receiveValue: { _ in })
            .store(in: &subscriptions)
            
    }
}
