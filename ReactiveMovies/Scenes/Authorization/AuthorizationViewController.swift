//
//  AuthorizationViewController.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 29.04.2021.
//

import UIKit
import Combine

protocol AuthorizationViewControllerOutput {
    var actionPublisher: AnyPublisher<AuthorizationViewController.Action, Never> { get }
}

// MARK: - AuthorizationViewController

final class AuthorizationViewController: UIViewController, AuthorizationPresenterOutput {
        
    enum Action {
        case loginWithCredentials(username: String, password: String)
        case validateCredentials(username: String, password: String)
        case guestSession
    }
    
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var realAuthButton: UIButton!
    @IBOutlet private weak var usernameTextfield: UITextField!
    @IBOutlet private weak var passwordTextfield: UITextField!
    @IBOutlet private weak var guestSessionButton: UIButton!
    
    var displaySomething: AnyPublisher<AuthorizationPresenter.ViewModel, Never>
    var interactor: AuthorizationInteractor

    private let output = PassthroughSubject<Action, Never>()
    //private(set) var viewModel: AuthorizationViewModel
    private var subscriptions = Set<AnyCancellable>()
    
    init(displaySomething: AnyPublisher<AuthorizationPresenter.ViewModel, Never>,
         interactor: AuthorizationInteractor
    ) {
        self.displaySomething = displaySomething
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        
        guestSessionButton.publisher(for: .touchUpInside)
            .map { _ in Action.guestSession }
            .subscribe(output)
            .store(in: &subscriptions)

        let username: AnyPublisher<String, Never> = usernameTextfield
            .publisher(for: .editingChanged)
            .compactMap { $0.text }
            .eraseToAnyPublisher()
        
        let password: AnyPublisher<String, Never> = passwordTextfield
            .publisher(for: .editingChanged)
            .compactMap { $0.text }
            .eraseToAnyPublisher()
        
        let credentials = Publishers.CombineLatest(username, password)
            .receive(on: Scheduler.mainScheduler)
            .share()
            .eraseToAnyPublisher()
        
        credentials.map { $0.0.count > 3 && $0.1.count > 3 }
            .removeDuplicates()
            .prepend(false)
            .sink(receiveValue: { [unowned self] isEnabled in
                setLoginButtonState(isEnabled: isEnabled)
            })
            .store(in: &subscriptions)
  
        realAuthButton.publisher(for: .touchUpInside)
            .map { _ in }
            .combineLatest(credentials)
            .map { $0.1 }
            .map { Action.loginWithCredentials(username: $0.0, password: $0.1) }
            .subscribe(output)
            .store(in: &subscriptions)
    }
    
    private func configureView() {
        //loginButton.setTitle(viewModel.moduleTitle, for: .normal)
        realAuthButton.layer.borderWidth = 0.5
        realAuthButton.layer.borderColor = UIColor.green.cgColor
    }
    
    private func setLoginButtonState(isEnabled: Bool) {
        realAuthButton.layer.borderWidth = isEnabled ? 5 : 0
        realAuthButton.isEnabled = isEnabled
        let validTitle = NSAttributedString(
            string: "Log in ➡️",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.black,
                         NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .heavy)]
        )
        let invalidTitle = NSAttributedString(
            string: "Invalid credentials",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.red,
                         NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .semibold)]
        )
        realAuthButton.setAttributedTitle(isEnabled ? validTitle : invalidTitle, for: .normal)
    }
}

// MARK: - Bindable to ViewModel

//extension AuthorizationViewController: BindableType {
//    func bindViewModel() {
//
//
//}
