//
//  CollectionDataManager.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 24.04.2021.
//

import Foundation
import UIKit

typealias DataSource = UICollectionViewDiffableDataSource<Section, MoviesListCollectionDataType>
typealias Snapshot = NSDiffableDataSourceSnapshot<Section, MoviesListCollectionDataType>

enum Section: Int {
    case genre = 0
    case movie = 1
}

// MARK: - UICollectionViewDelegate

extension CollectionDataManager: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        onWillDisplay(indexPath)
        //viewModel.currentScroll = indexPath
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onDidSelect(indexPath)
//        switch Section(rawValue: indexPath.section)! {
//        case .genre: viewModel.selectedGenreIndex = indexPath.row
//        case .movie: viewModel.showDetailWithMovieIndex(indexPath.row)
//        }
    }
}


class CollectionDataManager: NSObject {
    
    
    private unowned let collectionView: UICollectionView
    private var dataSource: DataSource!
    private let onDidSelect: (IndexPath) -> Void
    private let onWillDisplay: (IndexPath) -> Void
    
    init(collectionView: UICollectionView,
         onDidSelect: @escaping (IndexPath) -> Void,
         onWillDisplay: @escaping (IndexPath) -> Void
    ) {
        self.collectionView = collectionView
        self.onWillDisplay = onWillDisplay
        self.onDidSelect = onDidSelect
    }
    
    func configure() {
        dataSource = buildDataSource()
        collectionView.delegate = self
        layoutCollection()
        
        var snapshot = dataSource.snapshot()
        snapshot.appendSections([.genre, .movie])
        dataSource.apply(snapshot)
    }
    
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
                    heightDimension: NSCollectionLayoutDimension.absolute(200)
                )
                let itemCount = isPhone ? 4 : 5
                let item = NSCollectionLayoutItem(layoutSize: size)
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: itemCount)
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 0)
                return section
            }
        })
        collectionView.collectionViewLayout = layout
    }
}

