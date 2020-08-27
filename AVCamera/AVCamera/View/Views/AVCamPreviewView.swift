//
//  AVCamPreviewView.swift
//  AVCamera
//
//  Created  on 3/7/17.
//  Copyright © 2017 A. 
//

import UIKit
import AVFoundation

class AVCamPreviewView: UIView {

    // MARK: - Properties
    
    var session: AVCaptureSession? {
        get {
            return (self.layer as! AVCaptureVideoPreviewLayer).session
        }
        set (session) {
            (self.layer as! AVCaptureVideoPreviewLayer).session = session
        }
    }
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }

}
