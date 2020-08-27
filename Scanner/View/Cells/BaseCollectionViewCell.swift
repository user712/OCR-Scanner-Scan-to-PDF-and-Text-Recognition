//
//  BaseCollectionViewCell.swift
//  Scanner
//
//   on 1/17/17.
//   
//

import UIKit

class BaseCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    func setupViews() { }
}
