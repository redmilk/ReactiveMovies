//
//  Authenticator.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 06.05.2021.
//

import Combine
import Foundation

extension URLRequest {
    func setAuthorizationHeader(withAccessToken: String) -> URLRequest {
        var authRequest = self
        authRequest.setValue("Bearer \(withAccessToken)", forHTTPHeaderField: "Authorization")
        return authRequest
    }
}

/**
 Handling 4 cases:
 - Valid token exists, return valid token
 - Don't have any token, user need to Sign In, throw `RequestError.signInRequired`
 - Token refreshing is in progress, share the result to other requests
 - Begin token refreshing with refresh token
 */
final class Authenticator {
    private let authApi: ClaweeAuthApi
    private let queue = DispatchQueue(label: "authenticator-token-refreshing-serial-queue")
    
    /// this publisher is shared among all calls that request a token refresh
    private var refreshPublisher: AnyPublisher<TokenRefresh, Error>?
    
    init(authApi: ClaweeAuthApi) {
        self.authApi = authApi
    }
    
    func validToken(forceRefresh: Bool = false) -> AnyPublisher<TokenRefresh, Error> {
        return queue.sync { [weak self] in
            /// we are already requesting a new token
            if let publisher = self?.refreshPublisher {
                return publisher
            }
            
            /// we don't have refresh token at all, the user should log in
            guard let refreshToken = refreshToken else {
                return Fail(error: RequestError.signInRequired)
                    .eraseToAnyPublisher()
            }
            
            /// we already have a valid token and don't want to force a refresh
            if !accessToken.accessToken.isEmpty, !forceRefresh, !accessToken.isExpired { /// check if not expired
                return Just(accessToken)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            
            /// request access token with `refreshToken`
            let publisher = authApi.refreshToken(refreshToken: refreshToken)
                .handleEvents(receiveOutput: { token in
                    accessToken = token
                }, receiveCompletion: { completion in
                    switch completion {
                    case .finished: Logger.log("authApi.refreshToken", type: .subscriptionFinished)
                    case .failure(let error): Logger.log(error.localizedDescription)
                    }
                    self?.queue.sync {
                        self?.refreshPublisher = nil
                    }
                })
                .eraseToAnyPublisher()

            self?.refreshPublisher = publisher
            return publisher
        }
    }
}
