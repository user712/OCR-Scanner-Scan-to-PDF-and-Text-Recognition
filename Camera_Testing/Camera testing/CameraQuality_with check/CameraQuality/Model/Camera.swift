//
//  Camera.swift
//  CameraQuality
//
//  Created  on 2/28/17.
//  Copyright © 2017 
//

import UIKit
import AVFoundation

typealias CaptureCompletion = (UIImage) -> ()

let deviceType = UIDevice.current.userInterfaceIdiom

protocol CameraDelegate: class {
    
}

class Camera: NSObject {

    // MARK: - Properties
    
    let superView: UIView
    
    fileprivate let captureSession = AVCaptureSession()
    fileprivate var captureDevice: AVCaptureDevice!
    fileprivate var isTakePhoto = false
    fileprivate var previewLayer: CALayer!
    fileprivate var captureCompletion: CaptureCompletion?
    
    
    // MARK: - Initializers
    
    init(superView: UIView, captureCompletion: CaptureCompletion?) {
        self.superView = superView
        self.captureCompletion = captureCompletion
        super.init()
        self.prepareCamera()
    }
    
    
    // MARK: - Deinitializers
    
    deinit {
        
    }
    
    
    // MARK: - LayoutSubview
    
    func previewlayerLayout() {
        self.previewLayer.frame = self.superView.layer.frame
    }
}


extension Camera {
    
    fileprivate func prepareCamera() {
        /// Change sessionPreset on iPad & iPhone
        
        self.checkSessionPreset()
        
        if #available(iOS 10.0, *) {
            if let aviableDevices = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .back).devices {
                captureDevice = aviableDevices.first
                beginSession()
            }
        } else {
            // Fallback on earlier versions
            if let aviableDevices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as? [AVCaptureDevice] {
                captureDevice = aviableDevices.first
                beginSession()
            }
        }
    }
    
    fileprivate func beginSession() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(captureDeviceInput)
        } catch {
            print(error.localizedDescription)
        }
        
        if let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) {
            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            self.previewLayer = previewLayer
            self.superView.layer.addSublayer(self.previewLayer)
            self.previewLayer.frame = self.superView.layer.frame
            captureSession.startRunning()
            
            let dataOutput = AVCaptureVideoDataOutput()
            dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString): NSNumber(value: kCVPixelFormatType_32BGRA)]
            dataOutput.alwaysDiscardsLateVideoFrames = true
            
            if captureSession.canAddOutput(dataOutput) {
                captureSession.addOutput(dataOutput)
            }
            
            captureSession.commitConfiguration()
            
            let queue = DispatchQueue(label: "com.mihailsalari.captureQueue")
            dataOutput.setSampleBufferDelegate(self, queue: queue)
        }
    }
    
    fileprivate func checkSessionPreset() {
        if #available(iOS 9.0, *) {
            if captureSession.canSetSessionPreset(AVCaptureSessionPresetPhoto) {
                self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto
                print("Camera on this device use AVCaptureSessionPresetPhoto")
                
            } else if captureSession.canSetSessionPreset(AVCaptureSessionPresetHigh) {
                self.captureSession.sessionPreset = AVCaptureSessionPresetHigh
                print("Camera on this device use AVCaptureSessionPresetHigh")
                
            } else if captureSession.canSetSessionPreset(AVCaptureSessionPresetMedium) {
                self.captureSession.sessionPreset = AVCaptureSessionPresetMedium
                print("Camera on this device use AVCaptureSessionPresetMedium")
                
            } else if captureSession.canSetSessionPreset(AVCaptureSessionPresetLow) {
                self.captureSession.sessionPreset = AVCaptureSessionPresetLow
                print("Camera on this device use AVCaptureSessionPresetLow")
                
            } else if captureSession.canSetSessionPreset(AVCaptureSessionPreset352x288) {
                self.captureSession.sessionPreset = AVCaptureSessionPreset352x288
                print("Camera on this device use AVCaptureSessionPreset352x288")
                
            } else if captureSession.canSetSessionPreset(AVCaptureSessionPreset640x480) {
                self.captureSession.sessionPreset = AVCaptureSessionPreset640x480
                print("Camera on this device use AVCaptureSessionPreset640x480")
                
            } else if captureSession.canSetSessionPreset(AVCaptureSessionPreset1280x720) {
                self.captureSession.sessionPreset = AVCaptureSessionPreset1280x720
                print("Camera on this device use AVCaptureSessionPreset1280x720")
                
            } else if captureSession.canSetSessionPreset(AVCaptureSessionPreset1920x1080) {
                self.captureSession.sessionPreset = AVCaptureSessionPreset1920x1080
                print("Camera on this device use AVCaptureSessionPreset1920x1080")
                
            } else if captureSession.canSetSessionPreset(AVCaptureSessionPreset3840x2160) {
                self.captureSession.sessionPreset = AVCaptureSessionPreset3840x2160
                print("Camera on this device use AVCaptureSessionPreset3840x2160")
                
            } else if captureSession.canSetSessionPreset(AVCaptureSessionPresetiFrame960x540) {
                self.captureSession.sessionPreset = AVCaptureSessionPresetiFrame960x540
                print("Camera on this device use AVCaptureSessionPresetiFrame960x540")
                
            } else if captureSession.canSetSessionPreset(AVCaptureSessionPresetiFrame1280x720) {
                self.captureSession.sessionPreset = AVCaptureSessionPresetiFrame1280x720
                print("Camera on this device use AVCaptureSessionPresetiFrame1280x720")
                
            } else if captureSession.canSetSessionPreset(AVCaptureSessionPresetInputPriority) {
                self.captureSession.sessionPreset = AVCaptureSessionPresetInputPriority
                print("Camera on this device use AVCaptureSessionPresetInputPriority")
            }
        } else {
            /// Fallback on earlier versions
            if captureSession.canSetSessionPreset(AVCaptureSessionPresetPhoto) {
                self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto
                print("Camera on this device use AVCaptureSessionPresetPhoto")
                
            } else if captureSession.canSetSessionPreset(AVCaptureSessionPresetHigh) {
                self.captureSession.sessionPreset = AVCaptureSessionPresetHigh
                print("Camera on this device use AVCaptureSessionPresetHigh")
                
            } else if captureSession.canSetSessionPreset(AVCaptureSessionPresetMedium) {
                self.captureSession.sessionPreset = AVCaptureSessionPresetMedium
                print("Camera on this device use AVCaptureSessionPresetMedium")
                
            } else if captureSession.canSetSessionPreset(AVCaptureSessionPresetLow) {
                self.captureSession.sessionPreset = AVCaptureSessionPresetLow
                print("Camera on this device use AVCaptureSessionPresetLow")
                
            } else if captureSession.canSetSessionPreset(AVCaptureSessionPreset352x288) {
                self.captureSession.sessionPreset = AVCaptureSessionPreset352x288
                print("Camera on this device use AVCaptureSessionPreset352x288")
                
            } else if captureSession.canSetSessionPreset(AVCaptureSessionPreset640x480) {
                self.captureSession.sessionPreset = AVCaptureSessionPreset640x480
                print("Camera on this device use AVCaptureSessionPreset640x480")
                
            } else if captureSession.canSetSessionPreset(AVCaptureSessionPreset1280x720) {
                self.captureSession.sessionPreset = AVCaptureSessionPreset1280x720
                print("Camera on this device use AVCaptureSessionPreset1280x720")
                
            } else if captureSession.canSetSessionPreset(AVCaptureSessionPreset1920x1080) {
                self.captureSession.sessionPreset = AVCaptureSessionPreset1920x1080
                print("Camera on this device use AVCaptureSessionPreset1920x1080")
                
            } else if captureSession.canSetSessionPreset(AVCaptureSessionPresetiFrame960x540) {
                self.captureSession.sessionPreset = AVCaptureSessionPresetiFrame960x540
                print("Camera on this device use AVCaptureSessionPresetiFrame960x540")
                
            } else if captureSession.canSetSessionPreset(AVCaptureSessionPresetiFrame1280x720) {
                self.captureSession.sessionPreset = AVCaptureSessionPresetiFrame1280x720
                print("Camera on this device use AVCaptureSessionPresetiFrame1280x720")
                
            } else if captureSession.canSetSessionPreset(AVCaptureSessionPresetInputPriority) {
                self.captureSession.sessionPreset = AVCaptureSessionPresetInputPriority
                print("Camera on this device use AVCaptureSessionPresetInputPriority")
            }
        }
    }
}


