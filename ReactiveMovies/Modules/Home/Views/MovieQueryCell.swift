//
//  MovieQueryCell.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 11.04.2021.
//

import UIKit
import Kingfisher

final class MovieQueryCell: UICollectionViewCell {
    
    @IBOutlet private weak var movieImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    func configure(with model: MovieQueryElement) {
        movieImageView.kf.setImage(with: URL(string: Endpoints.images + (model.posterPath ?? "")))
        titleLabel.text = model.title
        descriptionLabel.text = (model.originalTitle ?? "") + ": ☆" + (model.voteAverage?.description ?? "")
        contentView.layer.cornerRadius = 12.0
    }
}
