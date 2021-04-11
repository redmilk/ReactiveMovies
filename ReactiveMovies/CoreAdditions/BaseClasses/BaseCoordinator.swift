//
//  BaseCoordinator.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 11.04.2021.
//

import Foundation
import UIKit
import Combine

class BaseCoordinator {
    
    weak var viewController: UIViewController!
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func showAlert(title: String, message: String) -> AnyPublisher<Void, Never> {
        return viewController.alert(title: title, text: message)
    }
    
}
