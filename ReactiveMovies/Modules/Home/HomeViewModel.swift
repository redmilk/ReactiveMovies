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
    public var collectionData: AnyPublisher<[HomeCollectionDataType], Never> {
        return _collectionData.eraseToAnyPublisher()
    }
        
    public func filteredItems(items: [HomeCollectionDataType], searchText: String?) -> [HomeCollectionDataType] {
        guard let searchText = searchText, !searchText.isEmpty else {
            return items
        }
        
        return items.filter { item in
            switch item {
            case .genre(let genre):
                return genre.name.lowercased().contains(searchText.lowercased())
            case .movie(let movie):
                return movie.title!.lowercased().contains(searchText.lowercased())
            }
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
        queryMovies()
    }
    
    /// Dependencies
    private let moviesApi: MoviesApi
    private let coordinator: HomeCoordinator
    /// Combine
    private var subscriptions = Set<AnyCancellable>()
    private let _errors = PassthroughSubject<Error, Never>()
    private let _collectionData = PassthroughSubject<[HomeCollectionDataType], Never>()
}

// MARK: - Private methods

private extension HomeViewModel {
    func requestGenres() {
        moviesApi
            .requestMoviesGenres()
            .map { $0.dataSourceWrapper }
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?._errors.send(error)
                }
            },
            receiveValue: { [weak self] genres in
                self?._collectionData.send(genres)
            })
            .store(in: &subscriptions)
    }
    
    func queryMovies(page: Int = 1, genres: String? = nil) {
        moviesApi.requestMoviesWithQuery(page: page, genres: genres)
            .map { $0.dataSourceWrapper }
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?._errors.send(error)
                }
            },
            receiveValue: { [weak self] queryResult in
                self?._collectionData.send(queryResult)
            })
            .store(in: &subscriptions)
    }
    
    func showAlert(with title: String, message: String) -> AnyPublisher<Void, Never> {
        return coordinator.showAlert(title: title, message: message)
    }
}
