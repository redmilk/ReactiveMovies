//
//  AuthorizationCoordinator.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 29.04.2021.
//

import UIKit

final class AuthorizationCoordinator: CoordinatorProtocol {
    private let moduleTitle: String
    unowned let window: UIWindow
    
    init(window: UIWindow, moduleTitle: String) {
        self.window = window
        self.moduleTitle = moduleTitle
    }
    
    func start() {
        let auth = AuthorizationBuilder.buildAuthorizationController(coordinator: self, moduleTitle: moduleTitle)
        window.rootViewController = auth
        window.makeKeyAndVisible()
    }
    
    func end() { }
        
    func displayHomeModule(completion: (() -> Void)?) {
        let homeCoordinator = HomeCoordinator(viewController: window.rootViewController!, homeModuleTitle: "Home movies")
        homeCoordinator.start()
    }
}
