//
//  ApplicationFlowCoordinator.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 29.04.2021.
//

import Foundation
import UIKit

final class ApplicationFlowCoordinator {
    
    private let window: UIWindow
    private let authModuleTitle: String
    
    init(window: UIWindow, authModuleTitle: String) {
        self.window = window
        self.authModuleTitle = authModuleTitle
    }
    
    func start() {
        let authStatus = false
        authStatus ? displayContent() : displayAuth()
    }
    
    private func displayContent() {}
    
    private func displayAuth() {
        let authCoordinator = AuthorizationCoordinator(window: window, moduleTitle: authModuleTitle)
        authCoordinator.start()
    }
}
