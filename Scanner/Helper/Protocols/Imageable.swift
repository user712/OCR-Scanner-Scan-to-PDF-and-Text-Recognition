//
//  Imageable.swift
//  Scanner
//
//  
//   
//

import UIKit
import ImageIO
import CoreImage
import QuartzCore

protocol Imageable {
    func processImage(_ image: UIImage) -> UIImage?
    func resizeData(_ data: Data, withSize size: CGSize) -> UIImage?
}


extension Imageable {
    
    func processImage(_ image: UIImage) -> UIImage? {
        
        // Create a `CGColorSpace` and `CGBitmapInfo` value that is appropriate for the device.
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        
        // Create a bitmap context of the same size as the image.
        let imageWidth = Int(Float(image.size.width))
        let imageHeight = Int(Float(image.size.height))
        
        let bitmapContext = CGContext(data: nil, width: imageWidth, height: imageHeight, bitsPerComponent: 8, bytesPerRow: imageWidth * 4, space: colorSpace, bitmapInfo: bitmapInfo)
        
        // Draw the image into the graphics context.
        guard let imageRef = image.cgImage else { fatalError("Unable to get a CGImage from a UIImage.") }
        bitmapContext?.draw(imageRef, in: CGRect(origin: CGPoint.zero, size: image.size))
        
        // Create a new `CGImage` from the contents of the graphics context.
        guard let newImageRef = bitmapContext?.makeImage() else { return image }
        
        // Return a new `UIImage` created from the `CGImage`.
        return UIImage(cgImage: newImageRef)
    }
}


extension Imageable {
    
    /// Resize directly from data
    func resizeData(_ data: Data, withSize size: CGSize = CGSize(width: 200, height: 200)) -> UIImage? {
        if let imageSource = CGImageSourceCreateWithData(data as CFData, nil) {
            let options: [NSString: Any] = [
                kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height),
                kCGImageSourceCreateThumbnailFromImageAlways: true
            ]
            return CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary?).flatMap { UIImage(cgImage: $0) }
        }
        
        return nil
    }
}
