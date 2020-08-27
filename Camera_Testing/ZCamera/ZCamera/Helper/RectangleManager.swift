//
//  RectangleManager.swift
//  ZCamera
//
//  Created by Developer on 3/10/17.
//  Copyright © . 
//

import UIKit
import AVFoundation

class RectangleManager {
    
    // MARK: - Properties
    
    fileprivate var detector: CIDetector!
    
    
    
    // MARK: - Initializers
    
    init() {
        detector = self.buildRectangleDetector
    }
}


// MARK: - Build Rectangle Detector

extension RectangleManager {
    
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


extension RectangleManager {
    
    func quadfromImage(_ ciImage: CIImage, quardView: QuadrilateralShowView) -> [CGPoint]? {
        
        /*
        guard let ref = image.cgImage else {
            return nil
        }
        
        let ciimage = CIImage(cgImage: ref)
        let options = [CIDetectorAccuracy: CIDetectorAccuracyHigh,
                       CIDetectorTracking: NSNumber(value: 1.0 as Float)] as [String : Any]
        let context = CIContext(options:[kCIContextUseSoftwareRenderer : true])
        let detector = CIDetector(ofType: CIDetectorTypeRectangle, context: context, options: options)
        let res = detector?.features(in: ciimage)
        if (res?.count)! < 1 {
            return nil
        }
        */
        
        let h = ciImage.extent.size.height
        if let rectangle = self.detectRectangularFeature(ciImage) { /// res?[0] as! CIRectangleFeature
            let topLeft = CGPoint(x: rectangle.topLeft.x, y: h - rectangle.topLeft.y)
            let topRight = CGPoint(x: rectangle.topRight.x, y: h - rectangle.topRight.y)
            let bottomLeft = CGPoint(x: rectangle.bottomLeft.x, y: h - rectangle.bottomLeft.y)
            let bottomRight = CGPoint(x: rectangle.bottomRight.x, y: h - rectangle.bottomRight.y)
            return [topLeft,topRight,bottomLeft,bottomRight]
        }
        
        DispatchQueue.main.async {
            quardView.hidedrawRectanglePath()
            quardView.setNeedsDisplay()
        }
        
        return nil
    }
}




extension RectangleManager {
    
    func imageFromSampleBuffer(_ sampleBuffer: CMSampleBuffer) -> UIImage {
        // Get a CMSampleBuffer's Core Video image buffer for the media data
        let buffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        guard let imageBuffer = buffer else{
            return UIImage()
        }
        // Lock the base address of the pixel buffer
        CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        // Get the number of bytes per row for the pixel buffer
        let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)
        
        // Get the number of bytes per row for the pixel buffer
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
        // Get the pixel buffer width and height
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        
        // Create a device-dependent RGB color space
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        // Create a bitmap graphics context with the sample buffer data
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
        let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        // Create a Quartz image from the pixel data in the bitmap graphics context
        let quartzImage = context?.makeImage();
        // Unlock the pixel buffer
        CVPixelBufferUnlockBaseAddress(imageBuffer,CVPixelBufferLockFlags(rawValue: 0));
        
        // Create an image object from the Quartz image
        let image = UIImage(cgImage: quartzImage!)
        
        return image
    }
    
    func fixImageOrientation(_ src:UIImage) -> UIImage {
        
        if src.imageOrientation == UIImageOrientation.up {
            return src
        }
        
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        switch src.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: src.size.width, y: src.size.height)
            transform = transform.rotated(by: CGFloat(M_PI))
            break
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: src.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(M_PI_2))
            break
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: src.size.height)
            transform = transform.rotated(by: CGFloat(-M_PI_2))
            break
        case .up, .upMirrored:
            break
        }
        
        switch src.imageOrientation {
        case .upMirrored, .downMirrored:
            transform.translatedBy(x: src.size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
            break
        case .leftMirrored, .rightMirrored:
            transform.translatedBy(x: src.size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        }
        
        let ctx:CGContext = CGContext(data: nil, width: Int(src.size.width), height: Int(src.size.height), bitsPerComponent: src.cgImage!.bitsPerComponent, bytesPerRow: 0, space: src.cgImage!.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        
        ctx.concatenate(transform)
        
        switch src.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(src.cgImage!, in: CGRect(x: 0, y: 0, width: src.size.height, height: src.size.width))
            break
        default:
            ctx.draw(src.cgImage!, in: CGRect(x: 0, y: 0, width: src.size.width, height: src.size.height))
            break
        }
        
        let cgimg: CGImage = ctx.makeImage()!
        let img = UIImage(cgImage: cgimg)
        
        return img
    }
}










