//
//  Publisher+Extensions.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 22.04.2021.
//

import Combine

extension Publisher {
    static func empty() -> AnyPublisher<Output, Failure> {
        return Empty().eraseToAnyPublisher()
    }

    static func fail(_ error: Failure) -> AnyPublisher<Output, Failure> {
        return Fail(error: error).eraseToAnyPublisher()
    }
    
    static func just(output: Output) -> AnyPublisher<Output, Failure> {
        return Just(output).setFailureType(to: Failure.self).eraseToAnyPublisher()
    }
}


extension Publisher {
    func flatMapLatest<T: Publisher>(
        _ transform: @escaping (Self.Output) -> T
    ) -> Publishers.SwitchToLatest<T, Publishers.Map<Self, T>> where T.Failure == Self.Failure {
        map(transform).switchToLatest()
    }
}
