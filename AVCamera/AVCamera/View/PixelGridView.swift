//
//  PixelGridView.swift
//  AVCamera
//
//  Created by Developer on 3/9/17.
//  Copyright © 2017 A. 
//

import UIKit

protocol PixelGridViewDelegate: class {
    func pixelGridViewDidRedraw(view: PixelGridView)
}

class PixelGridView: UIImageView {

    // MARK: - Nested types
    
    enum RenderingMode {
        case logicalPixels // Render to the "logical" pixel resolution (i.e. 3x on the iPhone 6 Plus)
        case nativePixels  // Try to render to "hardware" pixel resolution (i.e. with screen.nativeScale on the iPhone 6 Plus)
    }
    
    enum GridVariant {
        case variableSpacing
        case tightSpacing
    }

    
    // MARK: - Properties
    
    weak var delegate: PixelGridViewDelegate?
    
    var renderingMode: RenderingMode = .logicalPixels {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var gridVariant: GridVariant = .variableSpacing {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var renderScaleFactor: CGFloat {
        if renderingMode == .nativePixels {
            return window?.screen.nativeScale ?? contentScaleFactor
        } else {
            return contentScaleFactor
        }
    }
    
    // Scales from points to pixels
    var upscaleTransform: CGAffineTransform {
        let scaleFactor = renderScaleFactor
        return CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
    }
    
    // Scales from pixels to points
    var downscaleTransform: CGAffineTransform {
        return upscaleTransform.inverted()
    }
    
    
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentMode = .scaleAspectFill
        self.layer.minificationFilter = kCAFilterTrilinear
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        self.clipsToBounds = true
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    
    // MARK: - Draw
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.delegate?.pixelGridViewDidRedraw(view: self)
    }
}
