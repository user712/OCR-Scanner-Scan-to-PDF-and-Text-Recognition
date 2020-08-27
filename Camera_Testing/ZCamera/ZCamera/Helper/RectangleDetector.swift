//
//  RectangleDetector.swift
//  ZCamera
//
//  Created by Developer on 3/10/17.
//  Copyright © . 
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
    
    ///
    
    var lastTopLeft = [AnyObject]()
    var lastTopRight = [AnyObject]()
    var lastBottomLeft = [AnyObject]()
    var lastBottomRight = [AnyObject]()
    
    var topLeft = UIView()
    var topRight = UIView()
    var bottomLeft = UIView()
    var bottomRight = UIView()
    var last = [Any]()
    
    
    
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
    
    fileprivate func largestFeature(_ list: [CIRectangleFeature]) -> CIRectangleFeature? {
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
    
    func drawRectangleLayer(inRect layer: CAShapeLayer, previewRect: CGRect, imageRect: CGRect, biggestRectangleFeature: CIRectangleFeature) {
        //let imageRect: CGRect = ciImage.extent
        let shapeFillColor = UIColor.blue.withAlphaComponent(0.3).cgColor
        let shapeStrokeColor = UIColor.blue.cgColor
        
        /// find ratio between the video preview rect and the image rect; rectangle feature coordinates are relative to the CIImage
        let deltaX: CGFloat = previewRect.width / imageRect.width
        let deltaY: CGFloat = previewRect.height / imageRect.height
        
        /// transform to UIKit coordinate system
        var transform = CGAffineTransform(translationX: 0.0, y: previewRect.height)
        transform = transform.scaledBy(x: 0, y: 0)
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

extension RectangleDetector: CameraBufferDelegate {
    
    func videoCamera(_ videoCamera: VideoCamera, didOutputFrom sampleBuffer: CameraBuffer!, rectangleLayer: CAShapeLayer) {
        counter += 1
        print(counter)
        
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            
            if self.borderDetectFrame {
                self.borderDetectLastRectangleFeature = self.detectRectangularFeature(ciImage)
                self.borderDetectFrame = false
            }
            
            let rect = videoCamera.cameraView.frame.size
            let sy = rect.height / videoCamera.getCaptureResolution.height
            let sx = rect.width / videoCamera.getCaptureResolution.width
            
            let cameraRect = CGRect(x: 0, y: 0, width: sx, height: sy)
            if let lastRectFeature = self.borderDetectLastRectangleFeature {
                self.drawRectangleLayer(inRect: rectangleLayer, previewRect: videoCamera.cameraView.frame, imageRect: imageRect, biggestRectangleFeature: lastRectFeature)
                videoCamera.cameraView.layer.setNeedsDisplay()
            } else {
                self.hideRectangleLayer(rectangleLayer)
            }
        }
    }
}



//func test() {
//    let captureResolutionWidth = camera.getCaptureResolution.width
//    let captureResolutionHeight = camera.getCaptureResolution.height
//
//    let s: CGSize = camera.superView.frame.size
//    let sy: CGFloat = s.height / 352
//    let sx: CGFloat = s.width / 288
//    var bs: CGFloat = 0
//    var bestr: CIRectangleFeature!
//    let rate: CGFloat = 0.4
//
//    if let rectangles = self.detector.features(in: ciImage) as? [CIRectangleFeature] {
//        for rect in rectangles {
//            let ts: CGFloat = (rect.topRight.x - rect.topLeft.x) * (rect.topRight.y - rect.bottomRight.y)
//            if ts > bs {
//                bs = ts
//                bestr = rect
//            }
//        }
//    }
//
//    if bs > 0 {
//        lastTopLeft.append(NSValue(cgPoint: CGPoint(x: CGFloat(bestr.topLeft.y * sy), y: CGFloat(bestr.topLeft.x * sx))))
//        lastTopRight.append(NSValue(cgPoint: CGPoint(x: CGFloat(bestr.topRight.y * sy), y: CGFloat(bestr.topRight.x * sx))))
//        lastBottomRight.append(NSValue(cgPoint: CGPoint(x: CGFloat(bestr.bottomRight.y * sy), y: CGFloat(bestr.bottomRight.x * sx))))
//        lastBottomLeft.append(NSValue(cgPoint: CGPoint(x: CGFloat(bestr.bottomLeft.y * sy), y: CGFloat(bestr.bottomLeft.x * sx))))
//
//        if lastTopLeft.count > 100 {
//            lastTopLeft.remove(at: 0)
//            lastTopRight.remove(at: 0)
//            lastBottomRight.remove(at: 0)
//            lastBottomLeft.remove(at: 0)
//        }
//
//        var tlx: CGFloat = 0.0
//        var tly: CGFloat = 0.0
//        var trx: CGFloat = 0.0
//        var `try`: CGFloat = 0.0
//        var blx: CGFloat = 0.0
//        var bly: CGFloat = 0.0
//        var brx: CGFloat = 0.0
//        var bry: CGFloat = 0.0
//
//        let c: Int = lastTopLeft.count
//
//        for i in 0..<c {
//            tlx += lastTopLeft[i].cgPointValue.x / CGFloat(c) ///.cgPoint().x / c
//            tly += lastTopLeft[i].cgPointValue.y / CGFloat(c)
//            trx += lastTopRight[i].cgPointValue.x / CGFloat(c)
//            `try` += lastTopRight[i].cgPointValue.y / CGFloat(c)
//            brx += lastBottomRight[i].cgPointValue.x / CGFloat(c)
//            bry += lastBottomRight[i].cgPointValue.y / CGFloat(c)
//            blx += lastBottomLeft[i].cgPointValue.x / CGFloat(c)
//            bly += lastBottomLeft[i].cgPointValue.y / CGFloat(c)
//        }
//
//        topLeft.center = CGPoint(x: CGFloat(tlx), y: CGFloat(tly))
//        topRight.center = CGPoint(x: CGFloat(trx), y: CGFloat(`try`))
//        bottomRight.center = CGPoint(x: CGFloat(brx), y: CGFloat(bry))
//        bottomLeft.center = CGPoint(x: CGFloat(blx), y: CGFloat(bly))
//
//        CATransaction.flush()
//
//        last = [NSValue(cgPoint: CGPoint(x: CGFloat(topLeft.center.x), y: CGFloat(topLeft.center.y))), NSValue(cgPoint: CGPoint(x: CGFloat(topRight.center.x), y: CGFloat(topRight.center.y))), NSValue(cgPoint: CGPoint(x: CGFloat(bottomRight.center.x), y: CGFloat(bottomRight.center.y))), NSValue(cgPoint: CGPoint(x: CGFloat(bottomLeft.center.x), y: CGFloat(bottomLeft.center.y)))]
//
//    }
//}



/*
extension RectangleDetector {
    
    /// Prea mic
    func drawRectangleLayer2(inRect layer: CAShapeLayer, camera: VideoCamera, biggestRectangleFeature: CIRectangleFeature) {
        //        let imageRect: CGRect = ciImage.extent
        let shapeFillColor = UIColor.blue.withAlphaComponent(0.3).cgColor
        let shapeStrokeColor = UIColor.blue.cgColor
        
        /// find ratio between the video preview rect and the image rect; rectangle feature coordinates are relative to the CIImage
        
        
        let deltaX: CGFloat = camera.cameraView.frame.width / camera.getCaptureResolution.width
        let deltaY: CGFloat = camera.cameraView.frame.height / camera.getCaptureResolution.height
        
        /// transform to UIKit coordinate system
        var transform = CGAffineTransform(translationX: 0.0, y: camera.cameraView.frame.height)
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
}



////////// 3

extension RectangleDetector {
    
    /// netestat
    func drawRectangleLayer3(inRect layer: CAShapeLayer, camera: VideoCamera, imageRect: CGRect, biggestRectangleFeature: CIRectangleFeature) {
        let shapeFillColor = UIColor.blue.withAlphaComponent(0.3).cgColor
        let shapeStrokeColor = UIColor.blue.cgColor
        
        /// find ratio between the video preview rect and the image rect; rectangle feature coordinates are relative to the CIImage
        //        let deltaX: CGFloat = camera.superView.frame.width / imageRect.width
        //        let deltaY: CGFloat = camera.superView.frame.height / imageRect.height
        
        let deltaX: CGFloat = camera.cameraView.frame.width / imageRect.width
        print("deltaX = \(deltaX)")
        let deltaY: CGFloat = camera.cameraView.frame.height / imageRect.height
        print("deltaY = \(deltaY)")
        
        print("biggestRectangleFeature topLeft \(biggestRectangleFeature.topLeft)")
        print("biggestRectangleFeature topRight \(biggestRectangleFeature.topRight)")
        
        /// transform to UIKit coordinate system
        var transform = CGAffineTransform(translationX: 0.0, y: camera.cameraView.frame.width)
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
}

*/
