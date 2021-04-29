//
//  BaseCoordinator.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 11.04.2021.
//

import Foundation
import UIKit
import Combine

protocol CoordinatorProtocol: AnyObject {
    func start()
    func end()
}

class BaseCoordinator: CoordinatorProtocol {
    
    weak var viewController: UIViewController!
    weak var navigationController: UINavigationController?
    
    init(viewController: UIViewController, navigationController: UINavigationController?) {
        self.viewController = viewController
        self.navigationController = navigationController
    }
    
    func showAlert(title: String, message: String) -> AnyPublisher<Void, Never> {
        return viewController.alert(title: title, text: message)
    }
    
    func start() {
        
    }
    
    func end() {
        
    }

}
