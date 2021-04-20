//
//  MoviesCollectionDataType.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 20.04.2021.
//

import Foundation

enum MoviesListCollectionDataType: Hashable {
    case genre(Genre)
    case movie(MovieQueryElement)
    
    var genre: Genre? {
        switch self {
        case .genre(let genre): return genre
        case _: return nil
        }
    }
    
    var movie: MovieQueryElement? {
        switch self {
        case .movie(let movie): return movie
        case _: return nil
        }
    }
}
