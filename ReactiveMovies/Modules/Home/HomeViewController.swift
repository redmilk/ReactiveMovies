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
        case currentScroll(IndexPath)
        case genreSelectedIndex(Int)
        case movieSelectedIndex(Int)
    }
    
    func receive<S>(subscriber: S)
    where S: Subscriber,
          HomeViewController.Failure == S.Failure,
          HomeViewController.Output == S.Input {
        
        publisher
            .subscribe(publisher)
            .store(in: &subscriptions)
    }
}

// MARK: - HomeViewController

final class HomeViewController: UIViewController, Publisher {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private lazy var viewModel: HomeViewModel = {
        HomeViewModel(coordinator: HomeCoordinator(viewController: self, navigationController: navigationController),
                      movieService: MovieService.shared)
    }()
    
    private var publisher = PassthroughSubject<Action, Never>()
    
    private lazy var collectionDataManager: HomeCollectionDataManager = {
        HomeCollectionDataManager(
            collectionView: collectionView,
            onDidSelect: { [unowned self] indexPath in
                switch HomeMoviesSection(rawValue: indexPath.section)! {
                case .genre: self.viewModel.selectedGenreIndex = indexPath.row
                case .movie: self.viewModel.showDetailWithMovieIndex(indexPath.row)
                }
            }, onWillDisplay: { [unowned self] indexPath in
                self.viewModel.currentScroll = indexPath
            })
    }()
  
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        configureSearchController()
        collectionDataManager.configure()
        
        viewModel.genres
            .sink { [unowned self] genres in
                collectionDataManager.applySnapshot(collectionData: genres, type: .genre)
            }
            .store(in: &subscriptions)
        
        viewModel.movies
            .sink { [unowned self] movies in
                collectionDataManager.applySnapshot(collectionData: movies, type: .movie) }
            .store(in: &subscriptions)
    
        viewModel.hideNavigationBar
            .sink(receiveValue: { [unowned self] shouldHideNavbar in
                DispatchQueue.main.async {
                    navigationController?.setNavigationBarHidden(shouldHideNavbar, animated: true)
                }
            })
            .store(in: &subscriptions)
        viewModel.updateScrollPosition
            .sink { [unowned self] index in
                DispatchQueue.main.async {
                    collectionView.scrollToItem(at: index, at: .centeredVertically, animated: true)
                }
            }
            .store(in: &subscriptions)
    }
}

// MARK: - Private 🟨

private extension HomeViewController {
    func configureView() {
        title = "Movies"
        applyStyling()
    }
    
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
}

// MARK: - UISearchResultsUpdating Delegate

extension HomeViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.searchText = searchController.searchBar.text ?? ""
    }
}

