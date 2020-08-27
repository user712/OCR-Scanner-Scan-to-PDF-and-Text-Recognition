//
//  VideoCamera.swift
//  ZCamera
//
//  Created by Developer on 3/10/17.
//  Copyright © . 
//

import UIKit
import AVFoundation

typealias CameraBuffer = CMSampleBuffer
typealias ImageErrorCompletionHandler = (UIImage?, Error?) -> Void

protocol CameraBufferDelegate: class {
    func videoCamera(_ videoCamera: VideoCamera, didOutputFrom sampleBuffer: CameraBuffer!, rectangleLayer: CAShapeLayer)
}

protocol CameraFocusDelegate: class {
    func videoCamera(_ videoCamera: VideoCamera, didFocusAtPoint focusPoint: CGPoint, inLayer layer: CALayer)
}

class VideoCamera: NSObject {
    
    // MARK: - Properties
    
    let cameraView: CameraView
    
    var lowLightBoost = true
    var tapToFocus = true
    
    weak var focusdelegate: CameraFocusDelegate?
    weak var bufferDelegate: CameraBufferDelegate?
    
    /// returns the current screen resolution (differs by device type)
    var getCaptureResolution: CGSize {
        // Define default resolution
        var resolution = CGSize(width: 0, height: 0)
        
        // Set if video portrait orientation
        let portraitOrientation = (UIScreen.main.bounds.height > UIScreen.main.bounds.width)
        
        // Get video dimensions
        if let formatDescription = captureDevice?.activeFormat.formatDescription {
            let dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription)
            resolution = CGSize(width: CGFloat(dimensions.width), height: CGFloat(dimensions.height))
        } else {
            print("formatDescription error. Setting resolution to screen default")
            resolution = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        }
        
        if (!portraitOrientation) {
            resolution = CGSize(width: resolution.height, height: resolution.width)
        }
        
        // Return resolution
        return resolution
    }

    
    fileprivate var sessionQueue: DispatchQueue!
    fileprivate var videoDeviceInput: AVCaptureDeviceInput?
    fileprivate var stillImageOutput: AVCaptureStillImageOutput?
    fileprivate var videoDataOutput: AVCaptureVideoDataOutput?
    fileprivate var captureDevice: AVCaptureDevice?
    fileprivate var deviceAuthorized: Bool  = false
    fileprivate var backgroundRecordId: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    fileprivate let videoDataOutputQueue = DispatchQueue(label: "video data queue")
    fileprivate var rectangeLayer = CAShapeLayer()
    
    fileprivate var desiredVideoOrientation: AVCaptureVideoOrientation {
        switch UIDevice.current.orientation {
        case .portrait, .portraitUpsideDown, .faceUp, .faceDown, .unknown:
            return .portrait
        case .landscapeLeft:
            return .landscapeRight
        case .landscapeRight:
            return .landscapeLeft
        }
    }
    
    fileprivate let quadView: QuadrilateralShowView
    fileprivate let rectangleDetector: RectangleManager
    
    // MARK: - Initializers
    
    init(cameraView: CameraView) {
        self.cameraView = cameraView
        self.quadView = QuadrilateralShowView(frame: cameraView.bounds)
        cameraView.layer.addSublayer(self.quadView.rectangleLayer)
        cameraView.bringSubview(toFront: quadView)
        self.rectangleDetector = RectangleManager()
        
        super.init()
        self.prepareCamera()
    }
    
    
    // MARK: - Deinitializers
    
    deinit {
        sessionQueue = nil
        videoDeviceInput = nil
        stillImageOutput = nil
        videoDataOutput = nil
        captureDevice = nil
    }
}


// MARK: - Start & Stop session

extension VideoCamera {
    
    func startCaptureSession() {
        self.prepareCamera()
        
        if self.cameraView.cameraSession.isRunning {
            self.beginSession()
        }
    }
    
    func stopCaptureSession() {
        self.self.cameraView.cameraSession.stopRunning()
        
        if let inputs = self.cameraView.cameraSession.inputs as? [AVCaptureInput] {
            for input in inputs {
                self.cameraView.cameraSession.removeInput(input)
            }
        }
        
        self.self.cameraView.cameraSession.removeOutput(stillImageOutput)
    }
}


