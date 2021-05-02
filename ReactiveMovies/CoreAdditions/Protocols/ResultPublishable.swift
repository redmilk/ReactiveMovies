//
//  ResultPublishable.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 01.05.2021.
//

import Combine

protocol ResultPublishable: class {
    associatedtype Result
    var resultPublisher: AnyPublisher<Result, Never> { get }
}
