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

protocol VideoDataOutputDelegate: class {
    /**
     Called when the `CaptureManager` outputs a `CMSampleBuffer`.
     - Important: This is **NOT** called on the main thread, but instead on `CaptureManager.kFramesQueue`.
     */
    //    func captureManagerDidOutput(_ sampleBuffer: CMSampleBuffer)
    
    func captureManagerDidOutput(_ sampleBuffer: CMSampleBuffer, rectangleLayer: CAShapeLayer, superView: UIView)
}


class Camera: NSObject {

    // MARK: - Properties
    
    let superView: UIView
    
    weak var dataOutputDelegate: VideoDataOutputDelegate? {
        didSet {
            videoDataOutput?.setSampleBufferDelegate(self, queue: framesQueue)
        }
    }
    
    fileprivate let captureSession = AVCaptureSession()
    fileprivate var captureDevice: AVCaptureDevice!
    fileprivate var isTakePhoto = false
    fileprivate var captureCompletion: CaptureCompletion?
    fileprivate let framesQueue: DispatchQueue
    fileprivate let sessionQueue: DispatchQueue
    fileprivate static let kFramesQueue = "com.sic.SwiftCam.FramesQueue"
    fileprivate static let kSessionQueue = "com.sic.SwiftCam.SessionQueue"
    fileprivate var videoDataOutput: AVCaptureVideoDataOutput?
    fileprivate var rectangeLayer = CAShapeLayer()
    fileprivate var objCaptureDeviceInput: AVCaptureDeviceInput?
    fileprivate var stillImageOutput = AVCaptureStillImageOutput()
    
    
    // MARK: - Initializers
    
    init(superView: UIView, captureCompletion: CaptureCompletion?) {
        self.superView = superView
        self.captureCompletion = captureCompletion
        framesQueue = DispatchQueue(label: Camera.kFramesQueue)
        sessionQueue = DispatchQueue(label: Camera.kSessionQueue)
        
        super.init()
        self.prepareCamera()
    }
    
    
    // MARK: - Deinitializers
    
    deinit {
        
    }
}


extension Camera {
    
    fileprivate func prepareCamera() {
        superView.layer.addSublayer(rectangeLayer)
        
        /// Change sessionPreset on iPad & iPhone
        switch deviceType {
        case .phone:
            self.captureSession.sessionPreset = AVCaptureSessionPresetHigh
        case .pad:
            self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        default: break
        }
        
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
        
        
        
        captureSession.startRunning()
        
        videoDataOutput = AVCaptureVideoDataOutput()
        
        if let videoDataOutput = videoDataOutput {
            videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString): NSNumber(value: kCVPixelFormatType_32BGRA)]
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            videoDataOutput.setSampleBufferDelegate(self, queue: framesQueue)
            
            if captureSession.canAddOutput(videoDataOutput) {
                captureSession.addOutput(videoDataOutput)
            }
            
            let connection = videoDataOutput.connections.first as! AVCaptureConnection
            connection.videoOrientation = .portrait
            
            captureSession.commitConfiguration()
        }
    }
    
    fileprivate func setupCameraView() {
        superView.layer.addSublayer(rectangeLayer)
        
        let allDevices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
        let aDevice: AnyObject? = allDevices?.first as AnyObject?
        
        if aDevice == nil {
            return
        }
        
        self.captureSession.beginConfiguration()
        self.captureDevice = (aDevice as! AVCaptureDevice)
        
        objCaptureDeviceInput = try! AVCaptureDeviceInput(device: self.captureDevice)
        
        /// Change sessionPreset on iPad & iPhone
        switch deviceType {
        case .phone: self.captureSession.sessionPreset = AVCaptureSessionPresetHigh
        case .pad: self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        default: break
        }
        
        self.captureSession.addInput(objCaptureDeviceInput)
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.alwaysDiscardsLateVideoFrames = true
        dataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable: kCVPixelFormatType_32BGRA]
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        self.captureSession.addOutput(dataOutput)
        
        self.captureSession.addOutput(self.stillImageOutput)
        
        let connection = dataOutput.connections.first as! AVCaptureConnection
        connection.videoOrientation = .portrait
        
        self.captureSession.commitConfiguration()
    }
}


extension Camera {

    func startCaptureSession() {
        if !self.captureSession.isRunning {
            ///self.prepareCamera()
            
            setupCameraView()
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
        } else {
            DispatchQueue.main.async { [unowned self] in
                self.dataOutputDelegate?.captureManagerDidOutput(sampleBuffer, rectangleLayer: self.rectangeLayer, superView: self.superView)
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















