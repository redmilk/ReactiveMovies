//
//  MovieDetailsCoordinator.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 19.04.2021.
//

import Combine
import UIKit.UIViewController

final class MovieDetailsCoordinator: CoordinatorType {
    
    private unowned var viewController: UIViewController
    private let sceneBuilder: ApplicationSceneBuilder
    
    init(viewController: UIViewController,
         sceneBuilder: ApplicationSceneBuilder
    ) {
        self.viewController = viewController
        self.sceneBuilder = sceneBuilder
    }
    
    func start() {
        let movieDetails = sceneBuilder.buildMovieDetailsViewController(coordinator: self)
        viewController.present(movieDetails, animated: true, completion: { [weak self] in
            self?.viewController = movieDetails
        })
    }
    
    func end() {
        // TODO: provide coordinator output
    }
  
    func showAlert(title: String,
                   message: String
    ) -> AnyPublisher<Void, Never> {
        
        return viewController.alert(title: title, text: message)
    }
}
