//
//  Authenticator.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 06.05.2021.
//

import Combine
import Foundation

// MARK: - Authenticator
/** Handling 4 cases:
 - Valid token exists, return valid token
 - Don't have any token, user need to Sign In, throw `RequestError.signInRequired`
 - Token refreshing is in progress, share the result to other requests
 - Begin token refreshing with refresh token */
final class Authenticator {
    /// this publisher is shared among all calls that requests a token refresh
    private var refreshPublisher: AnyPublisher<TokenRefresh?, Error>?
    private let authApi: ClaweeAuthApi
    private let queue = DispatchQueue(label: "authenticator-token-refreshing-serial-queue")
    
    init(authApi: ClaweeAuthApi) {
        self.authApi = authApi
    }
    
    func takeValidToken(
        forceRefresh: Bool,
        isAuthorizationRequred: Bool,
        shouldValidateToken: Bool
    ) -> AnyPublisher<TokenRefresh?, Error> {
        
        queue.sync { [unowned self] in
            /// whether request authorization header required
            guard isAuthorizationRequred else { return Just(nil).setFailureType(to: Error.self).eraseToAnyPublisher() }
            /// token validation isn't required, just return current token
            guard shouldValidateToken else { return Just(accessToken).setFailureType(to: Error.self).eraseToAnyPublisher() }
            /// we are already requesting a new token
            if let publisher = refreshPublisher { return publisher }
            /// we don't have refresh token at all, the user should log in
            guard let refreshToken = refreshToken, let accessT = accessToken else { return Fail(error: RequestError.signInRequired).eraseToAnyPublisher() }
            /// we already have a valid token and don't want to force a refresh
            if !accessT.accessToken.isEmpty, !forceRefresh, !accessT.isExpired {
                return Just(accessToken).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
            /// request new access token with `refreshToken`
            refreshPublisher = authApi.refreshToken(refreshToken: refreshToken)
                .map {
                    var asd: TokenRefresh?
                    asd = $0
                    return asd
                }
                .handleEvents(receiveOutput: { accessToken = $0 },
                              receiveCompletion: { _ in queue.sync { refreshPublisher = nil } })
                .eraseToAnyPublisher()
            return refreshPublisher!
        }
    }
}
