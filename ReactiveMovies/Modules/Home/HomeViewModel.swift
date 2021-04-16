//
//  ViewModel.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 11.04.2021.
//

import Foundation
import Combine

class HomeViewModel {
    
    var errors: AnyPublisher<Error, Never> { _errors.eraseToAnyPublisher() }
    let genres = CurrentValueSubject<[HomeCollectionDataType], Never>([])
    let movies = CurrentValueSubject<[HomeCollectionDataType], Never>([])
        
    func filteredMovies(searchText: String?) -> [HomeCollectionDataType] {
        guard let searchText = searchText, !searchText.isEmpty else {
            return movies.value
        }
        
        return movies.value.filter { item in
            switch item {
            case .genre(let genre): fatalError()
                //return genre.name.lowercased().contains(searchText.lowercased())
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
        queryMovies(page: 1)
        
        
    }
    
    /// Dependencies
    private let moviesApi: MoviesApi
    private let coordinator: HomeCoordinator
    
    /// Combine
    private var subscriptions = Set<AnyCancellable>()
    private let _errors = PassthroughSubject<Error, Never>()
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
                let wrapedGenres = genres.dataSourceWrapper
                self?.genres.value.append(contentsOf: wrapedGenres)
            })
            .store(in: &subscriptions)
    }
    
    func queryMovies(page: Int, genres: String? = nil) {
        moviesApi.requestMoviesWithQuery(page: page, genres: genres)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?._errors.send(error)
                }
            },
            receiveValue: { [weak self] movies in
                let wrapedMovies = movies.dataSourceWrapper
                self?.movies.value.append(contentsOf: wrapedMovies)
            })
            .store(in: &subscriptions)
    }
    
    func showAlert(with title: String, message: String) -> AnyPublisher<Void, Never> {
        return coordinator.showAlert(title: title, message: message)
    }
}
