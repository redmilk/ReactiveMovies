//
//  MovieQueryCell.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 11.04.2021.
//

import UIKit
import Combine

final class MovieQueryCell: UICollectionViewCell {
    
    @IBOutlet private weak var movieImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    var imageLoadingSubscription: AnyCancellable?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoadingSubscription?.cancel()
        imageLoadingSubscription = nil
        movieImageView.image = nil
    }
    
    func configureWithMovie(_ movie: Movie) {
        titleLabel.text = movie.title
        descriptionLabel.text = (movie.originalTitle ?? "") + ": ☆" + (movie.voteAverage?.description ?? "")
        contentView.layer.cornerRadius = 12.0
        
        guard let imageUrl = URL(string: Endpoints.images + (movie.posterPath ?? "")) else { return }
        imageLoadingSubscription = BaseRequest.shared
            .loadImage(from: imageUrl)
            .sink(receiveValue: { [weak self] in self?.movieImageView.image = $0 })
    }
}
