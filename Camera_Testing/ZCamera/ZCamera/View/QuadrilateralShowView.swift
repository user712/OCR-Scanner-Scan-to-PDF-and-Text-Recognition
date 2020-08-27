//
//  QuadrilateralShowView.swift
//  ZCamera
//
//  Created by Developer on 3/10/17.
//  Copyright © . 
//

import UIKit

class QuadrilateralShowView: UIView {

    // MARK: - Properties
    
    let rectangleLayer = CAShapeLayer()
    
    
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }
}


// MARK: - Setup View

extension QuadrilateralShowView {
    
    fileprivate func setupView() {
        self.layer.addSublayer(rectangleLayer)
    }
}


extension QuadrilateralShowView {
    
    func drawRectanglePath(_ points: [CGPoint]?, imageSize: CGSize, viewSize: CGSize) {
        guard let pts = points else { return }
        
        if pts.count < 4 {
            return
        }
        
        let p = pts.map { (pt) -> CGPoint in
            return CGPoint(x: pt.x / imageSize.width * viewSize.width, y: pt.y / imageSize.height * viewSize.height)
        }
        
        let path = UIBezierPath()
        path.move(to: p[0])
        path.addLine(to: p[1])
        path.addLine(to: p[3])
        path.addLine(to: p[2])
        path.close()
        
        
        if self.rectangleLayer.path != path.cgPath {
            let animation = CABasicAnimation(keyPath: "path")
            animation.fromValue = self.rectangleLayer.path
            animation.toValue   = path.cgPath
            animation.duration  = 0.25
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            /// kCAMediaTimingFunctionEaseOut
            /// kCAMediaTimingFunctionEaseInEaseOut
            animation.isRemovedOnCompletion = false
            animation.fillMode = kCAFillModeBoth
            
            self.rectangleLayer.add(animation, forKey: animation.keyPath)
        }
        
        self.rectangleLayer.fillColor = UIColor(red: 17.0/255.0, green: 159.0/255.0, blue: 253.0/255.0, alpha: 0.3).cgColor
        self.rectangleLayer.strokeColor = UIColor.white.cgColor
        self.rectangleLayer.lineWidth = 1.5
        self.rectangleLayer.path = path.cgPath
    }
    
    func hidedrawRectanglePath() {
        self.rectangleLayer.fillColor = UIColor.clear.cgColor
        self.rectangleLayer.strokeColor = UIColor.clear.cgColor
        self.rectangleLayer.lineWidth = 0.0
        self.rectangleLayer.removeAnimation(forKey: "path")
    }
}
