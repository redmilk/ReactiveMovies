//
//  ViewController.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 11.04.2021.
//

import UIKit
import Combine

// MARK: - Publisher VC

extension HomeViewController {
    typealias Output = Action
    typealias Failure = Never
    
    enum Action {
        case searchQuery(String)
        case currentScroll(IndexPath, isSearchTextEmpty: Bool)
        case genreSelectedIndex(Int)
        case movieSelectedIndex(Int)
    }
    
    func receive<S>(subscriber: S)
    where S: Subscriber,
          HomeViewController.Failure == S.Failure,
          HomeViewController.Output == S.Input {
        
        outputToVM
            .subscribe(outputToVM)
            .store(in: &subscriptions)
    }
}

// MARK: - HomeViewController

final class HomeViewController: UIViewController, Publisher {
    
    @IBOutlet private weak var collectionView: UICollectionView!

    private let viewModel: HomeViewModel
    private var collectionDataManager: HomeCollectionDataManager!
    private let searchController = UISearchController(searchResultsController: nil)
    private var subscriptions = Set<AnyCancellable>()
    
    /// Output to view model
    private var outputToVM = PassthroughSubject<Action, Never>()
    /// Input from view model
    private var inputFromVM = PassthroughSubject<HomeViewModel.Action, Never>()
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()

        outputToVM
            .subscribe(viewModel.inputFromVC)
            .store(in: &subscriptions)
        
        viewModel.outputToVC
            .receive(on: DispatchQueue.main)
            .subscribe(inputFromVM)
            .store(in: &subscriptions)
        
        inputFromVM
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] action in
            switch action {
            case .genres(let genres): self?.collectionDataManager.applySnapshot(collectionData: genres, type: .genre)
            case .movies(let movies): self?.collectionDataManager.applySnapshot(collectionData: movies, type: .movie)
            case .hideNavigationBar(let shouldHide): self?.navigationController?.setNavigationBarHidden(shouldHide, animated: true)
            case .updateScrollPosition(let indexPath): self?.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
            }
        })
        .store(in: &subscriptions)
    }
}

// MARK: - Private

private extension HomeViewController {
    /// Initial setup
    func configureView() {
        func applyStyling() {
            navigationController?.navigationBar.prefersLargeTitles = false
            navigationController?.navigationItem.hidesSearchBarWhenScrolling = false
            collectionView.backgroundColor = .black
            view.backgroundColor = .black
            navigationController?.navigationBar.barTintColor = .black
            navigationController?.navigationBar.tintColor = .white
            searchController.searchBar.searchTextField.textColor = .white
        }
        func configureSearchController() {
            searchController.searchResultsUpdater = self
            searchController.obscuresBackgroundDuringPresentation = false
            searchController.searchBar.placeholder = "Find movie"
            navigationItem.searchController = searchController
            definesPresentationContext = true
        }
        func configureCollectionView() {
            collectionView.register(UINib(nibName: String(describing: HomeGenreCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: HomeGenreCell.self))
            collectionView.register(UINib(nibName: String(describing: HomeMovieCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: HomeMovieCell.self))
            
            collectionDataManager = HomeCollectionDataManager(
                collectionView: collectionView,
                onDidSelect: { [weak self] indexPath in
                    switch HomeMoviesSection(rawValue: indexPath.section)! {
                    case .genre: self?.outputToVM.send(.genreSelectedIndex(indexPath.row))
                    case .movie: self?.outputToVM.send(.movieSelectedIndex(indexPath.row))
                    }
                }, onWillDisplay: { [weak self] indexPath in
                    self?.outputToVM.send(.currentScroll(indexPath, isSearchTextEmpty: self?.isSearchTextEmpty ?? true))
                })
            collectionDataManager.initialSetup()
        }
        
        title = "Movies"
        applyStyling()
        configureSearchController()
        configureCollectionView()
    }
}

// MARK: - UISearchResultsUpdating Delegate

extension HomeViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        outputToVM.send(Action.searchQuery(searchController.searchBar.text ?? ""))
    }
    
    private var isSearchTextEmpty: Bool {
        return (searchController.searchBar.text ?? "").isEmpty
    }
}

