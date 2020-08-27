//
//  Camera.swift
//  GimiCam
//
//  Created  on 3/4/17.
//  Copyright © 2017 A. 
//

import UIKit
import AVFoundation
import CoreGraphics
import CoreImage

typealias CameraBuffer = CMSampleBuffer
typealias ImageErrorCompletionHandler = (UIImage?, Error?) -> Void

protocol CameraRectangleDelegate: class {
    func camera(_ camera: VideoCamera, didOutputFrom sampleBuffer: CameraBuffer!, rectangleLayer: CAShapeLayer)
}

protocol CameraDelegate: class {
    var lastFocusRectangle: CAShapeLayer? { get set }
    
    func camera(_ camera: VideoCamera, didFocusAtPoint focusPoint: CGPoint, inLayer layer: CALayer)
}

/// Error types for `CaptureManager`
enum CaptureManagerError: Error {
    case invalidSessionPreset
    case invalidMediaType
    case invalidCaptureInput
    case invalidCaptureOutput
    case sessionNotSetUp
    case missingOutputConnection
    case missingVideoDevice
    case missingMovieOutput
    case missingPreviewLayerProvider
    case cameraToggleFailed
    case focusNotSupported
    case exposureNotSupported
    case flashNotAvailable
    case flashModeNotSupported
    case torchNotAvailable
    case torchModeNotSupported
}

/// Error types for `CaptureManager` related to `AVCaptureStillImageOutput`
enum StillImageError: Error {
    case noData
    case noImage
}


class VideoCamera: NSObject {
    
    // MARK: - Nested Types
    
    fileprivate enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }
    
    
    // MARK: - Properties
    
    let superView: UIView
    
    var takePhoto = false
    var tapToFocus = true
    var lowLightBoost = true
    var mirrorsFrontCamera = true
    var usingJPEGOutput = true
    
    /// The `AVCaptureVideoOrientation` that corresponds to the current device's orientation.
    var desiredVideoOrientation: AVCaptureVideoOrientation {
        switch UIDevice.current.orientation {
        case .portrait, .portraitUpsideDown, .faceUp, .faceDown, .unknown:
            return .portrait
        case .landscapeLeft:
            return .landscapeRight
        case .landscapeRight:
            return .landscapeLeft
        }
    }
    
    weak var delegate: CameraDelegate?
    weak var rectangleDelegate: CameraRectangleDelegate?
    
    fileprivate var photoQuality: NSNumber = 1.0
    fileprivate let captureSession = AVCaptureSession()
    fileprivate var captureDevice: AVCaptureDevice!
    fileprivate var stillImageOutput: AVCaptureStillImageOutput!
    fileprivate(set) var videoDevicePosition = AVCaptureDevicePosition.back
    fileprivate var previewLayer: CALayer!
    fileprivate var setupResult = SessionSetupResult.success
    fileprivate var rectangeLayer = CAShapeLayer()
    public let framesQueue: DispatchQueue
    public let sessionQueue: DispatchQueue
    fileprivate static let kFramesQueue = "com.MihailSalari.GimiCam.FramesQueue"
    fileprivate static let kSessionQueue = "com.MihailSalari.GimiCam.SessionQueue"

    
    // MARK: - Initializers
    
    init(superView: UIView) {
        self.superView = superView
        framesQueue = DispatchQueue(label: VideoCamera.kFramesQueue)
        sessionQueue = DispatchQueue(label: VideoCamera.kSessionQueue)
        super.init()
    }
    
    
    // MARK: - Deinitializers
    
    deinit {
        self.stopCaptureSession()
        previewLayer = nil
        captureDevice = nil
        stillImageOutput = nil
    }
}


// MARK: - Prepare

extension VideoCamera {
    
    fileprivate func prepareCamera() {
        self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        
        if #available(iOS 10.0, *) {
            if let aviableDevices = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .back).devices {
                captureDevice = aviableDevices.first
            }
        } else {
            // Fallback on earlier versions
            if let aviableDevices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as? [AVCaptureDevice] {
                captureDevice = aviableDevices.first
            }
        }
        
        self.beginSession()
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
            self.previewLayer.addSublayer(rectangeLayer)
            
            captureSession.startRunning()

            stillImageOutput = AVCaptureStillImageOutput()
//            stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            if self.usingJPEGOutput {
                self.stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG, AVVideoQualityKey: self.photoQuality]
            } else {
                //Try doing raw input
                self.stillImageOutput.outputSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable: kCVPixelFormatType_32BGRA]
            }
            stillImageOutput.isHighResolutionStillImageOutputEnabled = true
            
            if captureSession.canAddOutput(stillImageOutput) {
                captureSession.addOutput(stillImageOutput)
            }
            
            let dataOutput = AVCaptureVideoDataOutput()
            dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString): NSNumber(value: kCVPixelFormatType_32BGRA)]
            dataOutput.alwaysDiscardsLateVideoFrames = true
            
            if captureSession.canAddOutput(dataOutput) {
                captureSession.addOutput(dataOutput)
            }
            
            captureSession.commitConfiguration()
            
            let queue = DispatchQueue(label: "com.MihailSalari.captureQueue")
            dataOutput.setSampleBufferDelegate(self, queue: queue)
        }
        
        self.prepareAutofocus()
        self.addGestureRecognizersTo(view: self.superView)
    }
}


