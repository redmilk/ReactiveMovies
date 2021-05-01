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
    
    init(authApi: AuthorizationApiType) {
        self.authApi = authApi
    }
    
    func getRequestToken() -> AnyPublisher<GetRequestToken, Error> {
        authApi.getRequestToken()
    }
}
