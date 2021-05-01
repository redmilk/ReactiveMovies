//
//  MoviesSearchService.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 23.04.2021.
//

import Foundation
import Combine

final class MoviesSearchService {
    // TODO: remove singletton
    static let shared = MoviesSearchService()
    
    //private let moviesApi = MoviesApi(networkService: <#NetworkServiceType#>)
    private var subscriptions = Set<AnyCancellable>()
    private var results: [MovieQueryElement] = []
    private var page: Int = 1
    
    init() {
         
    }
    
    func searchMovies(_ query: String, year: String? = nil, recycle: Bool = false) {
        if !recycle {
            subscriptions.forEach({ $0.cancel() })
            subscriptions.removeAll()
            results.removeAll()
        }
//        moviesApi.searchMovies(query, page: page, year: year)
//            .delay(for: .seconds(2), scheduler: DispatchQueue.main)
//            .sink(receiveCompletion: { completion in }, receiveValue: { [unowned self] queryResult in
//                print(queryResult.results?.count)
//                print(queryResult.results?.compactMap { $0.title }.joined(separator: ",  "))
//                print()
//                print()
//                if let count = queryResult.results?.count, query.count >= 2, count == 20 {
//                    results.append(contentsOf: queryResult.results!)
//                    page += 1
//                    searchMovies(query, recycle: true)
//                    print("Results array " + results.count.description)
//                }
//            })
//            .store(in: &subscriptions)
    }
    
}
