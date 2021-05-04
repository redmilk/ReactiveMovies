//
//  ViewModel.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 11.04.2021.
//

import Foundation
import Combine

// MARK: - View Model as Publisher

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

// MARK: - HomeViewModel

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
        
        bindViewModelOutputToVC()
        bindViewControllerActionsToViewModel()
        
        movieService.fetchGenres()
        movieService.fetchMovies()
    }
}

// MARK: - Private

private extension HomeViewModel {
    func bindViewModelOutputToVC() {
        movieService.currentScroll
            .compactMap { $0.row }
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
    }
    
    func bindViewControllerActionsToViewModel() {
        inputFromVC.sink(receiveValue: { [unowned self] action in
            switch action {
            
            case .genreSelectedIndex(let index):
                movieService.selectedGenreIndex = index

            case .movieSelectedIndex(let index):
                showDetailWithMovieIndex(index)

            case .searchQuery(let query):
                movieService.searchText = query

            case .currentScroll(let indexPath, let isSearchTextEmpty):
                /// hiding nav bar
                if isSearchTextEmpty && indexPath.section == HomeMoviesSection.movie.rawValue && indexPath.row > 10 || movieService.selectedGenreIndex != 0 {
                    ///outputToVC.send(.hideNavigationBar(true))
                }
                /// update current scroll in movies service
                if indexPath.section > 0 && indexPath.row > 0 {
                    movieService.currentScroll.send(indexPath)
                }
            }
        })
        .store(in: &subscriptions)
    }
    
    func showDetailWithMovieIndex(_ index: Int) {
        coordinator.displayMovieDetails(completion: { [unowned self] in
            //movieService.selectedMovieIndex.value = index
            movieService.currentScroll.send(IndexPath(row: index, section: 1))
        })
    }
}
