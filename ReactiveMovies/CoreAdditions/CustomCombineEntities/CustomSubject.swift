//
//  CustomSubject.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 30.04.2021.
//

import Combine

final class CustomSubject<Output, Failure: Error>: Subject {
    init(initialValue: Output, groom: @escaping (Output) -> Output) {
        self.wrapped = .init(groom(initialValue))
        self.groom = groom
    }

    func send(_ value: Output) {
        wrapped.send(groom(value))
    }

    func send(completion: Subscribers.Completion<Failure>) {
        wrapped.send(completion: completion)
    }

    func send(subscription: Subscription) {
        wrapped.send(subscription: subscription)
    }

    func receive<Downstream: Subscriber>(subscriber: Downstream) where Failure == Downstream.Failure, Output == Downstream.Input {
        wrapped.subscribe(subscriber)
    }

    private let wrapped: CurrentValueSubject<Output, Failure>
    private let groom: (Output) -> Output
}
