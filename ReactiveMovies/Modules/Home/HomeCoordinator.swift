//
//  HomeCoordinator.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 11.04.2021.
//

import Foundation
import UIKit
import Combine

final class HomeCoordinator: BaseCoordinator {
    
    // MARK: - Output to HomeVM from DetailVM
    
    var movieDetailsCurrentScrollItemIndex: AnyPublisher<Int?, Never> {
        return $_movieDetailsCurrentScrollItemIndex.eraseToAnyPublisher()
    }
    
    // MARK: - Public API
    
    func openMovieDetails(
        movie: AnyPublisher<[MovieQueryElement], Never>,
        initialIndex: Int
    ) {
        let detailVC = MovieDetailsViewController(nibName: "MovieDetailsViewController", bundle: nil)
        let detailCoordinator = MovieDetailsCoordinator(viewController: detailVC, navigationController: nil)
        let viewModel = MoviewDetailsViewModel(initialMovie: movie,
                                               initialIndex: initialIndex,
                                               movieService: MovieService(),
                                               coordinator: detailCoordinator)
        viewModel
            .$selectedScrollItemRowIndex
            .assign(to: \._movieDetailsCurrentScrollItemIndex, on: self)
            .store(in: &subscriptions)
        
        detailVC.viewModel = viewModel
        viewController.present(detailVC, animated: true, completion: nil)
    }
    
    // MARK: - Internal
    
    @Published private var _movieDetailsCurrentScrollItemIndex: Int?
    private var subscriptions = Set<AnyCancellable>()
}
