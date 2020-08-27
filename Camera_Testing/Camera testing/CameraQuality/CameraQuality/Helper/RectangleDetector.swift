//
//  RectangleDetector.swift
//  CameraQuality
//
//  Created by Developer on 3/1/17.
//  Copyright © 2017 
//

import Foundation
import AVKit
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


extension RectangleDetector {
    
    fileprivate func overlayFeature(_ rectFeature: CIRectangleFeature?, image: CIImage) -> CIImage {
        if let feature = rectFeature {
            return drawHighlightOverlayForPoints(image,
                                                 topLeft: feature.topLeft,
                                                 topRight: feature.topRight,
                                                 bottomLeft: feature.bottomLeft,
                                                 bottomRight: feature.bottomRight)
        } else {
            return image
        }
    }
    
    fileprivate func drawHighlightOverlayForPoints(_ image: CIImage, topLeft: CGPoint, topRight: CGPoint,
                                                   bottomLeft: CGPoint, bottomRight: CGPoint) -> CIImage {
        var overlay = CIImage(color: CIColor(red: 1.0, green: 0, blue: 0, alpha: 0.5))
        overlay = overlay.cropping(to: image.extent)
        overlay = overlay.applyingFilter("CIPerspectiveTransformWithExtent",
                                         withInputParameters: [
                                            "inputExtent": CIVector(cgRect: image.extent),
                                            "inputTopLeft": CIVector(cgPoint: topLeft),
                                            "inputTopRight": CIVector(cgPoint: topRight),
                                            "inputBottomLeft": CIVector(cgPoint: bottomLeft),
                                            "inputBottomRight": CIVector(cgPoint: bottomRight)
            ])
        return overlay.compositingOverImage(image)
    }
    
    fileprivate func correctPerspectiveFeature(_ feature: CIRectangleFeature, image: CIImage) -> CIImage {
        let params: [String: Any] = [
            "inputTopLeft": CIVector(cgPoint: feature.topLeft),
            "inputTopRight": CIVector(cgPoint: feature.topRight),
            "inputBottomLeft": CIVector(cgPoint: feature.bottomLeft),
            "inputBottomRight": CIVector(cgPoint: feature.bottomRight),
            ]
        
        return image.applyingFilter("CIPerspectiveCorrection", withInputParameters: params)
    }
}


extension CIImage {
    
    var contrastFilter: CIImage {
        return CIFilter(name: "CIColorControls", withInputParameters: ["inputContrast":1.1, kCIInputImageKey: self])!.outputImage!
    }
    
    var enhanceFilter: CIImage {
        return CIFilter(name: "CIColorControls", withInputParameters: ["inputBrightness":0.0, "inputContrast":1.14, "inputSaturation":0.0, kCIInputImageKey: self])!.outputImage!
    }
    
    var contrastFilterColor: CIImage {
        return CIFilter(name: "CIColorControls",
                        withInputParameters: [kCIInputContrastKey: 1.1, /// was  1.1
                            kCIInputImageKey: self])!.outputImage!
    }
    
    fileprivate func blackAndWhite(_ image: CIImage) -> CIImage {
        return CIFilter(name: "CIColorControls",
                        withInputParameters: [kCIInputBrightnessKey: 0.0,
                                              kCIInputContrastKey: 1.14,
                                              kCIInputSaturationKey: 0.0,
                                              kCIInputImageKey: image])!.outputImage!
    }
    
    var grayScaleFilter: CIImage {
        return CIFilter(name: "CIPhotoEffectMono",
                        withInputParameters: [kCIInputImageKey: self])!.outputImage!
    }
}
