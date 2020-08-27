//
//  ShareItemCollectionViewCell.swift
//  Scanner
//
//   
//   
//

import UIKit

class ShareItemCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var app: App? {
        didSet {
            nameLabel.text = app?.name
            if let imageName = app?.imageName {
                imageView.image = UIImage(named: imageName)
            }
        }
    }
    
    
    lazy var imageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        
        return image
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.textStyleFontRegular(10)
        label.numberOfLines = 2
        label.textColor = .black
        label.textAlignment = .center
        
        return label
    }()
    
    static let reuseIdentifier = "ShareItemCollectionViewCell"
}


// MARK: - Layout

extension ShareItemCollectionViewCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        addSubview(nameLabel)
        addSubview(imageView)
        
        addConstraintsWithFormat("H:|[v0]|", views: nameLabel)
        addConstraintsWithFormat("H:|[v0]|", views: imageView)
        
        addConstraintsWithFormat("V:|[v0][v1(26)]|", views: imageView, nameLabel)
    }
}
