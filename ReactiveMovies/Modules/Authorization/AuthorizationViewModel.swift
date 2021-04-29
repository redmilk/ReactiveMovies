//
//  AuthorizationViewModel.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 29.04.2021.
//

import Foundation
import Combine

final class AuthorizationViewModel {
    private let coordinator: AuthorizationCoordinator
    private var subscriptions = Set<AnyCancellable>()
    
    let moduleTitle: String
    let controllerActionsSubscriber = PassthroughSubject<AuthorizationViewController.Action, Never>()
    
    init(moduleTitle: String, coordinator: AuthorizationCoordinator) {
        self.moduleTitle = moduleTitle
        self.coordinator = coordinator

        bindControllerActions()
    }
    
    private func bindControllerActions() {
        controllerActionsSubscriber
            .sink(receiveValue: { [weak self] action in
                switch action {
                case .loginDidPress: self?.coordinator.displayHomeModule(completion: nil)
                }
            })
            .store(in: &subscriptions)
    }
}