// MARK: - Prepare

extension VideoCamera {
    
    fileprivate func prepareCamera() {
        let session = AVCaptureSession()
        self.cameraView.cameraSession = session
        self.cameraView.cameraSession.sessionPreset = AVCaptureSessionPresetPhoto
        self.checkDeviceAuthorizationStatus()
        self.cameraView.cameraSession.startRunning()
        
        let sessionQueue = DispatchQueue(label: "com.sic.cam.sessionQueue",attributes: [])
        self.sessionQueue = sessionQueue
        
        sessionQueue.async { [unowned self] in
            self.backgroundRecordId = UIBackgroundTaskInvalid
            
            /// Prepare capture device
            if #available(iOS 10.0, *) {
                if let aviableDevices = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .back).devices {
                    self.captureDevice = aviableDevices.first
                }
            } else {
                // Fallback on earlier versions
                if let aviableDevices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as? [AVCaptureDevice] {
                    var newCaptureDevice = aviableDevices.first
                    let preferringPosition: AVCaptureDevicePosition = .back
                    
                    for device in aviableDevices {
                        if device.position == preferringPosition {
                            newCaptureDevice = device
                            break
                        }
                    }
                    
                    self.captureDevice = newCaptureDevice
                }
            }
        }
    }
    
    fileprivate func beginSession() {
        self.cameraView.cameraSession.beginConfiguration()
        
        self.cameraView.layer.addSublayer(rectangeLayer)
        
        if let captureDevice = self.captureDevice, let videoDeviceInput = try? AVCaptureDeviceInput(device: captureDevice) {
            self.videoDeviceInput = videoDeviceInput
            if self.cameraView.cameraSession.canAddInput(videoDeviceInput) {
                self.cameraView.cameraSession.addInput(videoDeviceInput)
            }
        }
        
        
        self.stillImageOutput = AVCaptureStillImageOutput()
        if let stillImageOutput = self.stillImageOutput {
            if self.cameraView.cameraSession.canAddOutput(stillImageOutput) {
                stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
                self.cameraView.cameraSession.addOutput(stillImageOutput)
            }
        }
        
        
        self.videoDataOutput = AVCaptureVideoDataOutput()
        if let videoDataOutput = self.videoDataOutput {
            if self.cameraView.cameraSession.canAddOutput(videoDataOutput) {
                videoDataOutput.alwaysDiscardsLateVideoFrames = true
                videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
                videoDataOutput.setSampleBufferDelegate(self, queue: self.videoDataOutputQueue)
                self.cameraView.cameraSession.addOutput(videoDataOutput)
            }
        }
        
        self.cameraView.cameraSession.commitConfiguration()
        
        self.prepareAutofocus()
        self.addGestureRecognizersTo(view: self.cameraView)
    }
    
    fileprivate func checkDeviceAuthorizationStatus() {
        let mediaType = AVMediaTypeVideo
        
        AVCaptureDevice.requestAccess(forMediaType: mediaType) { (granted: Bool) in
            if granted {
                self.deviceAuthorized = true
            } else {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "AVCam", message: "AVCam does not have permission to access camera", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default) { _ in }
                    alert.addAction(action)
                }
                
                self.deviceAuthorized = false
            }
        }
    }
    
    fileprivate func setFlashMode(_ flashMode: AVCaptureFlashMode, device: AVCaptureDevice) {
        if device.hasFlash && device.isFlashModeSupported(flashMode) {
            var error: NSError? = nil
            do {
                try device.lockForConfiguration()
                device.flashMode = flashMode
                device.unlockForConfiguration()
                
            } catch let error1 as NSError {
                error = error1
                print(error!)
            }
        }
    }
    
    fileprivate func prepareAutofocus() {
        if let device = captureDevice {
            do {
                try device.lockForConfiguration()
                if device.isFocusModeSupported(.continuousAutoFocus) {
                    device.focusMode = .continuousAutoFocus
                    if device.isSmoothAutoFocusSupported {
                        device.isSmoothAutoFocusEnabled = true
                    }
                }
                
                if device.isExposureModeSupported(.continuousAutoExposure) {
                    device.exposureMode = .continuousAutoExposure
                }
                
                if device.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
                    device.whiteBalanceMode = .continuousAutoWhiteBalance
                }
                
                if device.isLowLightBoostSupported && lowLightBoost == true {
                    device.automaticallyEnablesLowLightBoostWhenAvailable = true
                }
                
                device.unlockForConfiguration()
            } catch {
                print("[SwiftyCam]: Error locking configuration")
            }
        }
    }
}


