//
//  ViewModel.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 11.04.2021.
//

import Foundation
import Combine

class HomeViewModel {
    
    var genres: AnyPublisher<[HomeCollectionDataType], Never> {
        _genres
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    var filteredMovies: AnyPublisher<[HomeCollectionDataType], Never> {
        _filteredMovies
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    @Published var searchText: String = ""
    
    private let coordinator: HomeCoordinator
    private let movieService: MovieService
    private var subscriptions = Set<AnyCancellable>()
    private var page: Int = 1
    private var movies: [HomeCollectionDataType] = []
    private let _filteredMovies = CurrentValueSubject<[HomeCollectionDataType], Never>([])
    private let _genres = CurrentValueSubject<[HomeCollectionDataType], Never>([])
    private let errors = PassthroughSubject<Error, Never>()
    
    init(coordinator: HomeCoordinator, movieService: MovieService) {
        self.coordinator = coordinator
        self.movieService = movieService
        
        errors
            .flatMap { [unowned self] error in
                self.showAlert(with: "Ooops", message: error.localizedDescription)
            }
            .sink(receiveValue: { _ in })
            .store(in: &subscriptions)
        
        movieService.requestGenres()
            .map { $0.dataSourceWrapper }
            .handleEvents(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errors.send(error)
                }
            })
            .replaceError(with: [])
            .assign(to: \._genres.value, on: self)
            .store(in: &subscriptions)
        
        movieService.queryMovies(page: page, genres: nil)
            .map { $0.dataSourceWrapper }
            .handleEvents(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errors.send(error)
                }
            })
            .replaceError(with: [])
            .sink(receiveValue: { movies in
                self._filteredMovies.send(movies)
                self.movies = movies
            })
            .store(in: &subscriptions)
        
        $searchText
            .removeDuplicates()
            .map { [unowned self] searchText -> [HomeCollectionDataType] in
                let movies = self.movies.compactMap { $0.movie }
                let results = self.movieService.filteredMovies(movies, searchText: searchText)
                return results.map { HomeCollectionDataType.movie($0) }
            }
            .sink(receiveValue: { [unowned self] collectionData in
                print(collectionData.count)
                _filteredMovies.send(collectionData)
            })
            .store(in: &subscriptions)
    }
        
    private func showAlert(with title: String, message: String) -> AnyPublisher<Void, Never> {
        return coordinator.showAlert(title: title, message: message)
    }
}
