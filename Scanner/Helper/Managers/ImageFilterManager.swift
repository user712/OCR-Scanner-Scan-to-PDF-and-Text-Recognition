//
//  ImageFilterManager.swift
//  Scanner
//
//   on 1/23/17.
//   
//

import UIKit

enum ImageFilterType: Int {
    case colorful, grayScale, blackAndWhite
}

class ImageFilterManager {
    
    // MARK: - Properties
    
    var filterName = String()
    
    static let CIColorControls = "CIColorControls"
    static let CIPhotoEffectMono = "CIPhotoEffectMono"
    static let CIEdges = "CIEdges"
    
    fileprivate let inputContrast = "inputContrast"
    fileprivate let inputBrightness = "inputBrightness"
    fileprivate let inputSaturation = "inputSaturation"
    fileprivate let inputIntensity = "inputIntensity"
    fileprivate let imageFilterKCIInputImageKey = kCIInputImageKey
    
    
    
    // MARK: - Initializers
    
    init() { }
}


// MARK: - Filter methods

extension ImageFilterManager {
    
    fileprivate func contrastFilterColor(_ image: CIImage) -> CIImage {
        return CIFilter(name: ImageFilterManager.CIColorControls,
                        withInputParameters: [inputContrast: 1.0, /// was  1.1
                            imageFilterKCIInputImageKey: image])!.outputImage!
    }
    
    fileprivate func enhanceFilterBlackAndWhite(_ image: CIImage) -> CIImage {
        return CIFilter(name: ImageFilterManager.CIColorControls,
                        withInputParameters: [inputBrightness: 0.0,
                                              inputContrast: 1.14,
                                              inputSaturation: 0.0,
                                              imageFilterKCIInputImageKey: image])!.outputImage!
    }
    
    fileprivate func grayScaleFilter(_ image: CIImage) -> CIImage {
        return CIFilter(name: ImageFilterManager.CIPhotoEffectMono,
                        withInputParameters: [imageFilterKCIInputImageKey: image])!.outputImage!
    }
    
    
    /// Detection Edges, just filter
    fileprivate func edgesFilter(_ image: CIImage) -> CIImage {
        return CIFilter(name: ImageFilterManager.CIEdges, withInputParameters: [inputIntensity: 10, imageFilterKCIInputImageKey: image])!.outputImage!
    }
}


// MARK: - Public filter

extension ImageFilterManager {
    
    func filterImage(_ image: CIImage, filterType filter: VideoCameraFilterType) -> CIImage {
        switch filter {
        case .grayScale: return self.grayScaleFilter(image)
        case .blackAndWhite: return self.enhanceFilterBlackAndWhite(image)
        case .color: return self.contrastFilterColor(image)
        }
    }
}



// MARK: - Filter Image

extension ImageFilterManager {
    
    func imageFilter(_ image: UIImage, type: ImageFilterType) -> UIImage? {
        switch type {
        case .grayScale:
            return self.filteredImageWithImage(image, brightness: 0.0, contrast: 1.0, saturation: 0.0)
        case .blackAndWhite:
            return self.filteredImageWithImage(image, brightness: 0.0, contrast: 2.0, saturation: 0.0)
        case .colorful:
            return self.filteredImageWithImage(image, brightness: 0.0, contrast: 1.0, saturation: 1.0)
        }
    }
    
    fileprivate func filteredImageWithImage(_ image: UIImage, brightness: Float, contrast: Float, saturation: Float) -> UIImage? {
        let beginImage = CIImage(image: image)
        
        if let colorControlsFilter = CIFilter(name: "CIColorControls") {
            colorControlsFilter.setValue(beginImage, forKey: kCIInputImageKey)
            colorControlsFilter.setValue(NSNumber(value: brightness), forKey: "inputBrightness")
            colorControlsFilter.setValue(NSNumber(value: contrast), forKey: "inputContrast")
            colorControlsFilter.setValue(NSNumber(value: saturation), forKey: "inputSaturation")
            
            let blackAndWhite = colorControlsFilter.outputImage!
            
            if let exposureAdjustFilter = CIFilter(name: "CIExposureAdjust") {
                exposureAdjustFilter.setValue(blackAndWhite, forKey: kCIInputImageKey)
                
                if let output = exposureAdjustFilter.outputImage {
                    let context = CIContext(options: nil)
                    
                    if let cgiimage = context.createCGImage(output, from: output.extent) {
                        let newImage = UIImage(cgImage: cgiimage, scale: image.scale, orientation: image.imageOrientation)
                        
                        return newImage
                    }
                }
            }
        }
        
        return nil
    }
}
