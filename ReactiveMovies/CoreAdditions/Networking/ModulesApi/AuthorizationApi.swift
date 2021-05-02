//
//  MoviesAuthorizationApi.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 01.05.2021.
//

import Combine
import Foundation

/// Request parameter keys
fileprivate enum Keys {
    static let apiKey = "api_key"
    static let requestToken = "request_token"
    static let username = "username"
    static let password = "password"
}
/// Request parameter values
fileprivate enum Values {
    static var apiKey: String { Constants.apiKey }
}
/// Request endpoints
fileprivate enum Endpoints {
    static let requestToken = "/authentication/token/new"
    static let newSession = "/authentication/session/new"
    static let guestSession = "/authentication/guest_session/new"
    static let credentialsLogin = "/authentication/token/validate_with_login"
    static var baseUrl: URL { Constants.baseUrl }
}

// MARK: - AuthorizationApi Protocol

protocol AuthorizationApiType {
    func getRequestToken() -> AnyPublisher<GetRequestToken, Error>
    func getRequestTokenWithCredentials(requestToken: String, userName: String, password: String) -> AnyPublisher<GetRequestToken, Error>
    func requestNewSessionId(with requestToken: String) -> AnyPublisher<GetSessionId, Error>
    func requestGuestSessionId() -> AnyPublisher<GetGuestSessionId, Error>
}

// MARK: - AuthorizationApi

struct AuthorizationApi: AuthorizationApiType {
    private let httpClient: HTTPClientType
    
    init(httpClient: HTTPClientType) {
        self.httpClient = httpClient
    }
    
    func getRequestToken() -> AnyPublisher<GetRequestToken, Error> {
        let params = RequestParametersAdapter(
            isBodyMain: false,
            parameters: [
                Param(Keys.apiKey, Values.apiKey),
            ])
        let headers = RequestHeaderAdapter()
        let requestBuilder = RequestBuilder(
            baseUrl: Endpoints.baseUrl,
            pathComponent: Endpoints.requestToken,
            adapters: [headers, params],
            method: .get
        )
        Logger.log(requestBuilder.request.url?.absoluteString, type: .requests)
        return httpClient
            .request(with: requestBuilder.request)
            .eraseToAnyPublisher()
    }
    
    func getRequestTokenWithCredentials(requestToken: String,
                                        userName: String,
                                        password: String
    ) -> AnyPublisher<GetRequestToken, Error> {
        let params = RequestParametersAdapter(
            isBodyMain: true,
            parameters: [Param(Keys.requestToken, requestToken),
                         Param(Keys.username, userName),
                         Param(Keys.password, password)],
            extraQuery: [Param(Keys.apiKey, Values.apiKey)]
        )
        let headers = RequestHeaderAdapter()
        let requestBuilder = RequestBuilder(
            baseUrl: Endpoints.baseUrl,
            pathComponent: Endpoints.credentialsLogin,
            adapters: [headers, params],
            method: .post
        )
        Logger.log(requestBuilder.request.url?.absoluteString, type: .requests)
        return httpClient
            .request(with: requestBuilder.request)
            .eraseToAnyPublisher()
    }
    
    func requestNewSessionId(with requestToken: String) -> AnyPublisher<GetSessionId, Error> {
        let params = RequestParametersAdapter(
            isBodyMain: true,
            parameters: [Param(Keys.requestToken, requestToken)],
            extraQuery: [Param(Keys.apiKey, Values.apiKey)]
        )
        let headers = RequestHeaderAdapter()
        let requestBuilder = RequestBuilder(
            baseUrl: Endpoints.baseUrl,
            pathComponent: Endpoints.newSession,
            adapters: [headers, params],
            method: .post
        )
        Logger.log(requestBuilder.request.url?.absoluteString, type: .requests)
        return httpClient
            .request(with: requestBuilder.request)
            .eraseToAnyPublisher()
    }
    
    func requestGuestSessionId() -> AnyPublisher<GetGuestSessionId, Error> {
        let params = RequestParametersAdapter(
            isBodyMain: false,
            parameters: [Param(Keys.apiKey, Values.apiKey)]
        )
        let headers = RequestHeaderAdapter()
        let requestBuilder = RequestBuilder(
            baseUrl: Endpoints.baseUrl,
            pathComponent: Endpoints.guestSession,
            adapters: [headers, params],
            method: .get
        )
        Logger.log(requestBuilder.request.url?.absoluteString, type: .requests)
        return httpClient
            .request(with: requestBuilder.request)
            .eraseToAnyPublisher()
    }
}




