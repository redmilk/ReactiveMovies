//
//  MovieDetailsViewModel.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 16.04.2021.
//

import Foundation
import Combine

final class MoviewDetailsViewModel {
    
    // MARK: - Output for VC
    lazy var movies: AnyPublisher<[Movie], Never> = {
        movieService.$moviesFiltered
            .receive(on: DispatchQueue.main)
            .share()
            .eraseToAnyPublisher()
    }()
    
    var itemScrollIndex: Int? {
        return movieService.currentScroll.row
    }
 
    /// Dependencies
    private let movieService: MovieService
    private let coordinator: MovieDetailsCoordinator
    /// Combine internal
    private let errors = PassthroughSubject<RequestError, Never>()
    private var subscriptions = Set<AnyCancellable>()
    //private var movieItemIndex: Int?
    
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
    }
    
    deinit {
        /// update current movie item index before dismiss
        //movieService.selectedMovieIndex = movieItemIndex
    }
    
    func updateScrollIndex(_ index: Int) {
        //movieItemIndex = index
        movieService.selectedMovieIndex = index//movieItemIndex
        movieService.currentScroll = IndexPath(row: index, section: HomeViewController.Section.movie.rawValue)
    }
}

