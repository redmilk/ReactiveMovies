//
//  BaseRequest.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 11.04.2021.
//

import Combine
import Foundation

protocol HTTPClientType {
    func request<D: Decodable>(with urlRequest: URLRequest) -> AnyPublisher<D, Error>
}

final class HTTPClient: HTTPClientType {
    private let urlSession: URLSession
    private var isAuthorizationRequired: Bool
    private lazy var authenticator: Authenticator = {
        let authApi = ClaweeAuthApi(httpClient: self)
        return Authenticator(authApi: authApi)
    }()
    
    init(session: URLSession = URLSession(configuration: .ephemeral),
         isAuthorizationRequired: Bool
    ) {
        self.urlSession = session
        self.isAuthorizationRequired = isAuthorizationRequired
    }
    
    func request<D: Decodable>(with urlRequest: URLRequest) -> AnyPublisher<D, Error> {
        performRequest(with: urlRequest)
    }
    
    private func performRequest<D: Decodable>(with urlRequest: URLRequest, shouldValidateToken: Bool = true) -> AnyPublisher<D, Error> {
        authenticator.takeValidToken(forceRefresh: false, isAuthorizationRequred: isAuthorizationRequired, shouldValidateToken: shouldValidateToken)
            .map { urlRequest.setAuthorizationHeader(withAccessToken: $0?.accessToken) }
            .flatMap({ [unowned self] urlRequest in
                urlSession.dataTaskPublisher(for: urlRequest).mapError { $0 }
                    .flatMap ({ data, response -> AnyPublisher<Data, Error> in
                        guard let httpResponse = response as? HTTPURLResponse else { return .fail(RequestError.nilResponse(urlRequest)) }
                        guard  200..<300 ~= httpResponse.statusCode else {
                            Logger.log(data)
                            return .fail(httpResponse.statusCode == 401 ? RequestError.invalidToken : RequestError.api(httpResponse.statusCode, urlRequest))
                        }
                        return Just(data).setFailureType(to: Error.self).eraseToAnyPublisher()
                    })
                    .decode(type: D.self, decoder: JSONDecoder())
                    .tryCatch({ [unowned self] error -> AnyPublisher<D, Error> in
                        guard let requestError = error as? RequestError, requestError == .invalidToken else { throw error }
                        return authenticator.takeValidToken(forceRefresh: true, isAuthorizationRequred: isAuthorizationRequired, shouldValidateToken: shouldValidateToken)
                            .map { urlRequest.setAuthorizationHeader(withAccessToken: $0?.accessToken) }
                            .flatMap({ [unowned self] urlRequest in performRequest(with: urlRequest, shouldValidateToken: false) })
                            .eraseToAnyPublisher()
                    })
                    .mapError { error -> Error in
                        switch error {
                        case is DecodingError: return RequestError.parsing("Parsing failure", error)
                        case is URLError: return RequestError.network("URL request error", error as! URLError)
                        case is RequestError: return error
                        default: return (error as NSError).code == -1001 ? RequestError.timeout(urlRequest) : RequestError.unknown(error)
                        }
                    }
            })
            .eraseToAnyPublisher()
    }
}

// MARK: - URLRequest+Extension

extension URLRequest {
    func setAuthorizationHeader(withAccessToken token: String?) -> URLRequest {
        guard let token = token else { return self }
        var authRequest = self
        authRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return authRequest
    }
}

// MARK: - Debug
/// .handleEvents(receiveOutput: { formatPrint(urlString: $0.response.url?.absoluteString, keyWord: "auth/refresh") })
fileprivate func formatPrint(urlString: String?, keyWord: String) {
    guard let urlString = urlString else { return }
    guard urlString.contains(keyWord) else { return }
    print("🏁🏁🏁 " + urlString)
}

