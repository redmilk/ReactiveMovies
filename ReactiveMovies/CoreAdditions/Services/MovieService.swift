//
//  MovieService.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 16.04.2021.
//

import Foundation
import Combine
// think about it

//class MovieGenre {
//    var info: Genre
//    var movies: [Movie]
//
//    init(genre: Genre, movies: [Movie]) {
//        self.info = genre
//        self.movies = movies
//    }
//}
//
//class MoviesStorage {
//    var genres: [MovieGenre]
//}

// MARK: - MovieService

final class MovieService {
    
    static let shared = MovieService(moviesApi: MoviesApi())
        
    // MARK: - Input
    @Published var currentScroll: IndexPath = IndexPath(row: 0, section: 0)
    @Published var selectedGenreIndex: Int = 0
    @Published var selectedMovieIndex: Int?
    @Published var searchText: String = ""
    
    // MARK: - Output
    @Published private(set) var moviesFiltered: [MovieQueryElement] = []
    @Published private(set) var genres: [Genre] = []
    
    var errors: AnyPublisher<RequestError, Never> {
        errors_.eraseToAnyPublisher()
    }
    
    private var pagination: Int = 1
    private(set) var moviesOriginal: [MovieQueryElement] = []
    private let errors_ = PassthroughSubject<RequestError, Never>()
    private var subscriptions = Set<AnyCancellable>()
    private let moviesApi: MoviesApi
    
    func fetchMovies() {
        moviesApi
            .requestMoviesWithQuery(page: pagination, genres: nil)
            .compactMap { $0.results }
            .sink(receiveCompletion: { [unowned self] completion in
                if case .failure(let error) = completion {
                    self.errors_.send(error)
                }
            }, receiveValue: { [unowned self] requestedMovies in
                moviesOriginal += requestedMovies
                moviesFiltered = moviesOriginal
                self.pagination += 1
            })
            .store(in: &subscriptions)
    }
    
    func fetchGenres() {
        moviesApi
            .requestMoviesGenres()
            .map { $0.genres }
            .sink(receiveCompletion: { [unowned self] completion in
                if case .failure(let error) = completion {
                    errors_.send(error)
                }
            },
            receiveValue: { [unowned self] genresResult in
                genres = [Genre.allGenres] + genresResult
            })
            .store(in: &subscriptions)
    }

    init(moviesApi: MoviesApi) {
        self.moviesApi = moviesApi
        bindInput()
    }
    
    private func bindInput() {
        /// infinite scroll
        $currentScroll
            .filter { [unowned self] in (moviesFiltered.count - 1) == $0.row && $0.section == 1 && searchText.isEmpty && selectedGenreIndex == 0 }
            .handleEvents(receiveOutput: { [unowned self] _ in
                fetchMovies()
            })
            .sink { indexPath in }
            .store(in: &subscriptions)
        
        /// search text
        $searchText
            .removeDuplicates()
            .filter { [unowned self] _ in selectedGenreIndex == 0 }
            .map { [unowned self] searchText -> [MovieQueryElement] in
                filteredMovies(moviesOriginal, searchText: searchText)
            }
            .sink(receiveValue: { [unowned self] searchResults in
                print("search movies count: " + searchResults.count.description)
                moviesFiltered = searchResults
            })
            .store(in: &subscriptions)
        
        /// selected genre
        $selectedGenreIndex
            .compactMap { $0 }
            .filter { [unowned self] _ in searchText.isEmpty && genres.count > 0 }
            .sink { [unowned self] genreIndex in
                deselectAllGenres()
                selectGenreAtIndex(genreIndex)
                filterMoviesByGenre(genres[genreIndex])
            }
            .store(in: &subscriptions)
    }
    
    private func fetchMovieDetailsWithMovieId(_ id: Int) -> AnyPublisher<Movie, RequestError> {
        return moviesApi
            .requestMovieDetails(movieId: id)
            .eraseToAnyPublisher()
    }
}

// MARK: - Filters

private extension MovieService {
    
    func filteredMovies(
        _ movies: [MovieQueryElement],
        searchText: String?
    ) -> [MovieQueryElement] {
        guard let searchText = searchText, !searchText.isEmpty else {
            return movies
        }
        return movies.filter { item in
            item.title!.lowercased().contains(searchText.lowercased())
        }
    }
    
    func deselectAllGenres() {
        genres = genres.map { Genre(id: $0.id, name: $0.name, isSelected: false) }
    }
    
    func selectGenreAtIndex(_ index: Int) {
        var genre: Genre = genres[index]
        genre.isSelected = true
        genres[index] = genre
    }
    
    func filterMoviesByGenre(_ genre: Genre?) {
        guard let genre = genre, genre.id != -1 else { /// ALL item index
            return moviesFiltered = moviesOriginal
        }
        moviesFiltered = moviesOriginal.filter { $0.genreIDS!.contains(genre.id) }
    }
}
