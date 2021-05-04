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
    
    var itemScrollIndex: IndexPath
 
    private let movieService: MovieService
    private let coordinator: MovieDetailsCoordinator

    private let errors = PassthroughSubject<RequestError, Never>()
    private var subscriptions = Set<AnyCancellable>()
    
    init(movieService: MovieService,
         coordinator: MovieDetailsCoordinator
    ) {
        self.movieService = movieService
        self.coordinator = coordinator
        self.itemScrollIndex = IndexPath(row: movieService.currentScroll.value.row, section: 0)
        
        errors
            .receive(on: DispatchQueue.main)
            .flatMap({ error in
                coordinator.showAlert(title: "Ooops", message: error.errorDescription)
            })
            .sink(receiveValue: { _ in })
            .store(in: &subscriptions)
    }
    
    func updateScrollIndex(_ index: Int) {
        //movieService.selectedMovieIndex.send(index)
        movieService.currentScroll.send(IndexPath(row: index, section: 1))
    }
}

