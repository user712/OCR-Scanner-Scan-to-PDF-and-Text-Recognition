//
//  MainCollectionViewCell.swift
//  Scanner
//
//  
//   
//

import UIKit

class MainCollectionViewCell: BaseCollectionViewCell {
    
    // MARK: - Properties
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    lazy var documentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    lazy var checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "selectRevealNone")
        
        return imageView
    }()
    
    lazy var nameLabel: UILabel = {
        let label = createLabel(UIColor.gri, font: UIFont.textStyleFontRegular(14), spacing: -0.5)
//        label.lineBreakMode = .byClipping
        return label
    }()
    
    lazy var dateLabel: UILabel = {
        let label = createLabel(UIColor.gri, font: UIFont.textStyleFontRegular(14), spacing: -0.5)
        
        return label
    }()

    lazy var countLabel: UILabel = {
        let label = createLabel(UIColor.darkSkyBlue, font: UIFont.textStyleFontRegular(12), spacing: -0.4)
        
        return label
    }()
    
    static let reuseIdentifier = "MainCollectionViewCell"
    
    var isChecked: Bool = false {
        didSet {
            if isChecked {
                self.checkmarkImageView.image = UIImage(named: "selectReveal")
            } else {
                self.checkmarkImageView.image = UIImage(named: "selectRevealNone")
            }
        }
    }
    

    // MARK: - Setup Views
    
    override func setupViews() {
        addSubview(nameLabel)
        addConstraintsWithFormat("H:|-2-[v0]-2-|", views: nameLabel)
        
        addSubview(imageView)
        addConstraintsWithFormat("H:|-2-[v0]-2-|", views: imageView)
        
        addSubview(dateLabel)
        addConstraintsWithFormat("H:|-2-[v0]-2-|", views: dateLabel)
     
        addSubview(countLabel)
        addConstraintsWithFormat("H:|-2-[v0]-2-|", views: countLabel)
        
        addConstraintsWithFormat("V:|-2-[v0(16)]-2-[v1]-2-[v2(16)]-2-[v3(14)]-2-|", views: nameLabel, imageView, dateLabel, countLabel)
        
        imageView.addSubview(documentImageView)
        imageView.addConstraintsWithFormat("H:|-12-[v0]-12-|", views: documentImageView)
        imageView.addConstraintsWithFormat("V:|-26-[v0]-6-|", views: documentImageView)
        
        documentImageView.addSubview(checkmarkImageView)
        
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let visualFormat = ":[documentImageView]-(<=1)-[checkmarkImageView(26)]"
        let views = ["documentImageView": documentImageView, "checkmarkImageView": checkmarkImageView]
        
        /// Center horisontally
        let horizontalConstraint = NSLayoutConstraint.constraints(
            withVisualFormat: "V" + visualFormat,
            options: .alignAllCenterX,
            metrics: nil,
            views: views)
        
        documentImageView.addConstraints(horizontalConstraint)
        
        /// Center vertically
        let verticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H" + visualFormat,
            options: .alignAllCenterY,
            metrics: nil,
            views: views)
        
        documentImageView.addConstraints(verticalConstraints)
    }
}
