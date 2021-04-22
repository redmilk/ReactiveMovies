//
//  ViewController.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 11.04.2021.
//

import UIKit
import Combine

final class HomeViewController: UIViewController {
    
    typealias DataSource = UICollectionViewDiffableDataSource<HomeViewController.Section, MoviesListCollectionDataType>
    typealias Snapshot = NSDiffableDataSourceSnapshot<HomeViewController.Section, MoviesListCollectionDataType>
    
    enum Section: Int {
        case genre = 0
        case movie = 1
    }
    
    private lazy var viewModel: HomeViewModel = {
        HomeViewModel(coordinator: HomeCoordinator(viewController: self, navigationController: navigationController),
                      movieService: MovieService.shared)
    }()
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var subscriptions = Set<AnyCancellable>()
    private lazy var dataSource = buildDataSource()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        configureSearchController()
        layoutCollection()
        
        viewModel.genres
            .sink { [unowned self] genres in
                applySnapshot(collectionData: genres, type: .genre)
            }
            .store(in: &subscriptions)
        
        viewModel.movies
            .sink { [unowned self] movies in
                applySnapshot(collectionData: movies, type: .movie)
            }
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

// MARK: - UICollectionViewDelegate

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.currentScroll = indexPath
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch Section(rawValue: indexPath.section)! {
        case .genre: viewModel.selectedGenreIndex = indexPath.row
        case .movie: viewModel.showDetailWithMovieIndex(indexPath.row)
        }
    }
}

// MARK: - Private 🟨

private extension HomeViewController {
    
    func applySnapshot(collectionData: [MoviesListCollectionDataType], type: Section) {
        var snapshot = dataSource.snapshot()
        switch type {
        case .genre:
            snapshot.appendItems(collectionData, toSection: .genre)
        case .movie:
            let currentItems = snapshot.itemIdentifiers(inSection: .movie)
            snapshot.deleteItems(currentItems)
            snapshot.appendItems(collectionData, toSection: .movie)
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func buildDataSource() -> DataSource {
        DataSource(
            collectionView: collectionView,
            cellProvider: { (collectionView, indexPath, collectionData) -> UICollectionViewCell? in
                var cell: UICollectionViewCell?
                switch collectionData {
                case .genre(let genre) where indexPath.section == Section.genre.rawValue:
                    cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: "GenreCell",
                        for: indexPath) as? GenreCell
                    (cell as? GenreCell)?.configure(with: genre)
                case .movie(let movie) where indexPath.section == Section.movie.rawValue:
                    cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: "MovieQueryCell",
                        for: indexPath) as? MovieQueryCell
                    (cell as? MovieQueryCell)?.configureWithMovie(movie)
                case _: fatalError()
                }
                return cell
            })
    }
    
    func configureView() {
        title = "Movies"
        applyStyling()
        collectionView.delegate = self
                
        var snapshot = Snapshot()
        snapshot.appendSections([.genre, .movie])
        dataSource.apply(snapshot)
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
    
    func layoutCollection() {
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            let isPhone = layoutEnvironment.traitCollection.userInterfaceIdiom == UIUserInterfaceIdiom.phone
            
            switch Section(rawValue: sectionIndex)! {
            case .genre:
                let size = NSCollectionLayoutSize(
                    widthDimension: NSCollectionLayoutDimension.fractionalWidth(1),
                    heightDimension: NSCollectionLayoutDimension.absolute(isPhone ? 30 : 50)
                )
                let itemCount = isPhone ? 4 : 6
                let item = NSCollectionLayoutItem(layoutSize: size)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10)
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: itemCount)
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 20, trailing: 10)
                section.interGroupSpacing = 20
                return section
            case .movie:
                let size = NSCollectionLayoutSize(
                    widthDimension: NSCollectionLayoutDimension.fractionalWidth(1),
                    heightDimension: NSCollectionLayoutDimension.absolute(200)//estimated(300)//absolute(isPhone ? 300 : 500)
                )
                let itemCount = isPhone ? 4 : 5
                let item = NSCollectionLayoutItem(layoutSize: size)
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: itemCount)
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 0)
                //section.interGroupSpacing = 10
                return section
            }
        })
        collectionView.collectionViewLayout = layout
    }
}

// MARK: - UISearchResultsUpdating Delegate

extension HomeViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.searchText = searchController.searchBar.text ?? ""
    }
}

