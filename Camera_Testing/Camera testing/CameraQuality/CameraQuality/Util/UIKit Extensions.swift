//
//  UIKit Extensions.swift
//  CameraQuality
//
//  Created by Developer on 3/1/17.
//  Copyright © 2017 
//

import UIKit

extension CAShapeLayer {
    
    func draw(inRect previewRect: CGRect, ciImage: CIImage, biggestRectangleFeature: CIRectangleFeature) {
        let imageRect: CGRect = ciImage.extent
        let shapeFillColor = UIColor.blue.withAlphaComponent(0.3).cgColor
        let shapeStrokeColor = UIColor.white.cgColor
        
        /// find ratio between the video preview rect and the image rect; rectangle feature coordinates are relative to the CIImage
        let deltaX: CGFloat = previewRect.width / imageRect.width
        let deltaY: CGFloat = previewRect.height / imageRect.height
        
        /// transform to UIKit coordinate system
        var transform = CGAffineTransform(translationX: 0.0, y: previewRect.height)
        transform = transform.scaledBy(x: 1, y: -1)
        
        /// apply preview to image scaling
        transform = transform.scaledBy(x: deltaX, y: deltaY)
        
        
        let topLeft = biggestRectangleFeature.topLeft.applying(transform)
        let topRight = biggestRectangleFeature.topRight.applying(transform)
        let bottomRight = biggestRectangleFeature.bottomRight.applying(transform)
        let bottomLeft = biggestRectangleFeature.bottomLeft.applying(transform)
        
        
        let path = UIBezierPath()
        path.move(to: topLeft)
        path.addLine(to: topRight)
        path.addLine(to: bottomRight)
        path.addLine(to: bottomLeft)
        path.addLine(to: topLeft)
        path.close()
        
        if self.path != path.cgPath {
            let animation = CABasicAnimation(keyPath: "path")
            animation.fromValue = self.path
            animation.toValue   = path.cgPath
            animation.duration  = 0.25
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut) // kCAMediaTimingFunctionEaseOut /// kCAMediaTimingFunctionEaseInEaseOut
            animation.isRemovedOnCompletion = false
            animation.fillMode = kCAFillModeBoth
            
            self.add(animation, forKey: animation.keyPath)
        }
        
        self.fillColor = shapeFillColor
        self.strokeColor = shapeStrokeColor
        self.lineWidth = 2.0
        self.path = path.cgPath
    }
    
    func hide() {
        self.fillColor = UIColor.clear.cgColor
        self.strokeColor = UIColor.clear.cgColor
        self.lineWidth = 0.0
        
        self.removeAnimation(forKey: "path")
    }
}

