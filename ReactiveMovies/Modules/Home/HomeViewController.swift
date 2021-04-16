//
//  ViewController.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 11.04.2021.
//

import UIKit
import Combine

enum Section: Int {
    case genre = 0
    case movie = 1
}

enum HomeCollectionDataType: Hashable {
    case genre(Genre)
    case movie(MovieQueryElement)
}

typealias DataSource = UICollectionViewDiffableDataSource<Section, HomeCollectionDataType>
typealias Snapshot = NSDiffableDataSourceSnapshot<Section, HomeCollectionDataType>

final class HomeViewController: UIViewController {
    
    /// Interactor
    private lazy var viewModel: HomeViewModel = {
        HomeViewModel(moviesApi: MoviesApi(),
                      coordinator: HomeCoordinator(viewController: self))
    }()
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var subscriptions = Set<AnyCancellable>()
    private lazy var dataSource = buildDataSource()
    
    @Published private var isCollectionAnimatingDifferences: Bool = false
    @Published private var searchText: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        configureSearchController()
        layoutCollection()
        
        viewModel
            .genres
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] collectionData in
                self.applySnapshot(collectionData: collectionData, type: .genre)
            }
            .store(in: &subscriptions)
        
        viewModel
            .movies
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] collectionData in
                self.applySnapshot(collectionData: collectionData, type: .movie)
            }
            .store(in: &subscriptions)
        
        $searchText
            .removeDuplicates()
            .combineLatest($isCollectionAnimatingDifferences.filter { !$0 }.removeDuplicates())
            .map { $0.0 }
            .map { [unowned self] searchText in
                self.viewModel.filteredMovies(searchText: searchText)
            }
            .sink(receiveValue: { [unowned self] collectionData in
                self.applySnapshot(collectionData: collectionData, type: .movie, isFilter: searchText != "")
            })
            .store(in: &subscriptions)
    }
}

// MARK: - Private 🟨

private extension HomeViewController {
    
    func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Genres"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    func layoutCollection() {
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            let isPhone = layoutEnvironment.traitCollection.userInterfaceIdiom == UIUserInterfaceIdiom.phone
            
            switch Section(rawValue: sectionIndex)! {
            case .genre:
                let size = NSCollectionLayoutSize(
                    widthDimension: NSCollectionLayoutDimension.fractionalWidth(1),
                    heightDimension: NSCollectionLayoutDimension.absolute(isPhone ? 50 : 80)
                )
                let itemCount = isPhone ? 3 : 6
                let item = NSCollectionLayoutItem(layoutSize: size)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: itemCount)
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
                section.interGroupSpacing = 20
                return section
            case .movie:
                let size = NSCollectionLayoutSize(
                    widthDimension: NSCollectionLayoutDimension.fractionalWidth(1),
                    heightDimension: NSCollectionLayoutDimension.absolute(isPhone ? 300 : 500)
                )
                let itemCount = isPhone ? 2 : 2
                let item = NSCollectionLayoutItem(layoutSize: size)
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: itemCount)
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 30, trailing: 10)
                section.interGroupSpacing = 10
                return section
            }
            
            
        })
        collectionView.collectionViewLayout = layout
    }
    
    func applySnapshot(collectionData: [HomeCollectionDataType], type: Section, isFilter: Bool = false) {
        var snapshot = dataSource.snapshot()
        switch type {
        case .genre: snapshot.appendItems(collectionData, toSection: .genre)
        case .movie:
            if !isFilter {
                snapshot.appendItems(collectionData, toSection: .movie)
            } else {
                let currentItems = snapshot.itemIdentifiers(inSection: .movie)
                snapshot.deleteItems(currentItems)
                snapshot.appendItems(collectionData, toSection: .movie)
            }
        }
        /// for being able to use animating differences true
        isCollectionAnimatingDifferences = true
        dataSource.apply(snapshot, animatingDifferences: true) {
            self.isCollectionAnimatingDifferences = false
        }
    }
    
    func buildDataSource() -> DataSource {
        DataSource(collectionView: collectionView,
                   cellProvider: { (collectionView, indexPath, collectionData) -> UICollectionViewCell? in
                    var cell: UICollectionViewCell?
                    
                    switch collectionData {
                    case .genre(let genre) where indexPath.section == Section.genre.rawValue:
                        cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GenreCell",
                                                                  for: indexPath) as? GenreCell
                        (cell as? GenreCell)?.configure(with: genre)
                    case .movie(let movie) where indexPath.section == Section.movie.rawValue:
                        cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieQueryCell",
                                                                  for: indexPath) as? MovieQueryCell
                        (cell as? MovieQueryCell)?.configure(with: movie)
                    case _: fatalError()
                    }
                    return cell
                   })
    }
    
    func configureView() {
        title = "Movie Genres"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        var snapshot = Snapshot()
        snapshot.appendSections([.genre, .movie])
        dataSource.apply(snapshot)
    }
}

// MARK: - UISearchResultsUpdating Delegate

extension HomeViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchText = searchController.searchBar.text ?? ""
    }
}

