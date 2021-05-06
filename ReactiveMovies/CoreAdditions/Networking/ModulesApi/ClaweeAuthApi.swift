//
//  ClaweeAuthApi.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 06.05.2021.
//

import Combine
import Foundation


final class ClaweeAuthApi {
    /// Request parameter keys
    fileprivate enum Keys {
        static let email = "email"
        static let password = "password"
        static let refreshToken = "refreshToken"
    }
    /// Request parameter values
    fileprivate enum Values {
        static var email = "timofeev.danil@gmail.com"
        static var password = "12345@Abc"
    }
    /// Request endpoints
    fileprivate enum Endpoints {
        static let machineTypes = "/machine-mechanism-type"
        
        static let credentialsLogin = "/auth"
        static let refreshToken = "/auth/refresh"
        static var baseUrl: URL { URL(string: "https://us-central1-clawee-dev.cloudfunctions.net/api")! }
    }
    
    private let httpClient: HTTPClientNoAuthRequestable & HTTPClientType
    
    init(httpClient: HTTPClientNoAuthRequestable & HTTPClientType) {
        self.httpClient = httpClient
    }
    
    func requestMachineTypes(token: String) -> AnyPublisher<MachineTypes, Error> {
        let headers = RequestHeaderAdapter(headers: [("Authorization", "Bearer \(token)")])
        let requestBuilder = RequestBuilder(
            baseUrl: Endpoints.baseUrl,
            pathComponent: Endpoints.machineTypes,
            adapters: [headers],
            method: .get
        )
        return httpClient
            .request(with: requestBuilder.request)
            .eraseToAnyPublisher()
    }
    
    func refreshToken(refreshToken: String) -> AnyPublisher<TokenRefresh, Error> {
        let parameters = RequestParametersAdapter(body: [
            Param(Keys.refreshToken, refreshToken),
        ], isFormUrlEncoded: true)
        let headers = RequestHeaderAdapter(contentType: .urlEncoded)
        let requestBuilder = RequestBuilder(
            baseUrl: Endpoints.baseUrl,
            pathComponent: Endpoints.refreshToken,
            adapters: [headers, parameters],
            method: .put
        )

        let request: URLRequest = requestBuilder.request

        return httpClient
            .performRequest(with: request)
            .eraseToAnyPublisher()
    }
    
    func requestAuth(email: String = Values.email, password: String = Values.password) -> AnyPublisher<User, Error> {
        let parameters = RequestParametersAdapter(body: [
            Param(Keys.email, email),
            Param(Keys.password, password),
        ], isFormUrlEncoded: true)
        let headers = RequestHeaderAdapter(contentType: .urlEncoded)
        let requestBuilder = RequestBuilder(
            baseUrl: Endpoints.baseUrl,
            pathComponent: Endpoints.credentialsLogin,
            adapters: [headers, parameters],
            method: .put
        )

        let request: URLRequest = requestBuilder.request

        return httpClient
            .request(with: request)
            .eraseToAnyPublisher()
    }
    
}
