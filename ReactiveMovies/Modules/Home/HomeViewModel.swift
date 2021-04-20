//
//  ViewModel.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 11.04.2021.
//

import Foundation
import Combine

// TODO: - Add infinite scroll in detail

class HomeViewModel {
    
    // MARK: - Output for Home VC
    
    @Published var genres: [HomeCollectionDataType] = []
    @Published var filteredMovies: [HomeCollectionDataType] = []
    @Published var hideNavigationBar: Bool = false
    var updateScrollPositionFromDetail: AnyPublisher<IndexPath, Never> {
        _updateScrollPositionFromDetail
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
   
    // MARK: - Input from Home VC
    
    @Published var searchText: String = ""
    @Published var currentScroll: IndexPath = IndexPath()
    @Published var selectedGenreIndex: Int = 0
    @Published var selectedMovieIndex: Int?
    
    // MARK: - Private
    private var selectedGenreId: Int? {
        genres[safe: selectedGenreIndex]?.genre?.id
    }
    private var page: Int = 1
    private var movies: [HomeCollectionDataType] = []
    private let errors = PassthroughSubject<RequestError, Never>()
    private let _updateScrollPositionFromDetail = PassthroughSubject<IndexPath, Never>()
    private var subscriptions = Set<AnyCancellable>()
    /// dependence
    private let coordinator: HomeCoordinator
    private let movieService: MovieService
    
    init(coordinator: HomeCoordinator, movieService: MovieService) {
        self.coordinator = coordinator
        self.movieService = movieService
        
        /// subscriptions
        handleErrors()
        requestGenres()
        requestMovies()
        handleSearchText()
        handleInfiniteScroll()
        handleGenreSelection()
        handleShowMovieDetail()
        
        /// hiding nav bar
        $currentScroll
            .dropFirst()
            .filter { [unowned self] _ in searchText.isEmpty }
            .map { [unowned self] in $0.section == HomeViewController.Section.movie.rawValue && $0.row > 10 || selectedGenreIndex != 0 }
            .removeDuplicates()
            .assign(to: \.hideNavigationBar, on: self)
            .store(in: &subscriptions)
        
        /// get value from detail screen
        coordinator
            .movieDetailsCurrentScrollItemIndex
            .compactMap { $0 }
            .compactMap { IndexPath(row: $0, section: HomeViewController.Section.movie.rawValue) }
            //.print("🟨🟨")
            .subscribe(_updateScrollPositionFromDetail)
            .store(in: &subscriptions)
        
        
        movieService.requestGenres()
            .map { $0.dataSourceWrapper }
            .handleEvents(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errors.send(error)
                }
            })
            .replaceError(with: [])
            .sink(receiveValue: { [unowned self] requestedGenres in
                genres = [HomeCollectionDataType.genre(Genre.allGenres)] + requestedGenres
            })
            .store(in: &subscriptions)
        
    }
    
    private func requestMovies() {
        movieService.queryMovies(page: page, genres: nil)
            .map { $0.dataSourceWrapper }
            .handleEvents(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errors.send(error)
                }
            })
            .sink(receiveCompletion: { [unowned self] completion in
                if case .failure(let error) = completion {
                    self.errors.send(error)
                }
            }, receiveValue: { [unowned self] requestedMovies in
                movies += requestedMovies
                //print("🟨🟨 movies total: " + movies.count.description)
                filteredMovies = movies
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
            .sink(receiveValue: { [unowned self] requestedGenres in
                genres = [HomeCollectionDataType.genre(Genre.allGenres)] + requestedGenres
            })
            .store(in: &subscriptions)
    }
    
    private func handleSearchText() {
        $searchText
            .removeDuplicates()
            .filter { _ in self.selectedGenreIndex == 0 }
            .map { [unowned self] searchText -> [HomeCollectionDataType] in
                let movies = self.movies.compactMap { $0.movie }
                let results = self.movieService.filteredMovies(movies, searchText: searchText)
                return results.map { HomeCollectionDataType.movie($0) }
            }
            .sink(receiveValue: { [unowned self] searchResults in
                //print("collection data count: " + searchResults.count.description)
                filteredMovies = searchResults
            })
            .store(in: &subscriptions)
    }
    
    private func handleGenreSelection() {
        $selectedGenreIndex
            .filter { [unowned self] _ in genres.count > 0 }
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
            .filter { [unowned self] in (filteredMovies.count - 1) == $0.row && $0.section == 1 && searchText.isEmpty && selectedGenreIndex == 0 }
            //.print("🟨")
            .handleEvents(receiveOutput: { _ in
                self.page += 1
                self.requestMovies()
            })
            .sink { [unowned self] indexPath in
                //print(indexPath)
                //print(filteredMovies.count - 1)
            }
            .store(in: &subscriptions)
    }
    
    private func handleErrors() {
        errors
            .receive(on: DispatchQueue.main)
            .flatMap ({ [unowned self] (error: RequestError) -> AnyPublisher<Void, Never> in
                coordinator.showAlert(title: "Ooops", message: error.errorDescription)
            })
            .sink(receiveValue: { error in
                
            })
            .store(in: &subscriptions)
    }
    
    private func handleShowMovieDetail() {
        $selectedMovieIndex.filter { $0 != nil }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [unowned self] index in
                coordinator.openMovieDetails(
                    movie: Just(filteredMovies.map { $0.movie }.compactMap { $0 }).setFailureType(to: Never.self).eraseToAnyPublisher(),
                    initialIndex: index!)
            })
            .store(in: &subscriptions)
    }
    
    private func deselectAllGenres() {
        let deselected = genres
            .compactMap { $0.genre }
            .map { HomeCollectionDataType.genre(Genre(id: $0.id, name: $0.name, isSelected: false)) }
        genres = deselected
    }
    
    private func selectGenreAtIndex(_ index: Int) {
        var genre: Genre = genres[index].genre!
        genre.isSelected = true
        let selectedGenre = HomeCollectionDataType.genre(genre)
        genres[index] = selectedGenre
    }
    
    private func filterMoviesByGenreIndex(_ index: Int) {
        guard index != 0 else { /// ALL item index
            return filteredMovies = movies
        }
        let allMovies = movies.compactMap { $0.movie }
        let genre = genres[index].genre
        let results = movieService
            .filteredMovies(allMovies, by: genre)
            .map { HomeCollectionDataType.movie($0) }
        
        filteredMovies = results
    }
}
