//
//  ServicesContainer.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 01.05.2021.
//

import Foundation

fileprivate let services = ServicesContainer()

final class ServicesContainer {
    
    lazy var movieService: MovieService = {
        let httpClient = HTTPClient(session: URLSession(configuration: .ephemeral), authenticator: nil)
        let moviesApi = MoviesApi(httpClient: httpClient)
        let imageCacher = ImageCacher()
        let imagesApi = MovieImageApi(cache: imageCacher)
        return MovieService(moviesApi: moviesApi, imageApi: imagesApi)
    }()
}

// MARK: - add all services to file

protocol ServicesProvidable { }
extension ServicesProvidable {
    var allServices: ServicesContainer { services }
}

// MARK: - add specific service dependency

protocol MovieServiceDependencyProvidable { }
extension MovieServiceDependencyProvidable {
    var movieService: MovieService { services.movieService }
}

