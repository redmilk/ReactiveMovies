//
//  AuthorizationInteractor.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 04.05.2021.
//

import Combine
import Foundation

protocol AuthorizationInteractorInput {
    var input: AnyPublisher<AuthorizationViewController.Action, Never> { get }
}

protocol AuthorizationInteractorOutput {
    var output: AnyPublisher<AuthorizationInteractor.Response, Never> { get }
}

final class AuthorizationInteractor: AuthorizationInteractorInput {
    
    enum Response {
        case validationResult(result: Bool)
        case guestSession(guestSessionId: String)
        case authenticationSuccess(userSessionId: String)
    }
    
    private(set) var input: AnyPublisher<AuthorizationViewController.Action, Never>
    private let output = PassthroughSubject<Response, Never>()
    
    private var subscriptions = Set<AnyCancellable>()
    private let sessionService: SessionService
    
    init(input: AnyPublisher<AuthorizationViewController.Action, Never>,
         sessionService: SessionService
    ) {
        self.input = input
        self.sessionService = sessionService

        input.sink(receiveValue: { [weak self] action in
            guard let self = self else { return }
            switch action {

            case .validateCredentials(let username, let password):
                let isValid = self.validateCredentials(username: username, password: password)
                self.output.send(.validationResult(result: isValid))

            case .guestSession:
                self.requestGuestSessionId()

            case .loginWithCredentials(let username, let password):
                break
            }
        })
        .store(in: &subscriptions)
    }
    
    private func validateCredentials(username: String, password: String) -> Bool {
        return username.count > 3 && password.count > 3
    }
    
    private func requestGuestSessionId() {
        sessionService.requestGuestSessionId()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error): Logger.log(error)
                case .finished: Logger.log("requestGuestSessionId", type: .subscriptionFinished)
                }
            }, receiveValue: { [weak self] guestSession in
                guard let self = self, let guestSessionId = guestSession.guestSessionId else { return }
                Logger.log("GUEST SESSION: " + guestSessionId, type: .token)
                
                self.output.send(.guestSession(guestSessionId: guestSessionId))
                ///coordinator.displayHomeModule(completion: nil)
            })
            .store(in: &subscriptions)
    }
/*
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
 */
}
