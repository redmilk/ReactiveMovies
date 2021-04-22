//
//  MovieService.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 16.04.2021.
//

import Foundation
import UIKit
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

/**
 head // [Entity]
     .flatMap { entities -> AnyPublisher<Entity, Error> in
         Publishers.Sequence(sequence: entities).eraseToAnyPublisher()
     }.flatMap { entity -> AnyPublisher<Entity, Error> in
         self.makeFuture(for: entity) // [Derivative]
             .flatMap { derivatives -> AnyPublisher<Derivative, Error> in
                 Publishers.Sequence(sequence: derivatives).eraseToAnyPublisher()
             }
             .flatMap { derivative -> AnyPublisher<Derivative2, Error> in
                 self.makeFuture(for: derivative).eraseToAnyPublisher() // Derivative2
         }.collect().map { derivative2s -> Entity in
             self.configuredEntity(entity, from: derivative2s)
         }.eraseToAnyPublisher()
     }.collect()
 */

// MARK: - MovieService

final class MovieService {
    
    static let shared = MovieService()
        
    // MARK: - Input
    @Published var currentScroll: IndexPath = IndexPath(row: 0, section: 0)  {
        didSet {
            print(currentScroll.row)
        }
    }
    @Published var selectedGenreIndex: Int = 0
    @Published var selectedMovieIndex: Int?
    @Published var searchText: String = ""
    
    // MARK: - Output
    @Published private(set) var moviesFiltered: [Movie] = []
    @Published private(set) var genres: [Genre] = []
    var errors: AnyPublisher<Error, Never> {
        errors_.eraseToAnyPublisher()
    }
    
    // MARK: - Private
    private var pagination: Int = 1
    private var moviesOriginal: [Movie] = []
    private let errors_ = PassthroughSubject<Error, Never>()
    private var subscriptions = Set<AnyCancellable>()
    private let moviesApi = MoviesApi()
    
    // MARK: - Bindings
    private init() { bindInput() }
    
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
    
    func loadImage(_ path: String?) -> AnyPublisher<UIImage?, Never> {
        guard let imageUrl = URL(string: Endpoints.images + (path ?? "")) else {
            return Just(nil).setFailureType(to: Never.self).eraseToAnyPublisher()
        }
        return NetworkService.shared
            .loadImage(from: imageUrl)
            .eraseToAnyPublisher()
    }
    
    func fetchMovies() {
        moviesApi.requestMoviesWithQuery(page: pagination, genres: nil) /// request movies by page
            .compactMap { $0.results }
            .subscribe(on: Scheduler.backgroundWorkScheduler)
            .flatMap({ movies -> AnyPublisher<MovieQueryElement, Error> in /// make publishers sequence
                Publishers.Sequence(sequence: movies)
                    .eraseToAnyPublisher()
            })
            .flatMap({ [unowned self] movie -> AnyPublisher<Movie, Error> in /// building the movie
                moviesApi.requestMovieDetails(movieId: movie.id!) /// get movies full details
                    .flatMap({ [unowned self] movie -> AnyPublisher<Movie, Error> in
                        Future<Movie, Never> { promise in /// return the movie filled with image
                            loadImage(movie.posterPath) /// load movie poster image
                                .subscribe(on: Scheduler.backgroundWorkScheduler)
                                .setFailureType(to: Never.self)
                                .eraseToAnyPublisher()
                                .sink(receiveValue: { image in
                                    movie.image = image
                                    promise(.success(movie))
                                })
                                .store(in: &subscriptions)
                        }
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                    })
                    .eraseToAnyPublisher()
            })
            .receive(on: Scheduler.mainScheduler)
            .sink(receiveCompletion: { [unowned self] completion in
                if case .failure(let error) = completion {
                    errors_.send(error)
                }
            }, receiveValue: { [unowned self] fullMovie in
                moviesOriginal.append(fullMovie)
                moviesFiltered = moviesOriginal
                pagination += 1
            })
            .store(in: &subscriptions)
    }
}

// MARK: - Private

private extension MovieService {
    
    func bindInput() {
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
            .map { [unowned self] searchText -> [Movie] in
                filteredMovies(moviesOriginal, searchText: searchText)
            }
            .sink(receiveValue: { [unowned self] searchResults in
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
    
    func fetchMovieDetailsWithMovieId(_ id: Int) -> AnyPublisher<Movie, Error> {
        return moviesApi
            .requestMovieDetails(movieId: id)
            .eraseToAnyPublisher()
    }
    
    func filteredMovies(
        _ movies: [Movie],
        searchText: String?
    ) -> [Movie] {
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
        guard let genre = genre, genre.id != -1 else { /// -1 ALL genre items index
            return moviesFiltered = moviesOriginal
        }
        let result = moviesOriginal.filter { $0.genres?.contains(genre) ?? true }
        moviesFiltered = result
    }
    
    func chainAllRequests() {
        moviesApi.requestMoviesGenres()
            .compactMap { $0.genres }
            .flatMap({ genres -> AnyPublisher<Genre, Error> in
                Publishers.Sequence(sequence: genres).eraseToAnyPublisher()
            })
            .map { $0.id }
            .flatMap({ [unowned self] genreId -> AnyPublisher<Movie, Error> in
                moviesApi.requestMoviesWithQuery(page: 1, genres: genreId.description)
                    .eraseToAnyPublisher()
                    .compactMap { $0.results }
                    .flatMap({ movies -> AnyPublisher<MovieQueryElement, Error> in
                        Publishers.Sequence(sequence: movies).eraseToAnyPublisher()
                    })
                    .compactMap { $0.id }
                    .flatMap({ id -> AnyPublisher<Movie, Error> in
                        moviesApi.requestMovieDetails(movieId: id)
                    })
                    .eraseToAnyPublisher()
            })
            .sink(receiveCompletion: { [unowned self] completion in
                if case .failure(let error) = completion {
                    errors_.send(error)
                }
            }, receiveValue: { [unowned self] movie in
                //_movies_.append(movie)
            })
            .store(in: &subscriptions)
    }
}
