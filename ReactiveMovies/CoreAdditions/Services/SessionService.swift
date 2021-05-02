//
//  Authentication.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 01.05.2021.
//

import Combine
import Foundation

final class SessionService {
    private let authApi: AuthorizationApiType
    private(set) var token: String? = "e953722bde3da1bd30553056a7590b0c9776d2fd" {
        didSet {
            Logger.log(token, type: .token)
        }
    }
    
    var webLoginURL: URL {
        URL(string: "https://www.themoviedb.org/authenticate/")!
    }
    
    init(authApi: AuthorizationApiType) {
        self.authApi = authApi
    }
    
    func requestRequestToken() -> AnyPublisher<GetRequestToken, Error> {
        authApi.getRequestToken()
    }
    
    func getRequestTokenWithCredentials(
        requestToken: String,
        userName: String,
        password: String
    ) -> AnyPublisher<GetRequestToken, Error> {
        authApi.getRequestTokenWithCredentials(requestToken: requestToken, userName: userName, password: password)
    }
    
    func requestNewSessionId(with requestToken: String) -> AnyPublisher<GetSessionId, Error> {
        authApi.requestNewSessionId(with: requestToken)
    }
    
    func requestGuestSessionId() -> AnyPublisher<GetGuestSessionId, Error> {
        authApi.requestGuestSessionId()
    }
    
    func updateToken(token: String) {
        self.token = token
    }
}
