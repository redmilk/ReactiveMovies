//
//  AuthorizationCoordinator.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 29.04.2021.
//

import UIKit

final class AuthorizationCoordinator: CoordinatorType {
    private let window: UIWindow
    private let sceneBuilder: ApplicationSceneBuilder
    private let moduleTitle: String

    init(window: UIWindow,
         sceneBuilder: ApplicationSceneBuilder,
         moduleTitle: String
    ) {
        self.window = window
        self.sceneBuilder = sceneBuilder
        self.moduleTitle = moduleTitle
    }
    
    func start() {
        let auth = sceneBuilder.buildAuthorizationNavigationController(
            coordinator: self,
            moduleTitle: moduleTitle
        )
        window.rootViewController = auth
        window.makeKeyAndVisible()
    }
    
    func displayHomeModule(completion: (() -> Void)?) {
        let homeCoordinator = HomeCoordinator(
            viewController: window.rootViewController!,
            sceneBuilder: sceneBuilder,
            homeModuleTitle: "Home Movies",
            detailModuleTitle: "Details"
        )
        homeCoordinator.start()
    }
}
