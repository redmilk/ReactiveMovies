//
//  HomeCoordinator.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 11.04.2021.
//

import Foundation
import UIKit
import Combine

final class HomeCoordinator: CoordinatorProtocol {
    
    private weak var navigationController: UINavigationController?
    private unowned var viewController: UIViewController
    private let homeModuleTitle: String
    
    init(viewController: UIViewController, homeModuleTitle: String) {
        self.viewController = viewController
        self.homeModuleTitle = homeModuleTitle
    }
    
    func start() {
        let home = HomeModuleBuilder.buildHomeModule(coordinator: self, moduleTitle: homeModuleTitle)
        navigationController = home
        home.modalPresentationStyle = .fullScreen
        viewController.present(home, animated: false, completion: { [weak self] in self?.viewController = home })
    }
        
    func showAlert(title: String, message: String) -> AnyPublisher<Void, Never> {
        return viewController.alert(title: title, text: message)
    }
    
    func displayMovieDetails(completion: @escaping () -> Void) {
        let detailVC = MovieDetailsViewController(nibName: "MovieDetailsViewController", bundle: nil)
        let detailCoordinator = MovieDetailsCoordinator(viewController: detailVC, navigationController: nil)
        let viewModel = MoviewDetailsViewModel(movieService: MovieService.shared,
                                               coordinator: detailCoordinator)
        detailVC.viewModel = viewModel
        viewController.present(detailVC, animated: true, completion: completion)
    }
    
    func end() { }
}
