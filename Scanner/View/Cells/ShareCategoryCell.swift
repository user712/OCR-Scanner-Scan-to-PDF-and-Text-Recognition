//
//  ShareCategoryCell.swift
//  Scanner
//
//   
//   
//

import UIKit

class ShareCategoryCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var appCategory: ShareAppCategory?
    
    fileprivate lazy var collectionView: UICollectionView = {
        let appsLayout = UICollectionViewFlowLayout()
        appsLayout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: appsLayout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        
        return collectionView
    }()
    
    static let reuseIdentifier = "ShareCategoryCell"
    static var sectionItems = 0
    
    weak var cellTapeableDegelate: CellTapeable?
    
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.collectionView.register(ShareItemCollectionViewCell.self, forCellWithReuseIdentifier: ShareItemCollectionViewCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        addSubview(collectionView)
        
        addConstraintsWithFormat("H:|-0-[v0]-0-|", views: collectionView)
        addConstraintsWithFormat("V:|[v0]|", views: collectionView)
    }
}


//MARK: - UICollectionViewDataSource

extension ShareCategoryCell: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return appCategory?.apps?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShareItemCollectionViewCell.reuseIdentifier, for: indexPath) as! ShareItemCollectionViewCell
        cell.app = appCategory?.apps?[indexPath.item]
        
        return cell
    }
}


// MARK: - UICollectionViewDelegate

extension ShareCategoryCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ShareItemCollectionViewCell {
            cellTapeableDegelate?.didSelectItemAt(indexPath, application: cell.app)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
}


// MARK: - UICollectionViewDelegateFlowLayout

extension ShareCategoryCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellHeight = collectionView.frame.size.height

        return CGSize(width: cellHeight, height: cellHeight)
    }
}
