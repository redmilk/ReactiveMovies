//
//  MovieDetailCell.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 16.04.2021.
//

import UIKit

final class MovieDetailCell: UICollectionViewCell {
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var budgetLabel: UILabel!
    @IBOutlet private weak var popularityLabel: UILabel!
    @IBOutlet private weak var voteAverageLabel: UILabel!
    @IBOutlet private weak var revenueLabel: UILabel!
    @IBOutlet private weak var releaseDateLabel: UILabel!
    @IBOutlet private weak var originalTitleLabel: UILabel!
    @IBOutlet private weak var originalLanguageLabel: UILabel!
    @IBOutlet private weak var genresLabel: UILabel!
    @IBOutlet private weak var productionIconImageView: UIImageView!
    @IBOutlet private weak var productionNameLabel: UILabel!
    @IBOutlet private weak var productionCountryLabel: UILabel!
    @IBOutlet private weak var homePageLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.layer.borderColor = #colorLiteral(red: 0.2594798207, green: 0.3202164769, blue: 1, alpha: 1)
        containerView.layer.cornerRadius = 12
        containerView.clipsToBounds = true
    }
    
    func configure(with movie: Movie) {
        imageView.kf.setImage(with: URL(string: Endpoints.images + movie.posterPath!)!)
        descriptionLabel.text = movie.overview
        budgetLabel.text = movie.budget?.description
        popularityLabel.text = movie.popularity?.description
        voteAverageLabel.text = movie.voteAverage?.description
        revenueLabel.text = movie.revenue?.description
        releaseDateLabel.text = movie.releaseDate?.description
        originalTitleLabel.text = movie.originalTitle
        originalLanguageLabel.text = movie.originalLanguage
        genresLabel.text = movie.genres?.first?.name
        productionNameLabel.text = movie.productionCompanies?.first?.name
        productionCountryLabel.text = movie.productionCompanies?.first?.originCountry
        homePageLabel.text = movie.homepage
        
        if let logoPath = movie.productionCompanies?.first?.logoPath {
            productionIconImageView.kf.setImage(with: URL(string: Endpoints.images + logoPath)!)
        }
    }

}
