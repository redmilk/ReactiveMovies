//
//  ViewModel.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 11.04.2021.
//

import Foundation
import Combine

class HomeViewModel {
    
    public var errors: AnyPublisher<Error, Never> { _errors.eraseToAnyPublisher() }
    public var genres: AnyPublisher<Genres, Never> { _genres.eraseToAnyPublisher() }
    
    public func requestGenres() {
        moviesApi
            .requestMoviesGenres()
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?._errors.send(error)
                }
            },
            receiveValue: { [weak self] genres in
                self?._genres.send(genres)
            })
            .store(in: &subscriptions)
    }
    
    init(moviesApi: MoviesApi, coordinator: HomeCoordinator) {
        self.moviesApi = moviesApi
        self.coordinator = coordinator
        
        errors
            .flatMap { [unowned self] error in
                self.showAlert(with: "Ooops", message: error.localizedDescription)
            }
            .sink(receiveValue: { _ in })
            .store(in: &subscriptions)
    }
    
    /// Dependencies
    private let moviesApi: MoviesApi
    private let coordinator: HomeCoordinator
    /// Combine
    private var subscriptions = Set<AnyCancellable>()
    private let _errors = PassthroughSubject<Error, Never>()
    private let _genres = PassthroughSubject<Genres, Never>()
}

// MARK: - Helper methods

private extension HomeViewModel {
    func showAlert(with title: String, message: String) -> AnyPublisher<Void, Never> {
        return coordinator.showAlert(title: title, message: message)
    }
}
