//
//  HomeCoordinator.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 11.04.2021.
//

import Foundation
import UIKit
import Combine

final class HomeCoordinator: CoordinatorType {
    
    private unowned var navigationController: UINavigationController!
    private unowned var viewController: UIViewController
    private let sceneBuilder: ApplicationSceneBuilder
    private let homeModuleTitle: String
    private let detailModuleTitle: String
    
    init(viewController: UIViewController,
         sceneBuilder: ApplicationSceneBuilder,
         homeModuleTitle: String,
         detailModuleTitle: String
    ) {
        self.viewController = viewController
        self.sceneBuilder = sceneBuilder
        self.homeModuleTitle = homeModuleTitle
        self.detailModuleTitle = detailModuleTitle
    }
    
    func start() {
        let home = sceneBuilder.buildHomeModuleNavigationController(coordinator: self)
        navigationController = home
        home.modalPresentationStyle = .fullScreen
        viewController.present(home, animated: false, completion: { [weak self] in
            self?.viewController = home
        })
    }
    
    func displayMovieDetails(completion: @escaping () -> Void) {
        let movieDetailCoordinator = MovieDetailsCoordinator(
            viewController: viewController,
            sceneBuilder: sceneBuilder
        )
        movieDetailCoordinator.start()
    }
    
    func showAlert(title: String, message: String) -> AnyPublisher<Void, Never> {
        return viewController.alert(title: title, text: message)
    }
}
