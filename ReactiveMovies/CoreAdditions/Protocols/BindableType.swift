//
//  BindableType.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 29.04.2021.
//

import UIKit

protocol BindableType {
    associatedtype ViewModelType
    var viewModel: ViewModelType { get }
    func bindViewModel()
}

extension BindableType where Self: UIViewController {
    mutating func bindViewModel(to model: Self.ViewModelType) {
        loadViewIfNeeded()
        bindViewModel()
    }
}
