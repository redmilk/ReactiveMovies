//
//  GenreCollectionCell.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 11.04.2021.
//

import UIKit

struct GenreCellModel {
    let title: String
    let id: String
}

final class GenreCell: UICollectionViewCell {
    
    @IBOutlet private weak var oneLabel: UILabel!
    @IBOutlet private weak var twoLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.borderColor = #colorLiteral(red: 0.2594798207, green: 0.3202164769, blue: 1, alpha: 1)
        contentView.layer.borderWidth = 1.0
        contentView.layer.cornerRadius = contentView.bounds.height / 2
    }
 
    public func configure(with model: GenreCellModel) {
        oneLabel.text = model.id
        twoLabel.text = model.title
    }

}