// MARK: - Get capture resolution

extension VideoCamera {
    
    /// Returns the current screen resolution (differs by device type)
    func getCaptureResolution() -> CGSize {
        // Define default resolution
        var resolution = CGSize(width: 0, height: 0)
        
        // Set if video portrait orientation
        let portraitOrientation = (UIScreen.main.bounds.height > UIScreen.main.bounds.width)
        
        if let formatDescription = captureDevice?.activeFormat.formatDescription {
            let dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription)
            resolution = CGSize(width: CGFloat(dimensions.width), height: CGFloat(dimensions.height))
        } else {
            print("formatDescription error. Setting resolution to screen default")
            resolution = CGSize(width: CGFloat(UIScreen.main.bounds.width), height: CGFloat(UIScreen.main.bounds.height))
        }
        
        if (!portraitOrientation) {
            resolution = CGSize(width: resolution.height, height: resolution.width)
        }
        
        // Return resolution
        return resolution
    }
}


// MARK: - Prepare Autofocus

extension VideoCamera {
    
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
    
    /// Handle single tap gesture
    
    @objc fileprivate func singleTapGesture(tap: UITapGestureRecognizer) {
        guard tapToFocus == true else {
            // Ignore taps
            return
        }
        
        let screenSize = previewLayer!.bounds.size
        let tapPoint = tap.location(in: superView)
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
                    self.delegate?.camera(self, didFocusAtPoint: tapPoint, inLayer: self.previewLayer)
                }
            }
            catch {
                // just ignore
            }
        }
    }
}


// MARK: - UIGestureRecognizerDelegate

extension VideoCamera: UIGestureRecognizerDelegate {
    
    fileprivate func addGestureRecognizersTo(view: UIView) {
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(singleTapGesture(tap:)))
        singleTapGesture.numberOfTapsRequired = 1
        singleTapGesture.delegate = self
        view.addGestureRecognizer(singleTapGesture)
    }
 
    /// Set beginZoomScale when pinch begins
    
    internal func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
}



// MARK: - Start & Stop

extension VideoCamera {
    
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
        
        self.captureSession.removeOutput(stillImageOutput)
    }
}


// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension VideoCamera: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        DispatchQueue.main.async { [unowned self] in
        
            if self.takePhoto {
                self.takePhoto = false
                
            }
        }
    }
}


extension VideoCamera {
    /**
     Capture a still image.
     - parameter completion: A closure of type `(UIImage?, Error?) -> Void` that is called on the **main thread** upon successful capture of the image or the occurence of an error.
     */
    func captureStillImage(_ completion: @escaping ImageErrorCompletionHandler) {
        
        sessionQueue.async {
            
            guard let imageOutput = self.stillImageOutput,
                let connection = imageOutput.connection(withMediaType: AVMediaTypeVideo) else {
                DispatchQueue.main.async {
                    completion(nil, CaptureManagerError.missingOutputConnection)
                }
                    
                return
            }
            
            connection.videoOrientation = self.desiredVideoOrientation
            
            imageOutput.captureStillImageAsynchronously(from: connection) { (sampleBuffer, error) -> Void in
                if (sampleBuffer == nil || error != nil) {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                    return
                }
                
                guard let data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer) else {
                    DispatchQueue.main.async {
                        completion(nil, StillImageError.noData)
                    }
                    return
                }
                
                guard let image = UIImage(data: data) else {
                    DispatchQueue.main.async {
                        completion(nil, StillImageError.noImage)
                    }
                    return
                }
                
                var flipped: UIImage?
                let wantsFlipped = (self.videoDevicePosition == .front && self.mirrorsFrontCamera)
                
                if (wantsFlipped) {
                    if let cgImage = image.cgImage {
                        flipped = UIImage(cgImage: cgImage, scale: image.scale, orientation: .leftMirrored)
                    }
                }
                
                DispatchQueue.main.async {
                    completion(flipped ?? image, nil)
                }
            }
        }
    }
    
    /**
     Capture a still image.
     - parameter completion: A closure of type `(UIImage?, Error?) -> Void` that is called on the **main thread** upon successful capture of the image or the occurence of an error.
     */
    func captureStillImage2(_ completion: @escaping ImageErrorCompletionHandler) {
        
        
        // Must be initialized
        if let videoConnection = stillImageOutput?.connection(withMediaType: AVMediaTypeVideo) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.landscapeLeft
            stillImageOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: {(sampleBuffer, error) in
                if (sampleBuffer != nil) {
                    if self.usingJPEGOutput {
                        if let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer) as? CFData {
                            if let dataProvider = CGDataProvider(data: imageData) {
                                if let cgImageRef = CGImage(jpegDataProviderSource: dataProvider, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent) {
                                    let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: .right)
                                    completion(image, nil)
                                }
                            }
                        }
                    } else {
                        //Raw ouput
                        
                    }
                }
            })
        }
    }
}
