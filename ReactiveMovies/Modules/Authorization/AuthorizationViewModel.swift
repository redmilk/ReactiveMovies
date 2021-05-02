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
    private let sessionService: SessionService
    private var subscriptions = Set<AnyCancellable>()
    
    let moduleTitle: String
    let controllerActionsSubscriber = PassthroughSubject<AuthorizationViewController.Action, Never>()
    
    init(moduleTitle: String, coordinator: AuthorizationCoordinator, sessionService: SessionService) {
        self.moduleTitle = moduleTitle
        self.coordinator = coordinator
        self.sessionService = sessionService
        bindControllerActions()
        
    }
    
    private func bindControllerActions() {
        controllerActionsSubscriber
            .sink(receiveValue: { [unowned self] action in
                switch action {
                case .loginDidPress: coordinator.displayHomeModule(completion: nil)
                case .loginWithCredentials(let username, let password):
                    Logger.log("Action.loginWithCredentials: \(username) \(password)")
                    startLoginFlow(username: username, password: password)
                }
            })
            .store(in: &subscriptions)
    }
    
    private func startLoginFlow(username: String, password: String) {
        sessionService.requestRequestToken()
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveCompletion: { completion in
                switch completion {
                case .failure(let error): Logger.log(error)
                case .finished: Logger.log("requestRequestToken", type: .subscriptionFinished)
                }
            })
            .compactMap { $0.requestToken }
            .map { [unowned self] in
                var loginURL = sessionService.webLoginURL
                loginURL.appendPathComponent($0)
                Logger.log(loginURL.absoluteString)
                return loginURL.absoluteString
            }
            .flatMap({ [unowned self] urlString -> AnyPublisher<String, Error> in
                coordinator.webViewResultToken(urlString: urlString)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            })
            .flatMap({ [unowned self] token -> AnyPublisher<GetRequestToken, Error> in
                sessionService.getRequestTokenWithCredentials(requestToken: token, userName: username, password: password)
            })
            //.first()
            .handleEvents(receiveCompletion: { completion in
                switch completion {
                case .failure(let error): Logger.log(error)
                case .finished: Logger.log("startLoginFlow", type: .subscriptionFinished)
                }
            })
            .compactMap { $0.requestToken }
            .flatMap({ [unowned self] requestToken -> AnyPublisher<String, Error> in
                requestNewSessionIdWithRequestToken(requestToken)
            })
            //.first()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error): Logger.log(error)
                case .finished: Logger.log("requestNewSessionIdWithRequestToken", type: .subscriptionFinished)
                }
            }, receiveValue: { sessionId in
                Logger.log("🎉🎉🎉 GOT SESSION ID: " + sessionId, type: .token)
            })
            .store(in: &subscriptions)
        /**
         , receiveValue: { [unowned self] requestToken in
             guard requestToken.success else { return Logger.log("requestToken.success: FALSE") }
             guard let token = requestToken.requestToken else { return Logger.log("requestToken.requestToken: NIL TOKEN") }
             var loginURL = sessionService.webLoginURL
             loginURL.appendPathComponent(token)
             Logger.log(loginURL.absoluteString)
             coordinator.displayWebLogin(urlString: loginURL.absoluteString)
         }
         */
    }
    
//    private func loginWithCredentials(username: String, password: String) {
//        coordinator.resultPublisher
//            .handleEvents(receiveOutput: { [unowned self] token in
//                sessionService.updateToken(token: token)
//            })
//
//    }
    
    private func requestNewSessionIdWithRequestToken(_ token: String) -> AnyPublisher<String, Error> {
        sessionService.requestNewSessionId(with: token)
            //.prefix(1)
            .handleEvents(receiveOutput: { newSessionId in
                Logger.log("SESSION ID: " + newSessionId.sessionId!, type: .token)
            }, receiveCompletion: { completion in
                switch completion {
                case .failure(let error): Logger.log(error)
                case .finished: Logger.log("requestNewSessionIdWithRequestToken", type: .subscriptionFinished)
                }
            })
            .compactMap { $0.sessionId }
            .eraseToAnyPublisher()
    }
    
    private func requestGuestSessionId() {
        sessionService.requestGuestSessionId()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error): Logger.log(error)
                case .finished: Logger.log("requestGuestSessionId", type: .subscriptionFinished)
                }
            }, receiveValue: { guestSession in
                Logger.log("GUEST SESSION: " + guestSession.guestSessionId!, type: .token)
            })
            .store(in: &subscriptions)
    }
}
