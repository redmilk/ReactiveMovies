//
//  MovieDetailsViewController.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 16.04.2021.
//

import UIKit
import Combine

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
        
        Publishers.CombineLatest(viewModel.movies, viewModel.scrollCollectionRowIndex)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
            .sink(receiveValue: { [weak self] movies, index in
                self?.applySnapshot(with: movies)
                self?.collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .top, animated: true)
            })
            .store(in: &subscriptions)
        
        viewModel.$movieDetails
            .compactMap { $0 }
            .sink(receiveValue: { [unowned self] in updateSnapshotItem(with: $0) })
            .store(in: &subscriptions)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isBeingDismissed {
            viewModel.dissmissViewControllerSignal.send(())
        }
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
        if let _ = cell {
            viewModel.updateScrollIndex(indexPath.row)
        }
    }
}
