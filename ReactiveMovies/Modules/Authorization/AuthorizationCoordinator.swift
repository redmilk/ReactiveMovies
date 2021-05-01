//
//  AuthorizationCoordinator.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 29.04.2021.
//

import UIKit

final class AuthorizationCoordinator: CoordinatorProtocol {
    private let moduleTitle: String
    private let moduleBuilder: ApplicationModulesBuilder
    unowned let window: UIWindow
    
    init(window: UIWindow,
         moduleBuilder: ApplicationModulesBuilder = ApplicationModulesBuilder(),
         moduleTitle: String
    ) {
        self.window = window
        self.moduleTitle = moduleTitle
        self.moduleBuilder = moduleBuilder
    }
    
    func start() {
        let auth = moduleBuilder.buildAuthorizationNavigationController(coordinator: self, moduleTitle: moduleTitle)
        window.rootViewController = auth
        window.makeKeyAndVisible()
    }
    
    func end() { }
        
    func displayHomeModule(completion: (() -> Void)?) {
        let homeCoordinator = HomeCoordinator(viewController: window.rootViewController!, homeModuleTitle: "Home movies")
        homeCoordinator.start()
    }
}
