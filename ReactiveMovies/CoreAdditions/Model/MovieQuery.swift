//
//  MovieQuery.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 11.04.2021.
//

import Foundation

// MARK: - Movie
struct MovieQuery: Codable {
    let page: Int?
    let results: [MovieQueryElement]?
    let totalPages: Int?
    let totalResults: Int?

    enum CodingKeys: String, CodingKey {
        case page = "page"
        case results = "results"
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

// MARK: - Result
struct MovieQueryElement: Codable, Hashable {
    let adult: Bool?
    let backdropPath: String?
    let genreIDS: [Int]?
    let id: Int?
    let originalLanguage: String?
    let originalTitle: String?
    let overview: String?
    let popularity: Double?
    let posterPath: String?
    let releaseDate: String?
    let title: String?
    let video: Bool?
    let voteAverage: Double?
    let voteCount: Int?

    enum CodingKeys: String, CodingKey {
        case adult = "adult"
        case backdropPath = "backdrop_path"
        case genreIDS = "genre_ids"
        case id = "id"
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case overview = "overview"
        case popularity = "popularity"
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case title = "title"
        case video = "video"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
    
    func hash(into hasher: inout Hasher) {
      hasher.combine(id)
        hasher.combine(popularity)
        hasher.combine(posterPath)
        hasher.combine(releaseDate)
        hasher.combine(title)
        hasher.combine(voteAverage)

    }
    
    static func == (lhs: MovieQueryElement, rhs: MovieQueryElement) -> Bool {
        return (lhs.id == rhs.id) &&
            (lhs.genreIDS == rhs.genreIDS) &&
            (lhs.posterPath == rhs.posterPath) &&
            (lhs.releaseDate == rhs.releaseDate) &&
            (lhs.popularity == rhs.popularity) &&
            (lhs.title == rhs.title)
    }
}
