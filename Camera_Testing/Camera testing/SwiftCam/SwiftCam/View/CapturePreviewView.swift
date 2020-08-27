//
//  CapturePreviewView.swift
//  SwiftCam
//
//  Created by Developer on 3/3/17.
//  Copyright © . 
//

import UIKit
import AVFoundation

/**
 A UIView subclass that overrides the default `layerClass` with `AVCaptureVideoPreviewLayer.self`.
 */
class CapturePreviewView: UIView {
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    fileprivate func setUp() {
        backgroundColor = .black
    }
}