// MARK: - UIGestureRecognizerDelegate

extension VideoCamera: UIGestureRecognizerDelegate {
    
    fileprivate func addGestureRecognizersTo(view: CameraView) {
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(singleTapGesture(tap:)))
        singleTapGesture.numberOfTapsRequired = 1
        singleTapGesture.delegate = self
        view.addGestureRecognizer(singleTapGesture)
    }
    
    /// Handle single tap gesture
    
    @objc fileprivate func singleTapGesture(tap: UITapGestureRecognizer) {
        guard tapToFocus == true else {
            // Ignore taps
            return
        }
        
        let screenSize = cameraView.bounds.size
        let tapPoint = tap.location(in: cameraView)
        let x = tapPoint.y / screenSize.height
        let y = 1.0 - tapPoint.x / screenSize.width
        let focusPoint = CGPoint(x: x, y: y)
        
        if let device = captureDevice {
            do {
                try device.lockForConfiguration()
                
                if device.isFocusPointOfInterestSupported == true {
                    device.focusPointOfInterest = focusPoint
                    device.focusMode = .autoFocus
                }
                device.exposurePointOfInterest = focusPoint
                device.exposureMode = AVCaptureExposureMode.continuousAutoExposure
                device.unlockForConfiguration()
                //Call delegate function and pass in the location of the touch
                
                DispatchQueue.main.async { [unowned self] in
                    self.focusdelegate?.videoCamera(self, didFocusAtPoint: tapPoint, inLayer: self.cameraView.layer)
                }
                
            } catch {
                // just ignore
            }
        }
    }
    
    
    /// Set beginZoomScale when pinch begins
    
    internal func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
}


// MARK: - Capture image

extension VideoCamera {
    
    func captureImageWithCompletion(_ completion: @escaping (_ imageData: Data?, _ image: UIImage?, _ error: Error?) -> ()) {
        self.sessionQueue.async { [unowned self] in
            let videoOrientation = self.cameraView.layer.connection.videoOrientation
            self.stillImageOutput!.connection(withMediaType: AVMediaTypeVideo).videoOrientation = videoOrientation
            self.setFlashMode(AVCaptureFlashMode.auto, device: self.videoDeviceInput!.device)
            
            self.stillImageOutput?.captureStillImageAsynchronously(from: self.stillImageOutput!.connection(withMediaType: AVMediaTypeVideo)) {
                (imageDataSampleBuffer, bufferError) in
                
                if bufferError == nil {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                    let image = UIImage( data: imageData!)
                    completion(imageData, image, nil)
                } else {
                    completion(nil, nil, bufferError)
                }
            }
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension VideoCamera: AVCaptureVideoDataOutputSampleBufferDelegate {
 
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        /*
        DispatchQueue.main.async { [unowned self] in
            self.bufferDelegate?.videoCamera(self, didOutputFrom: sampleBuffer, rectangleLayer: self.rectangeLayer)
        }*/
        
        let image = rectangleDetector.fixImageOrientation(rectangleDetector.imageFromSampleBuffer(sampleBuffer))
        guard let ciImage = CIImage(image: image) else { return }
        let points = rectangleDetector.quadfromImage(ciImage, quardView: quadView)
        
        DispatchQueue.main.async { [unowned self] in
            self.quadView.drawRectanglePath(points, imageSize: image.size, viewSize: self.cameraView.bounds.size)
        }
    }
}
