//
//  Genre.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 11.04.2021.
//

import Foundation

// MARK: - Genre
struct Genres: Codable {
    let genres: [Genre]
    
    var dataSourceWrapper: [MoviesListCollectionDataType] {
        return genres.map { MoviesListCollectionDataType.genre($0) }
    }
}
