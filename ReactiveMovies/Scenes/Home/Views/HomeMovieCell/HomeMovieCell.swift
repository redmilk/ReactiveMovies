//
//  HomeMovieCell.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 30.04.2021.
//

import UIKit

class HomeMovieCell: UICollectionViewCell {

    @IBOutlet private weak var movieImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var stackView: UIStackView!
    
    func configureWithMovie(_ movie: Movie, shouldHideLabels: Bool = true) {
        titleLabel.text = movie.title
        descriptionLabel.text = (movie.originalTitle ?? "") + ": ☆" + (movie.voteAverage?.description ?? "")
        movieImageView.image = movie.image
        hideLabels(shouldHideLabels)
    }
    
    private func hideLabels(_ isHidden: Bool) {
        stackView.isHidden = isHidden
    }
}
