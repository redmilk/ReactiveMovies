//
//  ApplicationFlowCoordinator.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 29.04.2021.
//

import Foundation
import UIKit

final class ApplicationFlowCoordinator: CoordinatorType {
    private let window: UIWindow
    private let sceneBuilder: ApplicationSceneBuilder
    private var childCoordinators: [CoordinatorType] = []
    
    init(window: UIWindow, sceneBuilder: ApplicationSceneBuilder) {
        self.window = window
        self.sceneBuilder = sceneBuilder
    }
    
    func start() {
        let authStatus = false
        authStatus ? displayContent() : displayAuth()
    }
    
    private func displayContent() { }
    
    private func displayAuth() {
        let authCoordinator = AuthorizationCoordinator(
            window: window,
            sceneBuilder: sceneBuilder,
            moduleTitle: "Log in ➡️"
        )
        childCoordinators.append(authCoordinator)
        authCoordinator.start()
    }
}
