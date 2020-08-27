//
//  MagnifierView.swift
//  Magnifier
//
//  Created by Developer on 3/10/17.
//  Copyright © . 
//

import UIKit

class MagnifierView: UIView {

    // MARK: - Properties
    
    var viewToMagnify: UIView!
    var touchPoint = CGPoint.zero
    
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        
        // make tnonatomic, nonatomic, he circle-shape outline with a nice border.
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 3
        self.layer.cornerRadius = 40
        self.layer.masksToBounds = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // MARK: - Deinitializers
    
    deinit {
        self.viewToMagnify = nil
    }
}


// MARK: - Draw

extension MagnifierView {
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // here we're just doing some transforms on the view we're magnifying,
        // and rendering that view directly into this view,
        // rather than the previous method of copying an image.
        if let context = UIGraphicsGetCurrentContext() {
            context.translateBy(x: 1 * (self.frame.size.width * 0.5), y: 1 * (self.frame.size.height * 0.5))
            context.scaleBy(x: 1.5, y: 1.5)
            context.translateBy(x: -1 * (touchPoint.x), y: -1 * (touchPoint.y))
            self.viewToMagnify.layer.render(in: context)
        }
    }
}

// MARK: - Set touch

extension MagnifierView {
    
    func setTouch(_ pt: CGPoint) {
        touchPoint = pt
        // whenever touchPoint is set,
        // update the position of the magnifier (to just above what's being magnified)
        self.center = CGPoint(x: pt.x, y: pt.y - 60)
    }
}
