//
//  AuthorizationViewModel.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 29.04.2021.
//

import Foundation
import Combine

// TODO: - Move session logic to service

// TODO: - Make VM as custom Subscriber

// TODO: - Memory leak debug

// TODO: - Session ID save

// TODO: - Refactor MovieService

// TODO: - Catch crash, unowned everywhere

// TODO: - Catch errors from publishers

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
                case .loginDidPress:
                    coordinator.displayHomeModule(completion: nil)
                case .loginWithCredentials(let username, let password):
                    Logger.log("Action.loginWithCredentials: \(username) \(password)")
                    startLoginFlow(username: username, password: password)
                case .guestSession:
                    requestGuestSessionId()
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
            .receive(on: Scheduler.mainScheduler)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error): Logger.log(error)
                case .finished: Logger.log("requestNewSessionIdWithRequestToken", type: .subscriptionFinished)
                }
            }, receiveValue: { [unowned self] sessionId in
                Logger.log("🎉🎉🎉 GOT SESSION ID: " + sessionId, type: .token)
                sessionService.updateSessionId(sessionId)
                coordinator.displayHomeModule(completion: nil)
            })
            .store(in: &subscriptions)
    }

    private func requestNewSessionIdWithRequestToken(_ token: String) -> AnyPublisher<String, Error> {
        sessionService.requestNewSessionId(with: token)
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
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error): Logger.log(error)
                case .finished: Logger.log("requestGuestSessionId", type: .subscriptionFinished)
                }
            }, receiveValue: { [unowned self] guestSession in
                Logger.log("GUEST SESSION: " + guestSession.guestSessionId!, type: .token)
                coordinator.displayHomeModule(completion: nil)
            })
            .store(in: &subscriptions)
    }
}
