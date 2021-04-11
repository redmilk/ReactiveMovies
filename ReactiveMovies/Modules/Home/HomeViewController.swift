//
//  ViewController.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 11.04.2021.
//

import UIKit
import Combine

enum Section {
    case genre
    case query
}

typealias DataSource = UICollectionViewDiffableDataSource<Section, Genre>
typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Genre>

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
                
        let genres = viewModel.genres
            .receive(on: DispatchQueue.main)
            .share()
        
        searchText
            .combineLatest(genres)
            .map { [unowned self] tuple in
                self.viewModel.filteredItems(genres: tuple.1.genres, searchText: tuple.0)
            }
            .sink(receiveValue: { [unowned self] genres in
                self.applySnapshot(genres: genres)
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
        })
        collectionView.collectionViewLayout = layout
    }
    
    func applySnapshot(genres: [Genre]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.genre, .query])
        snapshot.appendItems(genres)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func buildDataSource() -> DataSource {
        DataSource(collectionView: collectionView,
                   cellProvider: { (collectionView, indexPath, genre) -> UICollectionViewCell? in
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GenreCell",
                                                                  for: indexPath) as? GenreCell
                    let genreModel: GenreCellModel = GenreCellModel(title: genre.name, id: genre.id.description)
                    cell?.configure(with: genreModel)
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

