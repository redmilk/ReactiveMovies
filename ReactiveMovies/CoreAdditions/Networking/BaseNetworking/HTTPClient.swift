//
//  BaseRequest.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 11.04.2021.
//

import Combine
import Foundation
import UIKit

protocol HTTPClientType {
    func request<D: Decodable>(with request: URLRequest) -> AnyPublisher<D, Error>
}

protocol HTTPClientNoAuthRequestable {
    func performRequest<D: Decodable>(with urlRequest: URLRequest) -> AnyPublisher<D, Error>
}

class HTTPClient: HTTPClientType, HTTPClientNoAuthRequestable {
    
    private let urlSession: URLSession
    private lazy var authenticator: Authenticator = {
        let authApi = ClaweeAuthApi(httpClient: self)
        return Authenticator(authApi: authApi)
    }()
    
    init(session: URLSession = URLSession(configuration: .ephemeral)) {
        self.urlSession = session
    }
    
    func request<D: Decodable>(with urlRequest: URLRequest) -> AnyPublisher<D, Error> {
        authenticator
            .validToken()
            .map { urlRequest.setAuthorizationHeader(withAccessToken: $0.accessToken) }
            .flatMap({ [unowned self] in performRequest(with: $0) })
            .tryCatch({ [unowned self] error -> AnyPublisher<D, Error> in
                guard let requestError = error as? RequestError, requestError == .unauthorized else { throw error }
                return authenticator
                    .validToken(forceRefresh: true)
                    .map { urlRequest.setAuthorizationHeader(withAccessToken: $0.accessToken) }
                    .flatMap({ [unowned self] in performRequest(with: $0) })
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    func performRequest<D: Decodable>(with request: URLRequest) -> AnyPublisher<D, Error> {
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .handleEvents(receiveOutput: { formatPrint(urlString: $0.response.url?.absoluteString,
                                                       keyWord: "discover") })
            .mapError { $0 }
            .flatMap ({ data, response -> AnyPublisher<Data, Error> in
                guard let httpResponse = response as? HTTPURLResponse else { return .fail(RequestError.unknown) }
                guard  200..<300 ~= httpResponse.statusCode else {
                    return .fail(httpResponse.statusCode == 401 ? RequestError.unauthorized : RequestError.api(httpResponse.statusCode))
                }
                return Just(data).setFailureType(to: Error.self).eraseToAnyPublisher()
            })
            .decode(type: D.self, decoder: JSONDecoder())
            .mapError { error -> Error in
                switch error {
                case is DecodingError: return RequestError.parsing("Parsing failure", error)
                case is URLError: return RequestError.network("URL request error", error as! URLError)
                case is RequestError: return error
                default: return (error as NSError).code == -1001 ?
                    RequestError.timeout :
                    RequestError.unknown
                }
            }
            .eraseToAnyPublisher()
    }
}

fileprivate func formatPrint(urlString: String?, keyWord: String) {
    guard let urlString = urlString else { return }
    guard urlString.contains(keyWord) else { return }
    print("🏁🏁🏁 " + urlString)
}

