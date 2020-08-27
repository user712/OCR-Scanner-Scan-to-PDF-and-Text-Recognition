//
//  CameraView.swift
//  ZCamera
//
//  Created by Developer on 3/10/17.
//  Copyright © . 
//

import UIKit
import AVFoundation

class CameraView: UIView {
    
    // MARK: - Properties
    
    override var layer: AVCaptureVideoPreviewLayer {
        return super.layer as! AVCaptureVideoPreviewLayer
    }
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var cameraSession: AVCaptureSession {
        get {
            return self.layer.session
        }
        set {
            self.layer.session = newValue
        }
    }

    
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }
}


// MARK: - Setup View

extension CameraView {
    
    fileprivate func setupView() {
        UIApplication.shared.isIdleTimerDisabled = true
        let vlayer: AVCaptureVideoPreviewLayer =  self.layer
        vlayer.videoGravity = AVLayerVideoGravityResizeAspectFill
    }
}
