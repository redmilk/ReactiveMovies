//
//  ViewModel.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 11.04.2021.
//

import Foundation
import Combine
/**
 
 case .searchQuery(let query):
     guard !query.isEmpty else { return }
     movieService.searchText = query
//                query.removeDuplicates()
//                    .assign(to: \.searchText, on: movieService)
//                    .store(in: &subscriptions)
     //MoviesSearchService.shared.searchMovies(query)
//                query.filter { !$0.isEmpty }
//                    .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
//                    .removeDuplicates()
//                    .sink(receiveValue: { query in
//                        //print("REQUEST WITH " + query)
//                        MoviesSearchService.shared.searchMovies(query)
//                    })
//                    .store(in: &subscriptions)
 
 enum Action {
     case hideNavigationBar(AnyPublisher<Bool, Never>)
     case updateScrollPosition(AnyPublisher<IndexPath, Never>)
     case genres(AnyPublisher<[MoviesListCollectionDataType], Never>)
     case movies(AnyPublisher<[MoviesListCollectionDataType], Never>)
 }
 
 
 // MARK: - Output for Home VC
 
//    lazy var hideNavigationBar: AnyPublisher<Bool, Never> = {
//        _hideNavigationBar
//            .receive(on: DispatchQueue.main)
//            .eraseToAnyPublisher()
//    }()
 
//    lazy var updateScrollPosition: AnyPublisher<IndexPath, Never> = {
//
//    }()
 
//    lazy var genres: AnyPublisher<[MoviesListCollectionDataType], Never> = {
//        movieService.$genres
//            .map { MoviesCollectionDataAdapter.adaptGenres($0) }
//            .receive(on: Scheduler.mainScheduler)
//            .eraseToAnyPublisher()
//    }()
 
//    var movies: AnyPublisher<[MoviesListCollectionDataType], Never> {
//        movieService.$moviesFiltered
//            .map { MoviesCollectionDataAdapter.adaptMovies($0) }
//            .receive(on: DispatchQueue.main)
//            .eraseToAnyPublisher()
//    }
 
 // MARK: - Input from Home VC
 
 //@Published var searchText: String = ""
 //@Published var currentScroll = IndexPath(row: 0, section: 0)
 //@Published var selectedGenreIndex: Int = 0
 //var selectedMovieIndex: Int?
 
 */
extension HomeViewModel: Publisher {
    typealias Output = Action
    typealias Failure = Never
    
    enum Action {
        case hideNavigationBar(Bool)
        case updateScrollPosition(IndexPath)
        case genres([MoviesListCollectionDataType])
        case movies([MoviesListCollectionDataType])
    }
    
    func receive<S>(subscriber: S)
    where S: Subscriber,
          HomeViewModel.Failure == S.Failure,
          HomeViewModel.Output == S.Input {
        
        outputToVC
            .subscribe(outputToVC)
            .store(in: &subscriptions)
    }
}

final class HomeViewModel {

    public let inputFromVC = PassthroughSubject<HomeViewController.Action, Never>()
    public let outputToVC = PassthroughSubject<Action, Never>()

    private var subscriptions = Set<AnyCancellable>()
    private let coordinator: HomeCoordinator
    private let movieService: MovieService
    
    init(coordinator: HomeCoordinator, movieService: MovieService) {
        self.coordinator = coordinator
        self.movieService = movieService
        
        movieService.errors
            .receive(on: DispatchQueue.main)
            .flatMap ({ (error: Error) -> AnyPublisher<Void, Never> in
                let errorMessage = (error as? RequestError)?.errorDescription ?? error.localizedDescription
                return coordinator.showAlert(title: "Something went wrong", message: errorMessage)
            })
            .sink(receiveValue: { _ in })
            .store(in: &subscriptions)
    }
    
    public func bindViewModelOutputToVC() {
        movieService.selectedMovieIndex
            .compactMap { $0 }
            .map { Action.updateScrollPosition(IndexPath(row: $0, section: HomeMoviesSection.movie.rawValue)) }
            .subscribe(outputToVC)
            .store(in: &subscriptions)
        
        movieService.$genres
            .map { Action.genres(MoviesCollectionDataAdapter.adaptGenres($0)) }
            .subscribe(outputToVC)
            .store(in: &subscriptions)
        
        movieService.$moviesFiltered
            .map { Action.movies(MoviesCollectionDataAdapter.adaptMovies($0)) }
            .subscribe(outputToVC)
            .store(in: &subscriptions)
        
        movieService.fetchGenres()
        movieService.fetchMovies()
    }
    
    public func bindViewControllerActionsToViewModel() {
        inputFromVC
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [unowned self] action in
            switch action {
            
            case .genreSelectedIndex(let index):
                movieService.selectedGenreIndex = index

            case .movieSelectedIndex(let index):
                showDetailWithMovieIndex(index)

            case .searchQuery(let query):
                guard !query.isEmpty else { return }
                movieService.searchText = query

            case .currentScroll(let indexPath, let isSearchTextEmpty):
                /// hiding nav bar
                Just(indexPath)
                    .filter { _ in isSearchTextEmpty }
                    .map { $0.section == HomeMoviesSection.movie.rawValue && $0.row > 20 || movieService.selectedGenreIndex != 0 }
                    .prepend(false)
                    .removeDuplicates()
                    .map { Action.hideNavigationBar($0) }
                    .eraseToAnyPublisher()
                    .subscribe(outputToVC)
                    .store(in: &subscriptions)
                
                /// update current scroll in movies service
//                Just(indexPath)
//                    .filter { $0.section >= 0 && $0.row >= 0 }
//                    .removeDuplicates()
//                    .assign(to: \.currentScroll.value, on: movieService)
//                    .store(in: &subscriptions)
                if indexPath.section > 0 && indexPath.row > 0 {
                    movieService.currentScroll.send(indexPath)
                }
            }
        })
        .store(in: &subscriptions)
    }
    
    public func showDetailWithMovieIndex(_ index: Int) {
        coordinator.displayMovieDetails(completion: { [unowned self] in
            //movieService.selectedMovieIndex = index
            movieService.currentScroll.send(IndexPath(row: index, section: 1))
        })
    }
}
