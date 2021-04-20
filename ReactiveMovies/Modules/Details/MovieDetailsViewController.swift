//
//  MovieDetailsViewController.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 16.04.2021.
//

import UIKit
import Combine

class MovieDetailsCollectionData: Hashable {
    var movieQuery: MovieQueryElement?
    var movie: Movie?
    
    private let id = UUID().uuidString
    
    init(movieQuery: MovieQueryElement?, movie: Movie?) {
        self.movieQuery = movieQuery
        self.movie = movie
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MovieDetailsCollectionData, rhs: MovieDetailsCollectionData) -> Bool {
        return lhs.id == rhs.id
    }
}

final class MovieDetailsViewController: UIViewController {
    
    typealias DataSource = UICollectionViewDiffableDataSource<MovieDetailsViewController.Section, MovieDetailsCollectionData>
    typealias Snapshot = NSDiffableDataSourceSnapshot<MovieDetailsViewController.Section, MovieDetailsCollectionData>

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
        
        viewModel
            .$movies
            .compactMap { $0 }
            .sink(receiveValue: { [unowned self] movies in
                applySnapshot(with: movies)
                collectionView.scrollToItem(at: IndexPath(row: viewModel.selectedScrollItemRowIndex!, section: 0), at: .top, animated: true)
            })
            .store(in: &subscriptions)
        
        viewModel
            .$movieDetails
            .compactMap { $0 }
            .sink(receiveValue: { [unowned self] in updateSnapshotItem(with: $0) })
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
                //section.interGroupSpacing = 20
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

        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        dataSource.apply(snapshot)
    }
    
    private func buildDataSource() -> DataSource {
        return DataSource(collectionView: collectionView) { (collectionView, indexPath, collectionData) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieDetailCell", for: indexPath) as! MovieDetailCell
            cell.configure(with: collectionData)
            return cell
        }
    }
    
    private func applySnapshot(with collectionData: [MovieDetailsCollectionData]) {
        var snapshot = dataSource.snapshot()
        snapshot.appendItems(collectionData, toSection: .main)
        dataSource.apply(snapshot)
    }
    
    private func updateSnapshotItem(with data: MovieDetailsCollectionData) {
        var snapshot = dataSource.snapshot()
        if let _ = snapshot.indexOfItem(data) {
            snapshot.reloadItems([data])
            dataSource.apply(snapshot, animatingDifferences: false)
        }
    }
    
}

// MARK: - UICollectionViewDelegate

extension MovieDetailsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = collectionView.visibleCells.first
        if let cell = cell {
            let indexPath = collectionView.indexPath(for: cell)
            viewModel.selectedScrollItemRowIndex = indexPath?.row
        }
    }
}
