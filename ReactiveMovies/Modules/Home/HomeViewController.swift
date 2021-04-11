//
//  ViewController.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 11.04.2021.
//

import UIKit
import Combine

enum Section: Int {
    case genres
    case movies
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
    
    private let searchText = CurrentValueSubject<String, Never>("")
    private let searchController = UISearchController(searchResultsController: nil)
    private var subscriptions = Set<AnyCancellable>()
    private lazy var dataSource = buildDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        configureSearchController()
        layoutCollection()

        let collectionData = viewModel
            .collectionData
            .receive(on: DispatchQueue.main)
            .share()
        
        searchText
            .filter { $0 != "" }
            .prepend("")
            .combineLatest(collectionData)
            .map { [unowned self] tuple in
                self.viewModel.filteredItems(items: tuple.1, searchText: tuple.0)
            }
            .sink(receiveValue: { [unowned self] collectionData in
                self.applySnapshot(dataContainer: collectionData)
            })
            .store(in: &subscriptions)
    }
}

// MARK: - Private

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
            case .genres:
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
            case .movies:
                let size = NSCollectionLayoutSize(
                    widthDimension: NSCollectionLayoutDimension.fractionalWidth(1),
                    heightDimension: NSCollectionLayoutDimension.absolute(isPhone ? 300 : 500)
                )
                let itemCount = isPhone ? 1 : 2
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
    
    func applySnapshot(dataContainer: [HomeCollectionDataType]) {
        var snapshot = dataSource.snapshot()
        let genres = dataContainer.filter { (dataType) -> Bool in
            switch dataType {
            case .genre: return true
            case _: break
            }
            return false
        }
        
        let movies = dataContainer.filter { (dataType) -> Bool in
            switch dataType {
            case .movie: return true
            case _: break
            }
            return false
        }

        snapshot.indexOfSection(.genres) == nil ? snapshot.appendSections([.genres]) : ()
        snapshot.indexOfSection(.movies) == nil ? snapshot.appendSections([.movies]) : ()
        snapshot.appendItems(genres, toSection: .genres)
        snapshot.appendItems(movies, toSection: .movies)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func buildDataSource() -> DataSource {
        DataSource(collectionView: collectionView,
                   cellProvider: { (collectionView, indexPath, dataContainer) -> UICollectionViewCell? in
                    var cell: UICollectionViewCell?
                    switch dataContainer {
                    case .genre(let genre) where indexPath.section == Section.genres.rawValue:
                        cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GenreCell",
                                                                  for: indexPath) as? GenreCell
                        (cell as? GenreCell)?.configure(with: genre)
                    case .movie(let movie) where indexPath.section == Section.movies.rawValue:
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
    }
}

// MARK: - UISearchResultsUpdating Delegate

extension HomeViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchText.send(searchController.searchBar.text ?? "")
    }
}

