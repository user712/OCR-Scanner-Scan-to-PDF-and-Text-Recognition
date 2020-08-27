//
//  FeatureImage.swift
//  Scanner
//
//   on 1/23/17.
//   
//

import UIKit
import CoreGraphics

class CDImageRectangleDetector: NSObject {
    
    static let sharedDetector = CDImageRectangleDetector()
    
    
    private override init() {
        super.init()
    }
    
    func highAccuracyRectangleDetector() -> CIDetector {
        return CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])!
    }
    
    func featuresFromImage(_ ciImage: CIImage) -> [CIFeature] {
        return highAccuracyRectangleDetector().features(in: ciImage)
    }
    
    func biggestRectangleInRectangles(_ rectangles: [CIFeature]) -> CIRectangleFeature? {
        if let featuresRectanges = rectangles as? [CIRectangleFeature],
            var biggestRectangle = featuresRectanges.first {
            
            var halfPerimeterValue: CGFloat = 0.0
            
            for rectangle in featuresRectanges {
                let p1 = rectangle.topLeft
                let p2 = rectangle.topRight
                let width = hypot(p1.x - p2.x, p1.y - p2.y)
                
                let p3 = rectangle.bottomLeft
                let height = hypot(p1.x - p3.x, p1.y - p3.y)
                
                let currentHalfPermiterValue = height + width
                
                if halfPerimeterValue < currentHalfPermiterValue {
                    halfPerimeterValue = currentHalfPermiterValue
                    biggestRectangle = rectangle
                }
            }
            
            return biggestRectangle
        }
        
        return nil
    }
    
    func drawHighlightOverlayForPoints(_ image: CIImage, feature: CIRectangleFeature) -> CIImage {
        var overlay = CIImage(color: CIColor(red: 74.0/255.0, green: 144.0/255.0, blue: 226.0/255.0, alpha: 0.6))
        overlay = overlay.cropping(to: image.extent)
        overlay = overlay.applyingFilter("CIPerspectiveTransformWithExtent",
                                         withInputParameters: [
                                            "inputExtent": CIVector(cgRect: image.extent),
                                            "inputTopLeft": CIVector(cgPoint: feature.topLeft),
                                            "inputTopRight": CIVector(cgPoint: feature.topRight),
                                            "inputBottomLeft": CIVector(cgPoint: feature.bottomLeft),
                                            "inputBottomRight": CIVector(cgPoint: feature.bottomRight)])
        
        return overlay.compositingOverImage(image)
    }
}

class FeatureImage {
    
    // MARK: - Properties
    
    static var featureDetector: CIDetector!
    static let main = FeatureImage()
    
    
    // MARK: - Initializers
    
    private init() {
        FeatureImage.featureDetector = FeatureImage.prepareRectangleDetector()
    }
    
    
    // MARK: - Deinitializers
    
    deinit {
        // TODO: - Clean garbage
        FeatureImage.featureDetector = nil
    }
}


extension FeatureImage {
    
    static func prepareRectangleDetector() -> CIDetector? {
        return CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
    }
    
    static func featuresFromImage(_ ciImage: CIImage) -> [CIFeature] {
        self.featureDetector = FeatureImage.prepareRectangleDetector()
        
        return featureDetector.features(in: ciImage)
    }
    
    static func biggestRectangle(_ rectangles: [CIFeature]) -> CIRectangleFeature? {
        if let featuresRectanges = rectangles as? [CIRectangleFeature],
            var biggestRectangle = featuresRectanges.first {
            
            var halfPerimeterValue: CGFloat = 0.0
            
            for rectangle in featuresRectanges {
                let p1 = rectangle.topLeft
                let p2 = rectangle.topRight
                let width = hypot(p1.x - p2.x, p1.y - p2.y)
                
                let p3 = rectangle.bottomLeft
                let height = hypot(p1.x - p3.x, p1.y - p3.y)
                
                let currentHalfPermiterValue = height + width
                
                if halfPerimeterValue < currentHalfPermiterValue {
                    halfPerimeterValue = currentHalfPermiterValue
                    biggestRectangle = rectangle
                }
            }
            
            return biggestRectangle
        }
        
        return nil
    }
    
