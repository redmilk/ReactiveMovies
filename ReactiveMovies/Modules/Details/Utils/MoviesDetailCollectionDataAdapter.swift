//
//  MoviesDetailCollectionDataAdapter.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 20.04.2021.
//

import Foundation

struct MoviesDetailCollectionDataAdapter {
    static func adaptMovies(
        _ movies: [MovieQueryElement]
    ) -> [MovieDetailsCollectionData] {
        movies.map { MovieDetailsCollectionData(movieQuery: $0, movie: nil) }
    }
}
