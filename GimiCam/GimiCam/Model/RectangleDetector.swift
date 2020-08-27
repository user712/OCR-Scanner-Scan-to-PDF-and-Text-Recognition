//
//  RectangleDetector.swift
//  GimiCam
//
//  Created  on 3/4/17.
//  Copyright © 2017 A. 
//

import UIKit
import AVFoundation

class RectangleDetector {

    // MARK: - Properties
    
    fileprivate var detector: CIDetector!
    fileprivate var counter = 0
    fileprivate var borderDetectLastRectangleFeature: CIRectangleFeature?
    fileprivate var timeKeeper: Timer?
    fileprivate var borderDetectFrame = false
   
    
    // MARK: - Initializers
    
    init() {
        detector = self.buildRectangleDetector
        self.timeKeeper = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(enableBorderDetection), userInfo: nil, repeats: true)
        RunLoop.current.add(self.timeKeeper!, forMode: RunLoopMode.commonModes)
    }
}


// MARK: - Build Rectangle Detector

extension RectangleDetector {
    
    fileprivate var buildRectangleDetector: CIDetector {
        let options: [String: Any] = [CIDetectorAccuracy: CIDetectorAccuracyHigh, CIDetectorAspectRatio: 1.41]
        
        return CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: options)!
    }
    
    /// Calculates a comparable value of rectangle value
    /// i.e. half of perimeter
    fileprivate func featureSize(_ feature: CIRectangleFeature) -> Float {
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


// MARK: - Border Detections

extension RectangleDetector {
    
    @objc fileprivate func enableBorderDetection() {
        self.borderDetectFrame = true
    }
}


// MARK: - Draw rectangle layer

extension RectangleDetector {
    
    func drawRectangleLayer(inRect layer: CAShapeLayer, previewSize: CGSize, cameraSessionResolution: CGSize, biggestRectangleFeature: CIRectangleFeature) {
        //        let imageRect: CGRect = ciImage.extent
        let shapeFillColor = UIColor.blue.withAlphaComponent(0.3).cgColor
        let shapeStrokeColor = UIColor.blue.cgColor
        
        /// find ratio between the video preview rect and the image rect; rectangle feature coordinates are relative to the CIImage
        /// AVCaptureSessionPreset1920x1080
        let deltaX: CGFloat = previewSize.width / 1920
        let deltaY: CGFloat = previewSize.height / 1080
        
        /// transform to UIKit coordinate system
        var transform = CGAffineTransform(translationX: 0.0, y: previewSize.height)
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
        
        if layer.path != path.cgPath {
            let animation = CABasicAnimation(keyPath: "path")
            animation.fromValue = layer.path
            animation.toValue   = path.cgPath
            animation.duration  = 0.25
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            /// kCAMediaTimingFunctionEaseOut /// kCAMediaTimingFunctionEaseInEaseOut
            animation.isRemovedOnCompletion = false
            animation.fillMode = kCAFillModeBoth
            
            layer.add(animation, forKey: animation.keyPath)
        }
        
        layer.fillColor = shapeFillColor
        layer.strokeColor = shapeStrokeColor
        layer.lineWidth = 1.5
        layer.path = path.cgPath
    }
    
    func hideRectangleLayer(_ layer: CAShapeLayer) {
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.clear.cgColor
        layer.lineWidth = 0.0
        layer.removeAnimation(forKey: "path")
    }
}


// MARK: - CameraRectangleDelegate

extension RectangleDetector: CameraRectangleDelegate {
    
    func camera(_ camera: VideoCamera, didOutputFrom sampleBuffer: CameraBuffer!, rectangleLayer: CAShapeLayer) {
        counter += 1
        print(counter)
//        
//        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
////            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetHeight(pixelBuffer), height: CVPixelBufferGetWidth(pixelBuffer))
//            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
//            
//            if self.borderDetectFrame {
//                self.borderDetectLastRectangleFeature = self.detectRectangularFeature(ciImage)
//                self.borderDetectFrame = false
//            }
//            
//            let previewSize = camera.overlayView.frame.size
//            let cameraLayer = camera.overlayView.layer
//            let cameraSize = camera.getCaptureResolution()
//            /// 1920x1080
//            /// AVCaptureSessionPreset352x288
//            
//            if let lastRectFeature = self.borderDetectLastRectangleFeature {
//                self.drawRectangleLayer(inRect: rectangleLayer, previewSize: previewSize, cameraSessionResolution: cameraSize, biggestRectangleFeature: lastRectFeature)
//                cameraLayer.setNeedsDisplay()
//            } else {
//                self.hideRectangleLayer(rectangleLayer)
//            }
//        }
        
        
        
        
        
    }
}




extension RectangleDetector {
    
    func detectRectangles(_ image: CIImage) -> [CIRectangleFeature]? {
        let options: [String: Any] = [CIDetectorAccuracy : CIDetectorAccuracyHigh]
        let rectDetector = CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: options)
        
        return rectDetector?.features(in: image) as? [CIRectangleFeature]
    }
}
