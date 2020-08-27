//
//  Camera.swift
//  BestCam
//
//  Created by Developer on 3/3/17.
//  Copyright © . 
//

import UIKit
import AVFoundation

class Camera: NSObject {
    
    // MARK: - Properties
    
    var applyFilter: ((CIImage) -> CIImage?)?
    var videoDisplayViewBounds: CGRect!
    var renderContext: CIContext!
    let superview: UIView
    var avSession: AVCaptureSession?
    var sessionQueue: DispatchQueue!
    let previewLayer = AVCaptureVideoPreviewLayer()
    
    
    // MARK: - Initializers
    
    init(superview: UIView, applyFilterCallback: ((CIImage) -> CIImage?)?) {
        self.superview = superview
        self.applyFilter = applyFilterCallback
        renderContext = CIContext(eaglContext: EAGLContext(api: .openGLES2))
        sessionQueue = DispatchQueue(label: "AVSessionQueue", attributes: [])
        videoDisplayViewBounds = superview.bounds
        superview.layer.addSublayer(previewLayer)
        previewLayer.frame = superview.layer.bounds
    }
    // MARK: - Deinitializers
    
    deinit {
        
    }
}


extension Camera {
    
    func startFiltering() {
        // Create a session if we don't already have one
        if avSession == nil {
            do {
                avSession = try createAVSession()
            } catch {
                print(error)
            }
        }
        
        // And kick it off
        avSession?.startRunning()
    }
    
    func stopFiltering() {
        // Stop the av session
        avSession?.stopRunning()
    }
}


extension Camera {
    
    func createAVSession() throws -> AVCaptureSession {
        // Input from video camera
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        let input = try AVCaptureDeviceInput(device: device)
        
        // Start out with low quality
        let session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPresetPhoto
        
        // Output
        let videoOutput = AVCaptureVideoDataOutput()
        
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable: kCVPixelFormatType_32BGRA]
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        
        // Join it all together
        session.addInput(input)
        session.addOutput(videoOutput)
        
        return session
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension Camera: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
        // Need to shimmy this through type-hell
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        // Force the type change - pass through opaque buffer
        let opaqueBuffer = Unmanaged<CVImageBuffer>.passUnretained(imageBuffer!).toOpaque()
        let pixelBuffer = Unmanaged<CVPixelBuffer>.fromOpaque(opaqueBuffer).takeUnretainedValue()
        
        let sourceImage = CIImage(cvPixelBuffer: pixelBuffer, options: nil)
        
        
        
//        superview.setNeedsDisplay()
    }
}
