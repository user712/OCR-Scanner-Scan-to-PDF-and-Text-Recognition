//
//  BadgeButton.swift
//  Scanner
//
//  
//   
//

import UIKit

class BadgeButton: UIButton {
    
    // MARK: - Properties
    
    fileprivate var badgeLabel: UILabel
    
    var badgeString: String? {
        didSet {
            setupBadgeViewWithString(badgeText: badgeString)
        }
    }
    
    var badgeEdgeInsets: UIEdgeInsets? {
        didSet {
            setupBadgeViewWithString(badgeText: badgeString)
        }
    }
    
    var badgeBackgroundColor = UIColor.rgb(red: 238, green: 75, blue: 82, alpha: 1.0) {
        didSet {
            badgeLabel.backgroundColor = badgeBackgroundColor
        }
    }
    
    var badgeTextColor = UIColor.paleGrey {
        didSet {
            badgeLabel.textColor = badgeTextColor
        }
    }
    
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        badgeLabel = UILabel()
        super.init(frame: frame)
        /// Initialization code
        setupBadgeViewWithString(badgeText: "")
    }
    
    required init?(coder aDecoder: NSCoder) {
        badgeLabel = UILabel()
        super.init(coder: aDecoder)
        setupBadgeViewWithString(badgeText: "")
    }
    
    func initWithFrame(frame: CGRect, withBadgeString badgeString: String, withBadgeInsets badgeInsets: UIEdgeInsets) -> AnyObject {
        badgeLabel = UILabel()
        badgeEdgeInsets = badgeInsets
        setupBadgeViewWithString(badgeText: badgeString)
        return self
    }
}


// MARK: - Helper Methods

extension BadgeButton {
    
    fileprivate func setupBadgeViewWithString(badgeText: String?) {
        badgeLabel.clipsToBounds = true
        badgeLabel.text = badgeText
        badgeLabel.font = UIFont.systemFont(ofSize: 12)
        badgeLabel.textAlignment = .center
        badgeLabel.sizeToFit()
        let badgeSize = badgeLabel.frame.size
        
        let height = max(20, Double(badgeSize.height) + 5.0)
        let width = max(height, Double(badgeSize.width) + 10.0)
        
        var vertical: Double?
        var horizontal: Double?
        
        if let badgeInset = self.badgeEdgeInsets {
            vertical = Double(badgeInset.top) - Double(badgeInset.bottom)
            horizontal = Double(badgeInset.left) - Double(badgeInset.right)
            
            let x = bounds.size.width.toDouble - 10 + horizontal!
            let y = -(badgeSize.height.toDouble / 2) - 10 + vertical!
            badgeLabel.frame = CGRect(x: x, y: y, width: width, height: height)
        } else {
            let x = self.frame.width - (width / 2.0).toCGFloat
            let y = -(height / 2.0).toCGFloat
            badgeLabel.frame = CGRect(x: x, y: y, width: width.toCGFloat, height: height.toCGFloat)
        }
        
        setupBadgeStyle()
        addSubview(badgeLabel)
        
        if let text = badgeText {
            badgeLabel.isHidden = text != "" ? false : true
        } else {
            badgeLabel.isHidden = true
        }
        
    }
    
    fileprivate func setupBadgeStyle() {
        badgeLabel.textAlignment = .center
        badgeLabel.backgroundColor = badgeBackgroundColor
        badgeLabel.textColor = badgeTextColor
        badgeLabel.layer.cornerRadius = badgeLabel.bounds.size.height / 2
    }
}
