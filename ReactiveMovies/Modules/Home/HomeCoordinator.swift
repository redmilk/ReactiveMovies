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
    
    // MARK: - Public API
    
    func openMovieDetails() {
        
        let detailVC = MovieDetailsViewController(nibName: "MovieDetailsViewController", bundle: nil)
        let detailCoordinator = MovieDetailsCoordinator(viewController: detailVC, navigationController: nil)
        let viewModel = MoviewDetailsViewModel(movieService: MovieService.shared,
                                               coordinator: detailCoordinator)
        
        detailVC.viewModel = viewModel
        viewController.present(detailVC, animated: true, completion: nil)
    }
}
