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
    public var moviesQuery: AnyPublisher<MovieQuery, Never> { _moviesQuery.eraseToAnyPublisher() }
    
    public func queryMovies(page: Int, genres: String) {
        moviesApi.requestMoviesWithQuery(page: page, genres: genres)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?._errors.send(error)
                }
            },
            receiveValue: { [weak self] queryResult in
                self?._moviesQuery.send(queryResult)
            })
            .store(in: &subscriptions)
    }
    
    public func filteredItems(genres: [Genre], searchText: String?) -> [Genre] {
        guard let searchText = searchText, !searchText.isEmpty else {
            return genres
        }
        
        return genres.filter { genre in
            genre.name.lowercased().contains(searchText.lowercased())
        }
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
        
        requestGenres()
    }
    
    /// Dependencies
    private let moviesApi: MoviesApi
    private let coordinator: HomeCoordinator
    /// Combine
    private var subscriptions = Set<AnyCancellable>()
    private let _errors = PassthroughSubject<Error, Never>()
    private let _genres = PassthroughSubject<Genres, Never>()
    private let _moviesQuery = PassthroughSubject<MovieQuery, Never>()
}

// MARK: - Private methods

private extension HomeViewModel {
    func requestGenres() {
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
    
    func showAlert(with title: String, message: String) -> AnyPublisher<Void, Never> {
        return coordinator.showAlert(title: title, message: message)
    }
}
