//
//  HomeCollectionDataAdapter.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 20.04.2021.
//

import Foundation

enum MoviesCollectionDataAdapter {
    static func adaptGenres(
        _ genres: [Genre]
    ) -> [MoviesListCollectionDataType] {
        genres.map { MoviesListCollectionDataType.genre($0) }
    }
    
    static func adaptMovies(
        _ movies: [Movie]
    ) -> [MoviesListCollectionDataType] {
        movies.map { MoviesListCollectionDataType.movie($0) }
    }
}
