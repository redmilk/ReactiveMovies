//
//  ServicesContainer.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 01.05.2021.
//

import Foundation

fileprivate let services = ServicesContainer()

final class ServicesContainer {
    
    private let httpClient = HTTPClient(session: URLSession(configuration: .ephemeral), isAuthorizationRequired: false)
    
    lazy var movieService: MovieService = {
        let moviesApi = MoviesApi(httpClient: httpClient)
        let imageCacher = ImageCacher()
        let imagesApi = MovieImageApi(cache: imageCacher)
        return MovieService(moviesApi: moviesApi, imageApi: imagesApi)
    }()
    
    lazy var sessionService: SessionService = {
        let authApi = AuthorizationApi(httpClient: httpClient)
        return SessionService(authApi: authApi)
    }()
}

// MARK: - add all services to file

/// All service
protocol ServicesProvidable { }
extension ServicesProvidable {
    var allServices: ServicesContainer { services }
}

// MARK: - add specific service dependency

/// MovieService
protocol MovieServiceDependencyProvidable { }
extension MovieServiceDependencyProvidable {
    var movieService: MovieService { services.movieService }
}
/// SessionService
protocol SessionServiceDependencyProvidable { }
extension SessionServiceDependencyProvidable {
    var sessionService: SessionService { services.sessionService }
}

