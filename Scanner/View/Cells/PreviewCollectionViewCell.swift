//
//  PreviewCollectionViewCell.swift
//  Scanner
//
//   on 1/17/17.
//   
//

import UIKit

class PreviewCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var image: UIImage!
    
    static let reuseIdentifier = "PreviewCollectionViewCell"
    
    lazy var textView: UITextView = {
        let textView = UITextView(frame: self.bounds)
        textView.isEditable = true
//        textView.returnKeyType = .done
        textView.delegate = self
        
        return textView
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: self.bounds)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.image = self.image
        
        return imageView
    }()
    
    fileprivate let closeKeyboardButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "dismissKeyboard")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor.darkSkyBlue
        
        return button
    }()
    
    fileprivate lazy var accessoryView: UIView = {
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 40))
        customView.backgroundColor = UIColor.rgb(red: 208, green: 212, blue: 217, alpha: 1.0)
        customView.addTopBorder()
        
        return customView
    }()
    
    
    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        setupViews()
    }
}


// MARK: - Setup Views

extension PreviewCollectionViewCell {
    
    func setupViews() {
        self.addSubview(imageView)
        self.addSubview(textView)
        textView.isHidden = true
        
        closeKeyboardButton.addTarget(self, action: #selector(closeKeyboardTapped(_:)), for: .touchUpInside)
        accessoryView.addSubview(closeKeyboardButton)
        accessoryView.addConstraintsWithFormat("H:[v0]-20-|", views: closeKeyboardButton)
        accessoryView.addConstraintsWithFormat("V:|-2-[v0]-2-|", views: closeKeyboardButton)
    }
}


// MARK: - Action's

extension PreviewCollectionViewCell {
    
    @objc fileprivate func closeKeyboardTapped(_ button: UIButton) {
        self.endEditing(true)
    }
}


// MARK: - UITextViewDelegate

extension PreviewCollectionViewCell: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textView.inputAccessoryView = accessoryView
        
        return true
    }
    
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        if text == "\n" {
//            textView.resignFirstResponder()
//            
//            return false
//        }
//        
//        return true
//    }
}
