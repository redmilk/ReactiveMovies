//
//  AuthorizationViewController.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 29.04.2021.
//

import UIKit
import Combine

// MARK: - AuthorizationViewController Action

extension AuthorizationViewController {
    enum Action {
        case loginDidPress
    }
}

// MARK: - AuthorizationViewController

final class AuthorizationViewController: UIViewController {
    
    @IBOutlet private weak var loginButton: UIButton!
    
    private(set) var viewModel: AuthorizationViewModel
    private var subscriptions = Set<AnyCancellable>()
    
    init(viewModel: AuthorizationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Bindable to ViewModel

extension AuthorizationViewController: BindableType {
    func bindViewModel() {
        loginButton.setTitle(viewModel.moduleTitle, for: .normal)
        
        loginButton.publisher(for: .touchUpInside)
            .map { _ in return Action.loginDidPress }
            .subscribe(viewModel.controllerActionsSubscriber)
            .store(in: &subscriptions)
    }
}
