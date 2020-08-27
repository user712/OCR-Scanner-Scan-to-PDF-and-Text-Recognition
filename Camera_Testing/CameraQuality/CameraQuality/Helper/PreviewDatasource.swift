//
//  PreviewDatasource.swift
//  CameraQuality
//
//  Created  on 2/28/17.
//  Copyright © 2017 
//

import UIKit
import QuickLook

class PreviewDatasource: NSObject {

    // MARK: - Properties
    
    let previewItem: PreviewItem
    
    
    // MARK: - Initializers
    
    init(previewItem: PreviewItem) {
        self.previewItem = previewItem
        super.init()
    }
}


// MARK: - QLPreviewControllerDataSource

extension PreviewDatasource: QLPreviewControllerDataSource {
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return self.previewItem
    }
}


import AVFoundation

class RectangleDetector {
    
    // MARK: - Properties
    
    static let main = RectangleDetector()
    fileprivate var detector: CIDetector!
    
    
    
    // MARK: - Initializers
    
    private init() {
        detector = self.buildRectangleDetector
    }
}


// MARK: - Image from CMSampleBuffer

extension RectangleDetector {
    
    func sampleBufferToImage(_ sampleBuffer: CMSampleBuffer) -> CIImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }
        
        /// Force the type change - pass through opaque buffer
        let opaqueBuffer = Unmanaged<CVImageBuffer>.passUnretained(imageBuffer).toOpaque()
        let pixelBuffer = Unmanaged<CVPixelBuffer>.fromOpaque(opaqueBuffer).takeUnretainedValue()
        let sourceImage = CIImage(cvPixelBuffer: pixelBuffer, options: nil)
        
        return sourceImage
    }
}


extension RectangleDetector {
    
    /// -----------------------
    /// Create feature detector
    fileprivate var buildRectangleDetector: CIDetector {
        let options: [String: Any] = [CIDetectorAccuracy: CIDetectorAccuracyHigh, CIDetectorAspectRatio: 1.41]
        
        return CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: options)!
    }
    
    
    /// Calculates a comparable value of rectangle value
    /// i.e. half of perimeter
    fileprivate func featureSize(_ feature:CIRectangleFeature) -> Float {
        let p1 = feature.topLeft
        let p2 = feature.topRight
        let width = hypotf(Float(p1.x - p2.x), Float(p1.y - p2.y))
        
        let p3 = feature.bottomLeft
        let height = hypotf(Float(p1.x - p3.x), Float(p1.y - p3.y))
        
        return width + height
    }
    
    fileprivate func largestFeature(_ list:[CIRectangleFeature]) -> CIRectangleFeature? {
        if list.count == 0 {
            return nil
        }
        if list.count == 1 {
            return list[0]
        }
        
        let sorted = list.sorted { a,b in
            return featureSize(a) > featureSize(b)
        }
        
        return sorted.first
    }
    
    
    func detectRectangularFeature(_ image: CIImage) -> CIRectangleFeature? {
        let features = detector.features(in: image)
        return largestFeature(features as! [CIRectangleFeature])
    }
}

extension CAShapeLayer {
    
    func draw(inRect previewRect: CGRect, ciImage: CIImage, biggestRectangleFeature: CIRectangleFeature) {
        let imageRect: CGRect = ciImage.extent
        let shapeFillColor = UIColor.blue.withAlphaComponent(0.3).cgColor
        let shapeStrokeColor = UIColor.blue.cgColor
        
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
            //            animation.delegate = self
            
            self.add(animation, forKey: animation.keyPath)
        }
        
        self.fillColor = shapeFillColor
        self.strokeColor = shapeStrokeColor
        self.lineWidth = 1.5
        self.path = path.cgPath
    }
    
    func hide() {
        self.fillColor = UIColor.clear.cgColor
        self.strokeColor = UIColor.clear.cgColor
        self.lineWidth = 0.0
        self.removeAnimation(forKey: "path")
    }
}

