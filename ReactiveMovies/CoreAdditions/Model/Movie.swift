//
//  Movie.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 11.04.2021.
//

import Foundation

// MARK: - Movie
struct Movie: Codable, Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(popularity)
        hasher.combine(posterPath)
        hasher.combine(releaseDate)
        hasher.combine(title)
        hasher.combine(voteAverage)
        hasher.combine(voteCount)
    }
    
    static func == (lhs: Movie, rhs: Movie) -> Bool {
        return (lhs.id == rhs.id) &&
            (lhs.posterPath == rhs.posterPath) &&
            (lhs.releaseDate == rhs.releaseDate) &&
            (lhs.popularity == rhs.popularity) &&
            (lhs.title == rhs.title) &&
            (lhs.originalTitle == rhs.originalTitle)
    }
    
    let adult: Bool?
    let backdropPath: String?
    let belongsToCollection: BelongsToCollection?
    let budget: Int?
    let genres: [Genre]?
    let homepage: String?
    let id: Int?
    let imdbID: String?
    let originalLanguage: String?
    let originalTitle: String?
    let overview: String?
    let popularity: Double?
    let posterPath: String?
    let productionCompanies: [ProductionCompany]?
    let productionCountries: [ProductionCountry]?
    let releaseDate: String?
    let revenue: Int?
    let runtime: Int?
    let spokenLanguages: [SpokenLanguage]?
    let status: String?
    let tagline: String?
    let title: String?
    let video: Bool?
    let voteAverage: Double?
    let voteCount: Int?

    enum CodingKeys: String, CodingKey {
        case adult = "adult"
        case backdropPath = "backdrop_path"
        case belongsToCollection = "belongs_to_collection"
        case budget = "budget"
        case genres = "genres"
        case homepage = "homepage"
        case id = "id"
        case imdbID = "imdb_id"
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case overview = "overview"
        case popularity = "popularity"
        case posterPath = "poster_path"
        case productionCompanies = "production_companies"
        case productionCountries = "production_countries"
        case releaseDate = "release_date"
        case revenue = "revenue"
        case runtime = "runtime"
        case spokenLanguages = "spoken_languages"
        case status = "status"
        case tagline = "tagline"
        case title = "title"
        case video = "video"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}

// MARK: - Genre
struct Genre: Codable, Hashable {
    let id: Int
    let name: String
    var isSelected: Bool? = false
    
    static var allGenres: Genre {
        return Genre(id: -1, name: "ALL", isSelected: true)
    }
    
    init(id: Int, name: String, isSelected: Bool) {
        self.id = id
        self.name = name
        self.isSelected = isSelected
    }

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
    }
    
    func hash(into hasher: inout Hasher) {
      hasher.combine(id)
        hasher.combine(name)
    }

    static func == (lhs: Genre, rhs: Genre) -> Bool {
        lhs.id == rhs.id && lhs.name == rhs.name
    }
}

// MARK: - BelongsToCollection
struct BelongsToCollection: Codable {
    let id: Int?
    let name: String?
    let posterPath: String?
    let backdropPath: String?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
    }
}

// MARK: - ProductionCompany
struct ProductionCompany: Codable {
    let id: Int?
    let logoPath: String?
    let name: String?
    let originCountry: String?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case logoPath = "logo_path"
        case name = "name"
        case originCountry = "origin_country"
    }
}

// MARK: - ProductionCountry
struct ProductionCountry: Codable {
    let iso3166_1: String?
    let name: String?

    enum CodingKeys: String, CodingKey {
        case iso3166_1 = "iso_3166_1"
        case name = "name"
    }
}

// MARK: - SpokenLanguage
struct SpokenLanguage: Codable {
    let englishName: String?
    let iso639_1: String?
    let name: String?

    enum CodingKeys: String, CodingKey {
        case englishName = "english_name"
        case iso639_1 = "iso_639_1"
        case name = "name"
    }
}

