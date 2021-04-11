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
    
    var dataSourceWrapper: [HomeCollectionDataType] {
        return genres.map { HomeCollectionDataType.genre($0) }
    }

    enum CodingKeys: String, CodingKey {
        case genres = "genres"
    }
}
