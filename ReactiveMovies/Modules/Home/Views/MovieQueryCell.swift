//
//  MovieQueryCell.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 11.04.2021.
//

import UIKit

final class MovieQueryCell: UICollectionViewCell {
    
    @IBOutlet private weak var movieImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    func configure(with model: MovieQueryElement) {
        titleLabel.text = model.title
        descriptionLabel.text = model.posterPath
    }
}
