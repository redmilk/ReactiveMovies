//
//  RefreshToken.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 01.05.2021.
//

import Combine
import Foundation

struct Token: Decodable {
    let isValid: Bool
}

struct Response: Decodable {
    let message: String
}

enum ServiceErrorMessage: String, Decodable, Error {
    case invalidToken = "invalid_token"
}

struct ServiceError: Decodable, Error {
    let errors: [ServiceErrorMessage]
}

/// NetworkSession

protocol NetworkSession: AnyObject {
    func publisher(for url: URL, token: Token?) -> AnyPublisher<Data, Error>
}

/// URLSession extension

extension URLSession: NetworkSession {
    func publisher(for url: URL, token: Token?) -> AnyPublisher<Data, Error> {
        var request = URLRequest(url: url)
        if let token = token {
            request.setValue("Bearer <access token>", forHTTPHeaderField: "Authentication")
        }
        
        return dataTaskPublisher(for: request)
            .tryMap({ result in
                guard let httpResponse = result.response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    
                    let error = try JSONDecoder().decode(ServiceError.self, from: result.data)
                    throw error
                }
                
                return result.data
            })
            .eraseToAnyPublisher()
    }
}

/// NetworkManager

struct NetworkManager {
    private let session: NetworkSession
    private let authenticator: Authenticator
    
    init(session: NetworkSession = URLSession.shared, authenticator: Authenticator) {
        self.session = session
        self.authenticator = authenticator
    }
    
    func performAuthenticatedRequest() -> AnyPublisher<Response, Error> {
      let url = URL(string: "https://donnys-app.com/authenticated/resource")!

      return authenticator.validToken()
        .flatMap({ token in
          /// we can now use this token to authenticate the request
          session.publisher(for: url, token: token)
        })
        .tryCatch({ error -> AnyPublisher<Data, Error> in
          guard let serviceError = error as? ServiceError,
                serviceError.errors.contains(ServiceErrorMessage.invalidToken) else {
            throw error
          }

          return authenticator.validToken(forceRefresh: true)
            .flatMap({ token in
              /// we can now use this new token to authenticate the second attempt at making this request
              session.publisher(for: url, token: token)
            })
            .eraseToAnyPublisher()
        })
        .decode(type: Response.self, decoder: JSONDecoder())
        .eraseToAnyPublisher()
    }
}

/**
 The idea of an authenticator is that when asked for a valid token it can go down three routes:
 
 - A valid token exists and should be returned
 - We don't have a token so the user should log in
 - A token refresh is in progress so the result should be shared
 - No token refresh is in progress so we should start one
 */

enum AuthenticationError: Error {
  case loginRequired
}

class Authenticator {
    private let session: NetworkSession
    private var currentToken: Token? = Token(isValid: false)
    private let queue = DispatchQueue(label: "Autenticator.\(UUID().uuidString)")
    
    /// this publisher is shared amongst all calls that request a token refresh
    private var refreshPublisher: AnyPublisher<Token, Error>?
    
    init(session: NetworkSession = URLSession.shared) {
        self.session = session
    }
    
    func validToken(forceRefresh: Bool = false) -> AnyPublisher<Token, Error> {
        return queue.sync { [weak self] in
            /// scenario 1: we're already loading a new token
            if let publisher = self?.refreshPublisher {
                return publisher
            }
            
            /// scenario 2: we don't have a token at all, the user should probably log in
            guard let token = self?.currentToken else {
                return Fail(error: AuthenticationError.loginRequired)
                    .eraseToAnyPublisher()
            }
            
            /// scenario 3: we already have a valid token and don't want to force a refresh
            if token.isValid, !forceRefresh {
                return Just(token)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            
            /// scenario 4: we need a new token
            let endpoint = URL(string: "https://donnys-app.com/token/refresh")!
            let publisher = session.publisher(for: endpoint, token: nil)
                .share()
                .decode(type: Token.self, decoder: JSONDecoder())
                .handleEvents(receiveOutput: { token in
                    self?.currentToken = token
                }, receiveCompletion: { _ in
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


