//
//  HomeCoordinator.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 11.04.2021.
//

import Foundation
import UIKit

class HomeCoordinator: BaseCoordinator {
    
    func openMovieDetails(movie: [MovieQueryElement], initialIndex: Int) {
        let detailVC = MovieDetailsViewController(nibName: "MovieDetailsViewController", bundle: nil)
        let viewModel = MoviewDetailsViewModel(initialMovie: movie, initialIndex: initialIndex, movieService: MovieService())
        detailVC.viewModel = viewModel
        viewController.present(detailVC, animated: true, completion: nil)
        //navigationController?.pushViewController(detailVC, animated: true)
    }
    
}
