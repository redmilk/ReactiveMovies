//
//  GenreCollectionCell.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 11.04.2021.
//

import UIKit

final class GenreCell: UICollectionViewCell {
    
    @IBOutlet private weak var oneLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.borderColor = #colorLiteral(red: 0.2594798207, green: 0.3202164769, blue: 1, alpha: 1)
        contentView.layer.borderWidth = 0.5
        contentView.layer.cornerRadius = contentView.bounds.height / 2
    }
 
    public func configure(with model: Genre) {
        oneLabel.text = model.name
    }

}
