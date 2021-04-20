//
//  MoviesDetailCollectionDataType.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 20.04.2021.
//

import Foundation

class MovieDetailsCollectionData: Hashable {
    var movieQuery: MovieQueryElement?
    var movie: Movie?
    
    private let id = UUID().uuidString
    
    init(movieQuery: MovieQueryElement?, movie: Movie?) {
        self.movieQuery = movieQuery
        self.movie = movie
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MovieDetailsCollectionData, rhs: MovieDetailsCollectionData) -> Bool {
        return lhs.id == rhs.id
    }
}
