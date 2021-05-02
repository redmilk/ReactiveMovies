//
//  AuthorizationCoordinator.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 29.04.2021.
//

import Combine
import UIKit

final class AuthorizationCoordinator: CoordinatorType {
    private let window: UIWindow
    private let sceneBuilder: ApplicationSceneBuilder
    private let moduleTitle: String

    private var controller: UIViewController {
        return window.rootViewController!
    }

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
    
    func webViewResultToken(urlString: String) -> AnyPublisher<String, Never> {  // TODO: refactor WebViewController to base class
        let url = URL(string: urlString)!
        let webViewVC = WebViewController(initialUrlString: urlString, allowedHost: url.host!)
        return webViewVC.resultPublisher
            .handleEvents(receiveSubscription: { [unowned self] _ in
                DispatchQueue.main.async {
                    controller.present(webViewVC, animated: true)
                }
            })
            .eraseToAnyPublisher()
    }
    
//    func displayWebLogin(urlString: String) {  // TODO: refactor WebViewController to base class
//        let url = URL(string: urlString)!
//        let webViewVC = WebViewController(initialUrlString: urlString, allowedHost: url.host!)
//
//        subscription = webViewVC.resultPublisher
//            .prefix(1)
//            .handleEvents(receiveCompletion: { [weak self] _ in
//                self?.subscription?.cancel()
//            })
//            .subscribe(result)
//
//        DispatchQueue.main.async {
//            self.controller.present(webViewVC, animated: true)
//        }
//    }
}
