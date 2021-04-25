//
//  MovieDetailsViewController.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 16.04.2021.
//

import UIKit
import Combine

final class MovieDetailsViewController: UIViewController {
    
    typealias DataSource = UICollectionViewDiffableDataSource<MovieDetailsViewController.Section, Movie>
    typealias Snapshot = NSDiffableDataSourceSnapshot<MovieDetailsViewController.Section, Movie>

    enum Section: Int {
        case main
    }
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    var viewModel: MoviewDetailsViewModel!
    private var dataSource: DataSource!
    private var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        layoutCollection()
        
        viewModel.movies
            .sink(receiveValue: { [unowned self] movies in
                applySnapshot(with: movies)
            })
            .store(in: &subscriptions)
        
        viewModel.itemScrollIndex
            .dropFirst()
            .print()
            .map { IndexPath(row: $0, section: 0) }
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [unowned self] value in
                print("🎛🎛🎛🎛🎛🎛")
                print(value.row)
                collectionView.scrollToItem(at: value, at: .top, animated: false)
            })
            .store(in: &subscriptions)
    }
    
    private func layoutCollection() {
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            switch Section(rawValue: sectionIndex)! {
            case .main:
                let size = NSCollectionLayoutSize(widthDimension: NSCollectionLayoutDimension.fractionalWidth(1),
                                                  heightDimension: NSCollectionLayoutDimension.estimated(500))
                let item = NSCollectionLayoutItem(layoutSize: size)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: 1)
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                section.orthogonalScrollingBehavior = .groupPaging
                return section
            }
        })
        collectionView.collectionViewLayout = layout
    }
    
    private func configureView() {
        title = "Movie title"
        collectionView.register(UINib(nibName: "MovieDetailCell", bundle: nil), forCellWithReuseIdentifier: "MovieDetailCell")
        collectionView.isPagingEnabled = true
        collectionView.delegate = self
        dataSource = buildDataSource()
        
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func buildDataSource() -> DataSource {
        return DataSource(collectionView: collectionView) { (collectionView, indexPath, movie) -> UICollectionViewCell? in
            print("Movie")
            print(movie.title)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieDetailCell", for: indexPath) as! MovieDetailCell
            cell.configureWithMovie(movie)
            return cell
        }
    }
    
    private func applySnapshot(with movies: [Movie]) {
        var snapshot = dataSource.snapshot()
        snapshot.appendItems(movies, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - UICollectionViewDelegate

extension MovieDetailsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = collectionView.visibleCells.first
        if let _ = cell {
            viewModel.updateScrollIndex(indexPath.row)
        }
    }
}
