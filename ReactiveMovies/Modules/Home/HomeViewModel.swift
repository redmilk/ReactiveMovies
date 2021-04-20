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
    
    lazy var hideNavigationBar: AnyPublisher<Bool, Never> = {
        _hideNavigationBar
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }()
    
    lazy var updateScrollPosition: AnyPublisher<IndexPath, Never> = {
        $currentScroll
            .combineLatest(updateScrollPositionTrigger)
            .map { $0.0 }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }()
    
    lazy var genres: AnyPublisher<[MoviesListCollectionDataType], Never> = {
        movieService.$genres
            .map { MoviesCollectionDataAdapter.adaptGenres($0) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }()
    
    var movies: AnyPublisher<[MoviesListCollectionDataType], Never> {
        movieService.$moviesFiltered
            .map { MoviesCollectionDataAdapter.adaptMovies($0) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Input from Home VC
    
    @Published var searchText: String = ""
    @Published var currentScroll = IndexPath(row: 0, section: 0)
    @Published var selectedGenreIndex: Int = 0
    @Published var selectedMovieIndex: Int?

    private var errors: AnyPublisher<RequestError, Never> {
        movieService.errors
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    private var subscriptions = Set<AnyCancellable>()
    private let coordinator: HomeCoordinator
    private let movieService: MovieService
    private let _hideNavigationBar = PassthroughSubject<Bool, Never>()
    private let updateScrollPositionTrigger = PassthroughSubject<(), Never>()
    
    init(coordinator: HomeCoordinator, movieService: MovieService) {
        self.coordinator = coordinator
        self.movieService = movieService
        
        /// hiding nav bar
        $currentScroll
            .filter { [unowned self] _ in searchText.isEmpty }
            .map { $0.section == HomeViewController.Section.movie.rawValue && $0.row > 10 || movieService.selectedGenreIndex != 0 }
            .removeDuplicates()
            .sink(receiveValue: { [weak self] in self?._hideNavigationBar.send($0) })
            .store(in: &subscriptions)
        
        /// displaying error alert
        errors.receive(on: DispatchQueue.main)
            .flatMap ({ (error: RequestError) -> AnyPublisher<Void, Never> in
                coordinator.showAlert(title: "Ooops", message: error.errorDescription)
            })
            .sink(receiveValue: { error in
                print(error)
            })
            .store(in: &subscriptions)
        
        /// update scroll position after detail
        movieService.$selectedMovieIndex
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .map { _ in }
            .eraseToAnyPublisher()
            .subscribe(updateScrollPositionTrigger)
            .store(in: &subscriptions)
        
        bindOutputToMovieService()
        movieService.fetchGenres()
        movieService.fetchMovies()
    }
    
    private func bindOutputToMovieService() {
        $selectedGenreIndex
            .assign(to: \.selectedGenreIndex, on: movieService)
            .store(in: &subscriptions)
        
        $selectedMovieIndex.compactMap{ $0 }
            .assign(to: \.selectedMovieIndex, on: movieService)
            .store(in: &subscriptions)
        
        $currentScroll.filter { $0.section >= 0 && $0.row >= 0 }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .assign(to: \.currentScroll, on: movieService)
            .store(in: &subscriptions)
        
        $searchText.removeDuplicates()
            .assign(to: \.searchText, on: movieService)
            .store(in: &subscriptions)
        
        $selectedMovieIndex.compactMap { $0 }
            .assign(to: \.selectedMovieIndex, on: movieService)
            .store(in: &subscriptions)
        
        $selectedMovieIndex
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .print("dsfasdfsdf")
            .sink(receiveValue: { [weak self] _ in
                self?.coordinator.openMovieDetails()
            })
            .store(in: &subscriptions)
    }
}
