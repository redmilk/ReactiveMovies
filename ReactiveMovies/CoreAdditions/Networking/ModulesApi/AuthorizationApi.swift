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
}
/// Request parameter values
fileprivate enum Values {
    static var apiKey: String { Constants.apiKey }
}
/// Request endpoints
fileprivate enum Endpoints {
    static let requestToken = "/authentication/token/new"
    static var baseUrl: URL { Constants.baseUrl }
}

// MARK: - AuthorizationApi Protocol

protocol AuthorizationApiType {
    func getRequestToken() -> AnyPublisher<GetRequestToken, Error>
}

// MARK: - AuthorizationApi

struct AuthorizationApi: AuthorizationApiType {
    private let httpClient: HTTPClientType
    
    init(httpClient: HTTPClientType) {
        self.httpClient = httpClient
    }
    
    func getRequestToken() -> AnyPublisher<GetRequestToken, Error> {
        let params = RequestParametersAdapter(
            withBody: false,
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
        return httpClient
            .request(with: requestBuilder.request)
            .eraseToAnyPublisher()
    }
}




