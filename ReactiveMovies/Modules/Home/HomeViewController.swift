//
//  ViewController.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 11.04.2021.
//

import UIKit
import Combine



enum HomeCollectionDataType: Hashable {
    case genre(Genre)
    case movie(MovieQueryElement)
    
    var genre: Genre? {
        switch self {
        case .genre(let genre): return genre
        case _: return nil
        }
    }
    
    var movie: MovieQueryElement? {
        switch self {
        case .movie(let movie): return movie
        case _: return nil
        }
    }
}

final class HomeViewController: UIViewController {
    
    typealias DataSource = UICollectionViewDiffableDataSource<HomeViewController.Section, HomeCollectionDataType>
    typealias Snapshot = NSDiffableDataSourceSnapshot<HomeViewController.Section, HomeCollectionDataType>
    
    enum Section: Int {
        case genre = 0
        case movie = 1
    }
    
    /// Interactor
    private lazy var viewModel: HomeViewModel = {
        HomeViewModel(coordinator: HomeCoordinator(viewController: self, navigationController: navigationController),
                      movieService: MovieService())
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
        
        viewModel
            .genres
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] collectionData in
                self.applySnapshot(collectionData: collectionData, type: .genre)
            }
            .store(in: &subscriptions)
        
        viewModel
            .filteredMovies
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] collectionData in
                self.applySnapshot(collectionData: collectionData, type: .movie)
            }
            .store(in: &subscriptions)
        
        viewModel
            .$selectedGenreIndex
            .sink(receiveValue: { [unowned self] index in
                self.navigationController?.setNavigationBarHidden(index != 0, animated: true)
            })
            .store(in: &subscriptions)
    }
    
    @objc private func scrollToTop() {
        collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
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
        case .movie: viewModel.selectedMovieIndex = indexPath.row
        }
        
    }
}

// MARK: - Private 🟨

private extension HomeViewController {
    
    func applySnapshot(collectionData: [HomeCollectionDataType], type: Section) {
        var snapshot = dataSource.snapshot()
        switch type {
        case .genre: snapshot.appendItems(collectionData, toSection: .genre)
        case .movie:
            let currentItems = snapshot.itemIdentifiers(inSection: .movie)
            snapshot.deleteItems(currentItems)
            snapshot.appendItems(collectionData, toSection: .movie)
        }
        dataSource.apply(snapshot, animatingDifferences: true)
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
        title = "Movies"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.hidesSearchBarWhenScrolling = false
        collectionView.delegate = self
        
        let scrollToTopButton = UIBarButtonItem(title: "Scroll top", style: .plain, target: self, action: #selector(scrollToTop))
        navigationItem.setRightBarButton(scrollToTopButton, animated: false)
        
        var snapshot = Snapshot()
        snapshot.appendSections([.genre, .movie])
        dataSource.apply(snapshot)
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
                    heightDimension: NSCollectionLayoutDimension.absolute(isPhone ? 300 : 500)
                )
                let itemCount = isPhone ? 3 : 4
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
}

// MARK: - UISearchResultsUpdating Delegate

extension HomeViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.searchText = searchController.searchBar.text ?? ""
    }
}

