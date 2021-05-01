//
//  AuthorizationBuilder.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 29.04.2021.
//

import UIKit.UINavigationController
import UIKit.UIViewController

final class ApplicationSceneBuilder { }

// MARK: - Dependency Providers

extension ApplicationSceneBuilder: MovieServiceDependencyProvidable { }

// MARK: - Authorization

extension ApplicationSceneBuilder {
    
    func buildAuthorizationNavigationController(
        coordinator: AuthorizationCoordinator,
        moduleTitle: String
    ) -> UINavigationController {
        
        let navigation = UINavigationController()
        navigation.setNavigationBarHidden(true, animated: false)
        let viewModel = AuthorizationViewModel(moduleTitle: moduleTitle, coordinator: coordinator)
        var controller = AuthorizationViewController(viewModel: viewModel)
        controller.bindViewModel(to: viewModel)
        navigation.pushViewController(controller, animated: false)
        return navigation
    }
}

// MARK: - Home

extension ApplicationSceneBuilder {
    
    func buildHomeModuleNavigationController(
        coordinator: HomeCoordinator
    ) -> UINavigationController {
        
        let viewModel = HomeViewModel(coordinator: coordinator, movieService: movieService)
        let controller = HomeViewController(viewModel: viewModel)
        let navigation = UINavigationController(rootViewController: controller)
        return navigation
    }
}

// MARK: - Detail

extension ApplicationSceneBuilder {
    
    func buildMovieDetailsViewController(
        coordinator: MovieDetailsCoordinator
    ) -> UIViewController {
        
        let detailVC = MovieDetailsViewController(nibName: "MovieDetailsViewController", bundle: nil)
        let viewModel = MoviewDetailsViewModel(movieService: movieService, coordinator: coordinator)
        detailVC.viewModel = viewModel
        return detailVC
    }
}