    /*
    static func overlayImageForFeatureInImage(_ image: CIImage, feature: CIRectangleFeature) -> CIImage! {
        var overlay = CIImage(color: CIColor(color: UIColor.darkSkyBlue.withAlphaComponent(0.3)))
        
        /// #1 Border
        let localFrameColor = UIColor.darkSkyBlue
        let fifteen: CGFloat = 15
        overlay = overlay.cropping(to: image.extent)
        
        var leftBorder = CIImage(color: CIColor(color: localFrameColor))
        var innerFrame = overlay.extent
        innerFrame.size.width = fifteen
        leftBorder = leftBorder.cropping(to: innerFrame)
        
        var resultCIImage = leftBorder.compositingOverImage(overlay)
        
        var rightBorder = CIImage(color: CIColor(color: localFrameColor))
        innerFrame = overlay.extent
        innerFrame.origin.x = innerFrame.size.width - fifteen
        innerFrame.size.width = fifteen
        rightBorder = rightBorder.cropping(to: innerFrame)
        
        resultCIImage = rightBorder.compositingOverImage(resultCIImage)
        
        var botBorder = CIImage(color: CIColor(color: localFrameColor))
        innerFrame = overlay.extent
        innerFrame.size.height = fifteen
        botBorder = botBorder.cropping(to: innerFrame)
        
        resultCIImage = botBorder.compositingOverImage(resultCIImage)
        
        var topBorder = CIImage(color: CIColor(color: localFrameColor))
        innerFrame = overlay.extent
        innerFrame.origin.y = innerFrame.size.height - fifteen
        innerFrame.size.height = fifteen
        topBorder = topBorder.cropping(to: innerFrame)
        
        resultCIImage = topBorder.compositingOverImage(resultCIImage)
        
        overlay = resultCIImage.applyingFilter("CIPerspectiveTransformWithExtent",
                                               withInputParameters: ["inputExtent": CIVector(cgRect: image.extent),
                                                                     "inputTopLeft": CIVector(cgPoint: feature.topLeft),
                                                                     "inputTopRight": CIVector(cgPoint: feature.topRight),
                                                                     "inputBottomLeft": CIVector(cgPoint: feature.bottomLeft),
                                                                     "inputBottomRight": CIVector(cgPoint: feature.bottomRight)])
        
        return overlay.compositingOverImage(image)
    }*/
    
    static func overlayImageForFeatureInImage(_ image: CIImage, feature: CIRectangleFeature) -> CIImage! {
        var overlay = CIImage(color: CIColor(color: UIColor.darkSkyBlue.withAlphaComponent(0.3)))
        overlay = overlay.cropping(to: image.extent)
        
        let ciImageSize = overlay.extent.size
        var transform = CGAffineTransform(scaleX: 1, y: -1)
        transform = transform.translatedBy(x: 0, y: -ciImageSize.height)
        
        
        
        // Apply the transform to convert the coordinates
        var faceViewBounds = feature.bounds.applying(transform)
        
        // Calculate the actual position and size of the rectangle in the image view
        let viewSize = image.extent.size
        let scale = min(viewSize.width / ciImageSize.width,
                        viewSize.height / ciImageSize.height)
        let offsetX = (viewSize.width - ciImageSize.width * scale) / 2
        let offsetY = (viewSize.height - ciImageSize.height * scale) / 2
        
        faceViewBounds = faceViewBounds.applying(CGAffineTransform(scaleX: scale, y: scale))
        faceViewBounds.origin.x += offsetX
        faceViewBounds.origin.y += offsetY
        
        let resultCIImage = overlay.compositingOverImage(overlay)
        /*
        overlay = resultCIImage.applyingFilter("CIPerspectiveTransformWithExtent",
                                               withInputParameters: ["inputExtent": CIVector(cgRect: image.extent),
                                                                     "inputTopLeft": CIVector(cgPoint: feature.topLeft),
                                                                     "inputTopRight": CIVector(cgPoint: feature.topRight),
                                                                     "inputBottomLeft": CIVector(cgPoint: feature.bottomLeft),
                                                                     "inputBottomRight": CIVector(cgPoint: feature.bottomRight)])
        */
        return overlay.compositingOverImage(resultCIImage)
    }
    
    static func perspectiveCorrectedImage(_ image: CIImage, feature: CIRectangleFeature) -> CIImage {
        return image.applyingFilter("CIPerspectiveCorrection", withInputParameters: [
            "inputTopLeft":    CIVector(cgPoint: feature.topLeft),
            "inputTopRight":   CIVector(cgPoint: feature.topRight),
            "inputBottomLeft": CIVector(cgPoint: feature.bottomLeft),
            "inputBottomRight":CIVector(cgPoint: feature.bottomRight)])
    }
    
    static func drawHighlightOverlayForPoints(_ image: CIImage, feature: CIRectangleFeature) -> CIImage {
        var overlay = CIImage(color: CIColor(red: 74.0/255.0, green: 144.0/255.0, blue: 226.0/255.0, alpha: 0.6))
        overlay = overlay.cropping(to: image.extent)
        overlay = overlay.applyingFilter("CIPerspectiveTransformWithExtent",
                                         withInputParameters: [
                                            "inputExtent": CIVector(cgRect: image.extent),
                                            "inputTopLeft": CIVector(cgPoint: feature.topLeft),
                                            "inputTopRight": CIVector(cgPoint: feature.topRight),
                                            "inputBottomLeft": CIVector(cgPoint: feature.bottomLeft),
                                            "inputBottomRight": CIVector(cgPoint: feature.bottomRight)])
        
        return overlay.compositingOverImage(image)
    }
}
