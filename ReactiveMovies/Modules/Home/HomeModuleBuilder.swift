//
//  HomeModuleBuilder.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 29.04.2021.
//

import UIKit

struct HomeModuleBuilder {
    
    static func buildHomeModule(
        coordinator: HomeCoordinator,
        moduleTitle: String
    ) -> UINavigationController {
        
        let navigation = UINavigationController()
        
        let viewModel = HomeViewModel(coordinator: coordinator, movieService: MovieService.shared)
        let controller = HomeViewController(viewModel: viewModel)
        
        navigation.pushViewController(controller, animated: false)
        return navigation
    }
}
