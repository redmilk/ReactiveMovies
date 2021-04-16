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
    private lazy var dataSource = buildDataSource()
    private var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        layoutCollection()
        
        viewModel.movie.sink(receiveValue: { [unowned self] movie in
            self.applySnapshot(with: [movie])
        })
        .store(in: &subscriptions)
    }
    
    private func layoutCollection() {
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            switch Section(rawValue: sectionIndex)! {
            case .main:
                let size = NSCollectionLayoutSize(widthDimension: NSCollectionLayoutDimension.fractionalWidth(1),
                                                  heightDimension: NSCollectionLayoutDimension.estimated(1000))
                let item = NSCollectionLayoutItem(layoutSize: size)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: 1)
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                section.interGroupSpacing = 20
                return section
            }
        })
        collectionView.collectionViewLayout = layout
    }
    
    private func configureView() {
        title = "Movie title"
        collectionView.register(UINib(nibName: "MovieDetailCell", bundle: nil), forCellWithReuseIdentifier: "MovieDetailCell")
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        dataSource.apply(snapshot)
    }
    
    private func buildDataSource() -> DataSource {
        return DataSource(collectionView: collectionView) { (collectionView, indexPath, movie) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieDetailCell", for: indexPath) as! MovieDetailCell
            cell.configure(with: movie)
            return cell
        }
    }
    
    private func applySnapshot(with movies: [Movie]) {
        var snapshot = dataSource.snapshot()
        snapshot.appendItems(movies, toSection: .main)
        dataSource.apply(snapshot)
    }
    
}
