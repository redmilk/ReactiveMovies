//
//  AuthorizationPresenter.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 04.05.2021.
//

import Combine
import Foundation

protocol AuthorizationPresenterInput {
    var input: AnyPublisher<AuthorizationInteractor.Response, Never> { get }
}

protocol AuthorizationPresenterOutput {
    var displaySomething: AnyPublisher<AuthorizationPresenter.ViewModel, Never> { get }
}

final class AuthorizationPresenter: AuthorizationPresenterInput {
    
    struct ViewModel {
        let isLoginButtonEnabled: Bool
    }
        
    private(set) var input: AnyPublisher<AuthorizationInteractor.Response, Never>
    private let output = PassthroughSubject<ViewModel, Never>()
    private var subscriptions = Set<AnyCancellable>()
    
    init(input: AnyPublisher<AuthorizationInteractor.Response, Never>) {
        self.input = input
        
        input.sink(receiveValue: { [weak self] response in
            guard let self = self else { return }
            switch response {
            case .validationResult(let isCredentialsValid):
                let viewModel = ViewModel(isLoginButtonEnabled: isCredentialsValid)
                self.output.send(viewModel)
            case .guestSession(let guestSessionId): break
            case .authenticationSuccess(let userSessionId): break
            }
        })
        .store(in: &subscriptions)
    }
}
