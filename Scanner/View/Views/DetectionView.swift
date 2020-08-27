//
//  DetectionView.swift
//  Scanner
//
//   on 2/15/17.
//   
//

import UIKit

class DetectionView: UIView {

    // MARK: - Properties
    
    var lastRectFeature: CIRectangleFeature!
    var ciImage: CIImage!
    
    
    // MARK: - Draw
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        if let ciImage = self.ciImage, let biggestRectangleFeature = self.lastRectFeature {
            let ciImageSize = ciImage.extent.size
            var rectViewBounds = biggestRectangleFeature.bounds
            
            // Calculate the actual position and size of the rectangle in the image view
            let viewSize = rect.size
            
            let scale_w = viewSize.width / (ciImageSize.width)
            let scale_h = viewSize.height / (ciImageSize.height)
            let offsetX = (viewSize.width - (ciImageSize.width) * scale_w) / 2.0
            let offsetY = (viewSize.height - (ciImageSize.height) * scale_h) / 2.0
            
            rectViewBounds = rectViewBounds.applying(CGAffineTransform(scaleX: scale_w, y: scale_h))
            rectViewBounds.origin.x += offsetX
            rectViewBounds.origin.y += offsetY
            
            UIColor.red.set()
            let bpath = UIBezierPath(rect: rectViewBounds)
            bpath.stroke()
            
            let p1 = lastRectFeature.topLeft.applying(CGAffineTransform(scaleX: scale_w, y: scale_h))
            let p2 = lastRectFeature.topRight.applying(CGAffineTransform(scaleX: scale_w, y: scale_h))
            let p3 = lastRectFeature.bottomRight.applying(CGAffineTransform(scaleX: scale_w, y: scale_h))
            let p4 = lastRectFeature.bottomLeft.applying(CGAffineTransform(scaleX: scale_w, y: scale_h))
            
            let path = UIBezierPath()
            UIColor.green.set()
            path.move(to: p1)
            path.addLine(to: p2)
            path.addLine(to: p3)
            path.addLine(to: p4)
            path.addLine(to: p1)
            
            path.stroke()
        }
    }
}
