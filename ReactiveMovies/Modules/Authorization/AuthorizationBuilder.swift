//
//  AuthorizationBuilder.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 29.04.2021.
//

import UIKit

struct AuthorizationBuilder {
    
    static func buildAuthorizationController(
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
