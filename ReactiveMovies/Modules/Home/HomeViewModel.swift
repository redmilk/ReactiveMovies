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
    
    /// Input
    @Published var searchText: String = ""
    @Published var currentScroll: IndexPath = IndexPath()
    @Published var selectedGenreIndex: Int = 0
    
    private let coordinator: HomeCoordinator
    private let movieService: MovieService

    private var page: Int = 1
    private var movies: [HomeCollectionDataType] = []
    
    private let _filteredMovies = CurrentValueSubject<[HomeCollectionDataType], Never>([])
    private var _genres = CurrentValueSubject<[HomeCollectionDataType], Never>([])
    private let errors = PassthroughSubject<Error, Never>()
    private var subscriptions = Set<AnyCancellable>()
    
    init(coordinator: HomeCoordinator, movieService: MovieService) {
        self.coordinator = coordinator
        self.movieService = movieService
        
        handleErrors()
        requestGenres()
        requestMovies()
        handleSearchText()
        handleInfiniteScroll()
        handleGenreSelection()
    }
    
    private func requestMovies() {
        movieService.queryMovies(page: page, genres: nil)
            .map { $0.dataSourceWrapper }
            .handleEvents(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errors.send(error)
                }
            })
            .replaceError(with: [])
            .sink(receiveValue: { movies in
                self.movies += movies
                self._filteredMovies.send(self.movies)
            })
            .store(in: &subscriptions)
    }
    
    private func requestGenres() {
        movieService.requestGenres()
            .map { $0.dataSourceWrapper }
            .handleEvents(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errors.send(error)
                }
            })
            .replaceError(with: [])
            .sink(receiveValue: { [weak self] genres in
                var prependWithGenreAll = genres
                prependWithGenreAll.insert(HomeCollectionDataType.genre(Genre.allGenres), at: 0)
                self?._genres.send(prependWithGenreAll)
            })
            .store(in: &subscriptions)
    }
    
    private func handleSearchText() {
        $searchText
            .removeDuplicates()
            .map { [unowned self] searchText -> [HomeCollectionDataType] in
                let movies = self.movies.compactMap { $0.movie }
                let results = self.movieService.filteredMovies(movies, searchText: searchText)
                return results.map { HomeCollectionDataType.movie($0) }
            }
            .sink(receiveValue: { [unowned self] collectionData in
                print("collection data count: " + collectionData.count.description)
                _filteredMovies.send(collectionData)
            })
            .store(in: &subscriptions)
    }
    
    private func handleGenreSelection() {
        $selectedGenreIndex
            .filter { [unowned self] _ in self._genres.value.count > 0 }
            .sink { [unowned self] genreIndex in
                self.deselectAllGenres()
                self.selectGenreAtIndex(genreIndex)
                self.filterMoviesByGenreIndex(genreIndex)
            }
            .store(in: &subscriptions)
    }
    
    private func handleInfiniteScroll() {
        $currentScroll
            .dropFirst()
            .filter { (self._filteredMovies.value.count - 1) == $0.row && $0.section == 1 && self.searchText.isEmpty && self.selectedGenreIndex == 0 }
            .handleEvents(receiveOutput: { _ in
                self.page += 1
                self.requestMovies()
            })
            .sink { indexPath in
                print(indexPath)
                print(self._filteredMovies.value.count - 1)
            }
            .store(in: &subscriptions)
    }
    
    private func handleErrors() {
        errors
            .flatMap { [unowned self] error in
                self.showAlert(with: "Ooops", message: error.localizedDescription)
            }
            .sink(receiveValue: { _ in })
            .store(in: &subscriptions)
    }
    
    private func showAlert(with title: String, message: String) -> AnyPublisher<Void, Never> {
        return coordinator.showAlert(title: title, message: message)
    }
    
    private func deselectAllGenres() {
        let deselected = _genres.value
            .compactMap { $0.genre }
            .map { HomeCollectionDataType.genre(Genre(id: $0.id, name: $0.name, isSelected: false)) }
        _genres.send(deselected)
    }
    
    private func selectGenreAtIndex(_ index: Int) {
        var genre: Genre = self._genres.value[index].genre!
        genre.isSelected = true
        let selectedGenre = HomeCollectionDataType.genre(genre)
        self._genres.value[index] = selectedGenre
    }
    
    private func filterMoviesByGenreIndex(_ index: Int) {
        guard index != 0 else { /// ALL item index
            return self._filteredMovies.send(movies)
        }
        let movies = self.movies.compactMap { $0.movie }
        let genre = self._genres.value[index].genre
        let results = self.movieService.filteredMovies(movies, by: genre).map { HomeCollectionDataType.movie($0)}
        self._filteredMovies.send(results)
    }
}
