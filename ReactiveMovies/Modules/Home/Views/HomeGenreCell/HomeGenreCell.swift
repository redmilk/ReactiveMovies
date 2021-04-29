//
//  HomeGenreCell.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 29.04.2021.
//

import UIKit

class HomeGenreCell: UICollectionViewCell {
    
    @IBOutlet private weak var oneLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = contentView.bounds.height / 2
    }
 
    public func configure(with model: Genre) {
        oneLabel.text = model.name
        oneLabel.font = model.name == "ALL🔎" ? UIFont.systemFont(ofSize: 13, weight: .heavy) : UIFont.systemFont(ofSize: 11, weight: .regular)
        setSelected(model.isSelected!)
    }
    
    private func setSelected(_ isSelected: Bool) {
        contentView.layer.borderWidth = isSelected ? 3.5 : 0.0
        contentView.layer.borderColor = isSelected ? UIColor.white.cgColor : UIColor.red.cgColor
        oneLabel.textColor = isSelected ? .black : .white
        contentView.backgroundColor = isSelected ? .white : .black
    }
}