extension Camera {

    func startCaptureSession() {
        if !self.captureSession.isRunning {
            self.prepareCamera()
        }
    }
    
    func stopCaptureSession() {
        self.captureSession.stopRunning()
        
        if let inputs = captureSession.inputs as? [AVCaptureInput] {
            for input in inputs {
                self.captureSession.removeInput(input)
            }
        }
    }
}


// MARK: - Get Image

extension Camera {

    fileprivate func getImageFromSampleBuffer(_ buffer: CMSampleBuffer) -> UIImage? {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) {
            if #available(iOS 9.0, *) {
                let ciImage = CIImage(cvImageBuffer: pixelBuffer)
                let context = CIContext()
                let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
                
                if let image = context.createCGImage(ciImage, from: imageRect) {
                    return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right)
                }
                
            } else {
                // Fallback on earlier versions
                let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
                let context = CIContext()
                let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
                
                if let image = context.createCGImage(ciImage, from: imageRect) {
                    return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right)
                }
            }
        }
        
        return nil
    }
}


// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension Camera: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        if isTakePhoto {
            isTakePhoto = false
            
            /// get image from sample buffer
            if let image = self.getImageFromSampleBuffer(sampleBuffer) {
                DispatchQueue.main.async { [unowned self] in
                    self.captureCompletion?(image)
                }
            }
        }
    }
    
    func captureImage(_ completion: @escaping (UIImage) -> ()) {
        self.isTakePhoto = true
        self.captureCompletion = { image in
            completion(image)
        }
    }
}















