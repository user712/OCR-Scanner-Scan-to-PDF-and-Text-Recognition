//
//  UIKit Extensions.swift
//  GimiCam
//
//  Created  on 3/4/17.
//  Copyright © 2017 A. 
//

import UIKit

// MARK: - CALayer

extension CALayer {
    
    func drawCameraFocus(_ lastFocusRectangle: CAShapeLayer?, didFocusAtPoint focusPoint: CGPoint, inLayer layer: CALayer) {
        var lastFocusRectangleTapped = lastFocusRectangle
        
        if let lastFocusRectangle = lastFocusRectangleTapped {
            lastFocusRectangle.removeFromSuperlayer()
            lastFocusRectangleTapped = nil
        }
        
        let size = CGSize(width: 75, height: 75)
        let rect = CGRect(origin: CGPoint(x: focusPoint.x - size.width / 2.0, y: focusPoint.y - size.height / 2.0), size: size)
        
        let endPath = UIBezierPath(rect: rect)
        endPath.move(to: CGPoint(x: rect.minX + size.width / 2.0, y: rect.minY))
        endPath.addLine(to: CGPoint(x: rect.minX + size.width / 2.0, y: rect.minY + 5.0))
        endPath.move(to: CGPoint(x: rect.maxX, y: rect.minY + size.height / 2.0))
        endPath.addLine(to: CGPoint(x: rect.maxX - 5.0, y: rect.minY + size.height / 2.0))
        endPath.move(to: CGPoint(x: rect.minX + size.width / 2.0, y: rect.maxY))
        endPath.addLine(to: CGPoint(x: rect.minX + size.width / 2.0, y: rect.maxY - 5.0))
        endPath.move(to: CGPoint(x: rect.minX, y: rect.minY + size.height / 2.0))
        endPath.addLine(to: CGPoint(x: rect.minX + 5.0, y: rect.minY + size.height / 2.0))
        
        let startPath = UIBezierPath(cgPath: endPath.cgPath)
        let scaleAroundCenterTransform = CGAffineTransform(translationX: -focusPoint.x, y: -focusPoint.y).concatenating(CGAffineTransform(scaleX: 2.0, y: 2.0).concatenating(CGAffineTransform(translationX: focusPoint.x, y: focusPoint.y)))
        startPath.apply(scaleAroundCenterTransform)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = endPath.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor(red:1, green:0.83, blue:0, alpha:0.95).cgColor
        shapeLayer.lineWidth = 1.0
        
        layer.addSublayer(shapeLayer)
        lastFocusRectangleTapped = shapeLayer
        
        CATransaction.begin()
        
        CATransaction.setAnimationDuration(0.2)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut))
        
        CATransaction.setCompletionBlock() {
            if shapeLayer.superlayer != nil {
                shapeLayer.removeFromSuperlayer()
                lastFocusRectangleTapped = nil
            }
        }
        
        let appearPathAnimation = CABasicAnimation(keyPath: "path")
        appearPathAnimation.fromValue = startPath.cgPath
        appearPathAnimation.toValue = endPath.cgPath
        shapeLayer.add(appearPathAnimation, forKey: "path")
        
        let appearOpacityAnimation = CABasicAnimation(keyPath: "opacity")
        appearOpacityAnimation.fromValue = 0.0
        appearOpacityAnimation.toValue = 1.0
        shapeLayer.add(appearOpacityAnimation, forKey: "opacity")
        
        let disappearOpacityAnimation = CABasicAnimation(keyPath: "opacity")
        disappearOpacityAnimation.fromValue = 1.0
        disappearOpacityAnimation.toValue = 0.0
        disappearOpacityAnimation.beginTime = CACurrentMediaTime() + 0.8
        disappearOpacityAnimation.fillMode = kCAFillModeForwards
        disappearOpacityAnimation.isRemovedOnCompletion = false
        shapeLayer.add(disappearOpacityAnimation, forKey: "opacity")
        
        CATransaction.commit()
    }
}


extension CALayer {
    
    func animateShadowRadius(to radius: CGFloat) {
        let key = "com.mihailsalari.GimiCam.animateShadowRadius"
        removeAnimation(forKey: key)
        
        let anim = CABasicAnimation(keyPath: #keyPath(shadowRadius))
        anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        anim.toValue = radius
        anim.duration = 0.2
        
        add(anim, forKey: key)
        shadowRadius = radius
    }
}



// MARK: - UIView

extension UIView {
    
    func addConstraintsWithFormat(_ format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
    
    func addTopBorder() {
        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0, y: 0, width: 1000, height: 0.5)
        topBorder.backgroundColor = UIColor.rgb(red: 229, green: 231, blue: 235, alpha: 1).cgColor
        self.layer.addSublayer(topBorder)
    }
}



// MARK: - UIColor

extension UIColor {
    
    class func colorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    class func rgb(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
    }
    
    class var darkSkyBlue: UIColor {
        return UIColor.rgb(red: 38.0, green: 128.0, blue: 228.0, alpha: 1.0)
    }
    
    class var paleGrey: UIColor {
        return UIColor.rgb(red: 245.0, green: 245.0, blue: 247.0, alpha: 1.0)
    }
    
    class var gri: UIColor {
        return UIColor.rgb(red: 66.0, green: 66.0, blue: 66.0, alpha: 108)
    }
    
    class var separator: UIColor {
        return UIColor.rgb(red: 228.0, green: 228.0, blue: 234.0, alpha: 108)
    }
    
    class var download: UIColor {
        return UIColor.rgb(red: 161.0, green: 161.0, blue: 175.0, alpha: 108)
    }
    
    class var navLayer: UIColor {
        return UIColor.rgb(red: 229, green: 231, blue: 235, alpha: 1.0)
    }
    
    class var tableViewLayer: UIColor {
        return UIColor.rgb(red: 203, green: 203, blue: 212, alpha: 1.0)
    }
    
    class var isDownloaded: UIColor {
        return UIColor.rgb(red: 161, green: 161, blue: 175, alpha: 1.0)
    }
}


