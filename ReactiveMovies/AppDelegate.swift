//
//  AppDelegate.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 11.04.2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var flowCoordinator: ApplicationFlowCoordinator!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow()
        flowCoordinator = ApplicationFlowCoordinator(window: window!, sceneBuilder: ApplicationSceneBuilder())
        flowCoordinator.start()
        
        return true
    }

}

