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
    
    private let httpClient: HTTPClientType
    
    init(httpClient: HTTPClientType) {
        self.httpClient = httpClient
    }
    
    func requestMachineTypes(token: String) -> AnyPublisher<MachineTypes, Error> {
        let headers = RequestHeaderAdapter(headers: [("Authorization", "Bearer \(token)")])
        var requestBuilder = RequestBuilder(
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
        var requestBuilder = RequestBuilder(
            baseUrl: Endpoints.baseUrl,
            pathComponent: Endpoints.refreshToken,
            adapters: [headers, parameters],
            method: .put
        )
        return URLSession.shared
            .dataTaskPublisher(for: requestBuilder.request)
            .tryMap { data, response in
                guard let _ = response as? HTTPURLResponse else { throw RequestError.nilResponse(requestBuilder.request) }
                return data
            }
            .decode(type: TokenRefresh.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
