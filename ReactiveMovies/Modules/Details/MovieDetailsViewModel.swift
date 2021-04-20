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
    var movies: AnyPublisher<[MovieDetailsCollectionData], Never> {
        movieService.$moviesFiltered
            .map { MoviesDetailCollectionDataAdapter.adaptMovies($0) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    @Published var movieDetails: MovieDetailsCollectionData?
    
    lazy var scrollCollectionRowIndex: AnyPublisher<Int, Never> = {
        movieService.$selectedMovieIndex
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }()
    
    /// Dependencies
    @Published private var initialMovies: [MovieQueryElement] = []
    private let movieService: MovieService
    private let coordinator: MovieDetailsCoordinator
    /// Combine internal
    @Published private var indexMovieRequiredExtraInfo: Int?
    private let errors = PassthroughSubject<RequestError, Never>()
    private var subscriptions = Set<AnyCancellable>()
    var dissmissViewControllerSignal = PassthroughSubject<(), Never>()
    
    init(movieService: MovieService,
         coordinator: MovieDetailsCoordinator
    ) {
        self.movieService = movieService
        self.coordinator = coordinator
        
        errors
            .receive(on: DispatchQueue.main)
            .flatMap({ error in
                coordinator.showAlert(title: "Ooops", message: error.errorDescription)
            })
            .sink(receiveValue: { _ in })
            .store(in: &subscriptions)
        
        dissmissViewControllerSignal.receive(on: DispatchQueue.main)
            .sink(receiveValue: { _ in
                
            })
            
    }
    
    func updateScrollIndex(_ index: Int) {
        //movieService.selectedMovieIndex = index
    }
}
