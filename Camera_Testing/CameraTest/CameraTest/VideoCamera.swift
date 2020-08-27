//
//  VideoCamera.swift
//  CameraTest
//
//  Created by Developer on 2/28/17.
//  Copyright © . 
//

import UIKit
import GLKit
import AVFoundation
import CoreMedia
import CoreImage
import OpenGLES
import QuartzCore
import ImageIO
import GPUImage

class VideoCamera: NSObject {

    // MARK: - Properties
    
    var borderDetectionEnabled = true
    
    fileprivate var captureSession = AVCaptureSession()
    fileprivate var captureDevice: AVCaptureDevice?
    fileprivate var context: EAGLContext?
    fileprivate var stillImageOutput = AVCaptureStillImageOutput()
    fileprivate var forceStop: Bool = false
    fileprivate var coreImageContext: CIContext?
    fileprivate var renderBuffer: GLuint = 0
    fileprivate let glkView: GLKView
    fileprivate var stopped: Bool = false
    fileprivate var imageDetectionConfidence = 0.0
    fileprivate var borderDetectFrame: Bool = false
    fileprivate var borderDetectLastRectangleFeature: CIRectangleFeature?
    fileprivate var capturing: Bool = false
    fileprivate var timeKeeper: Timer?
    fileprivate var shapeLayer = CAShapeLayer()
    fileprivate let superview: RenderView
    fileprivate var objCaptureDeviceInput: AVCaptureDeviceInput?
    fileprivate var infoLabel: UILabel!
    fileprivate var videoCamera: Camera
    
    
    // MARK: - Initializers
    
    init(superview: RenderView) {
        self.superview = superview
        
        
        if let _ = self.context {
            return
        }
        
        superview.layer.addSublayer(shapeLayer)
        
        self.context = EAGLContext(api: .openGLES2)
        self.glkView = GLKView(frame: superview.bounds, context: self.context!)
        self.glkView.autoresizingMask = ([.flexibleWidth, .flexibleHeight])
        self.glkView.translatesAutoresizingMaskIntoConstraints = true
        self.glkView.contentScaleFactor = 1.0
        self.glkView.drawableDepthFormat = .format24
        superview.insertSubview(self.glkView, at: 0)
        glGenRenderbuffers(1, &self.renderBuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), self.renderBuffer)
        
        self.coreImageContext = CIContext(eaglContext: self.context!, options: [kCIContextUseSoftwareRenderer: true])
        EAGLContext.setCurrent(self.context!)
        
        ///
        do {
            switch deviceType {
            case .pad:
                videoCamera = try Camera(sessionPreset: AVCaptureSessionPresetPhoto, location:.backFacing)
            case .phone:
                videoCamera = try Camera(sessionPreset: AVCaptureSessionPresetHigh, location:.backFacing)
            default:
                break
            }
        } catch {
            print("Couldn't initialize camera with error: \(error)")
            videoCamera = try! Camera(sessionPreset: AVCaptureSessionPresetPhoto, location:.backFacing)
        }
        
        super.init()
        
        videoCamera.runBenchmark = true
        videoCamera.addTarget(superview)
        videoCamera.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(cameraDidEnterBackground), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(cameraDidEnterForeground), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        self.infoLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 220, height: 30))
        self.infoLabel.backgroundColor = UIColor.red.withAlphaComponent(0.6)
        self.infoLabel.textColor = UIColor.white
        self.infoLabel.layer.cornerRadius = 8.0
        self.infoLabel.clipsToBounds = true
        self.infoLabel.textAlignment = .center
        self.infoLabel.numberOfLines = 0
        
        self.infoLabel.center = superview.center
        self.infoLabel.alpha = 0.0
        superview.addSubview(self.infoLabel)
    }

    
    // MARK: - Deinitializers
    
    deinit{
        stopCapture()
    }
}




extension VideoCamera {
    
    func startCapture() {
        startFiltering()
        videoCamera.startCapture()
    }
    
    
    fileprivate func startFiltering() {
        self.stopped = false
        self.captureSession.startRunning()
        self.hideGlkView(false, completion: nil)
        
        self.timeKeeper = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(VideoCamera._enableBorderDetection), userInfo: nil, repeats: true)
        RunLoop.current.add(self.timeKeeper!, forMode: RunLoopMode.commonModes)
    }
    
    
    func stopCapture() {
        stopFiltering()
        videoCamera.stopCapture()
        videoCamera.removeAllTargets()
    }
    
    
    fileprivate func stopFiltering() {
        self.stopped = true
        self.captureSession.stopRunning()
        self.hideGlkView(true, completion: nil)
        self.timeKeeper?.invalidate()
    }
    
    func cameraDidEnterBackground() {
        self.forceStop = true
    }
    
    func cameraDidEnterForeground() {
        self.forceStop = false
    }
    
    func _enableBorderDetection() {
        self.borderDetectFrame = true
    }
    
    fileprivate func detectionConfidenceValid() -> Bool {
        return (self.imageDetectionConfidence > 1.0)
    }
    
    fileprivate func setupCameraView() {
//        self.setupGLKView()
        
        let allDevices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
        let aDevice: AnyObject? = allDevices?.first as AnyObject?
        
        if aDevice == nil {
            return
        }
        
        self.captureSession.beginConfiguration()
        self.captureDevice = (aDevice as! AVCaptureDevice)
        
        objCaptureDeviceInput = try! AVCaptureDeviceInput(device: self.captureDevice)
        
        //        let input = try! AVCaptureDeviceInput(device: self.captureDevice)
        
        /// Change sessionPreset on iPad & iPhone
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            self.captureSession.sessionPreset = AVCaptureSessionPresetHigh
        case .pad:
            self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        default: break
        }
        
        //        self.captureSession.addInput(input)
        self.captureSession.addInput(objCaptureDeviceInput)
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.alwaysDiscardsLateVideoFrames = true
        dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString): NSNumber(value: kCVPixelFormatType_32BGRA)]
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        self.captureSession.addOutput(dataOutput)
        
        self.captureSession.addOutput(self.stillImageOutput)
        
        let connection = dataOutput.connections.first as! AVCaptureConnection
        connection.videoOrientation = .portrait
        
        if self.captureDevice!.isFlashAvailable {
            try! self.captureDevice?.lockForConfiguration()
            self.captureDevice?.flashMode = .off
            self.captureDevice?.unlockForConfiguration()
        }
        
        if self.captureDevice!.isFocusModeSupported(.continuousAutoFocus) {
            try! self.captureDevice?.lockForConfiguration()
            self.captureDevice?.focusMode = .continuousAutoFocus
            self.captureDevice?.unlockForConfiguration()
        }
        
        self.captureSession.commitConfiguration()
    }
    
//    fileprivate func setupGLKView() {
//        if let _ = self.context {
//            return
//        }
//        
//        superview.layer.addSublayer(shapeLayer)
//        
//        self.context = EAGLContext(api: .openGLES2)
//        self.glkView = GLKView(frame: superview.bounds, context: self.context!)
//        self.glkView!.autoresizingMask = ([.flexibleWidth, .flexibleHeight])
//        self.glkView!.translatesAutoresizingMaskIntoConstraints = true
//        self.glkView!.contentScaleFactor = 1.0
//        self.glkView!.drawableDepthFormat = .format24
//        superview.insertSubview(self.glkView!, at: 0)
//        glGenRenderbuffers(1, &self.renderBuffer)
//        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), self.renderBuffer)
//        
//        self.coreImageContext = CIContext(eaglContext: self.context!, options: [kCIContextUseSoftwareRenderer: true])
//        EAGLContext.setCurrent(self.context!)
//    }
    
    fileprivate func hideGlkView(_ hide: Bool, completion:( () -> Void)?) {
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.glkView.alpha = (hide) ? 0.0 : 1.0
        }, completion: { (finished) -> Void in
            completion?()
        })
    }
}


// MARK: - CameraDelegate

extension VideoCamera: CameraDelegate {
    
    func didCaptureBuffer(_ sampleBuffer: CMSampleBuffer) {
//        if self.forceStop {
//            return
//        }
//        
//        let sampleBufferValid: Bool = CMSampleBufferIsValid(sampleBuffer)
//        
//        if self.stopped || self.capturing || !sampleBufferValid {
//            return
//        }
//        
//        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
//        let image = CIImage(cvPixelBuffer: pixelBuffer!)
//        
//        
//        self.infoLabel.center = self.superview.center
//        
//        if let metadataDict = CMCopyDictionaryOfAttachments(nil, sampleBuffer, kCMAttachmentMode_ShouldPropagate) {
//            if let metadata = metadataDict as? [AnyHashable: Any] {
//                if let exifMetadata = metadata[(kCGImagePropertyExifDictionary) as AnyHashable] as? [AnyHashable : Any] {
//                    if let brightnessValue = exifMetadata[(kCGImagePropertyExifBrightnessValue) as AnyHashable] as? Float {
//                        if brightnessValue <= -1.0 {
//                            self.infoLabel.alpha = 1.0
//                            self.infoLabel.text = "Poor light! \nSearching for document"
//                            self.infoLabel.frame = CGRect(x: self.infoLabel.frame.origin.x, y: self.infoLabel.frame.origin.y, width: 200, height: 56)
//                        } else {
//                            if self.borderDetectionEnabled {
//                                if self.borderDetectFrame {
//                                    self.borderDetectLastRectangleFeature = RectangleDetector.main.detectRectangularFeature(image)
//                                    self.borderDetectFrame = false
//                                }
//                                
//                                if let lastRectFeature = self.borderDetectLastRectangleFeature {
//                                    self.imageDetectionConfidence += 0.5
//                                    
//                                    UIView.animate(withDuration: 1.0) { [unowned self] in
//                                        self.shapeLayer.draw(inRect: self.superview.frame, ciImage: image, biggestRectangleFeature: lastRectFeature)
//                                    }
//                                    
//                                    self.infoLabel.alpha = 1.0
//                                    self.infoLabel.text = "Move closer."
//                                    self.infoLabel.frame = CGRect(x: self.infoLabel.frame.origin.x, y: self.infoLabel.frame.origin.y, width: 120, height: 30)
//                                    
//                                } else {
//                                    self.imageDetectionConfidence = 0.0
//                                    
//                                    UIView.animate(withDuration: 1.0) { [unowned self] in
//                                        self.shapeLayer.hide()
//                                    }
//                                    
//                                    self.infoLabel.alpha = 1.0
//                                    self.infoLabel.text = "Searching for document..."
//                                    self.infoLabel.frame = CGRect(x: self.infoLabel.frame.origin.x, y: self.infoLabel.frame.origin.y, width: 220, height: 30)
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//
//        if let context = self.context, let ciContext = self.coreImageContext, let glkView = self.glkView {
//            ciContext.draw(image, in: superview.bounds, from: image.extent)
//            context.presentRenderbuffer(Int(GL_RENDERBUFFER))
//            glkView.setNeedsDisplay()
//        }
    }
}


// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension VideoCamera: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        if self.forceStop {
            return
        }
        
        let sampleBufferValid: Bool = CMSampleBufferIsValid(sampleBuffer)
        
        if self.stopped || self.capturing || !sampleBufferValid {
            return
        }
        
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let image = CIImage(cvPixelBuffer: pixelBuffer!)
        
        
        self.infoLabel.center = self.superview.center
        
        if let metadataDict = CMCopyDictionaryOfAttachments(nil, sampleBuffer, kCMAttachmentMode_ShouldPropagate) {
            if let metadata = metadataDict as? [AnyHashable: Any] {
                if let exifMetadata = metadata[(kCGImagePropertyExifDictionary) as AnyHashable] as? [AnyHashable : Any] {
                    if let brightnessValue = exifMetadata[(kCGImagePropertyExifBrightnessValue) as AnyHashable] as? Float {
                        if brightnessValue <= -1.0 {
                            self.infoLabel.alpha = 1.0
                            self.infoLabel.text = "Poor light! \nSearching for document"
                            self.infoLabel.frame = CGRect(x: self.infoLabel.frame.origin.x, y: self.infoLabel.frame.origin.y, width: 200, height: 56)
                        } else {
                            if self.borderDetectionEnabled {
                                if self.borderDetectFrame {
                                    self.borderDetectLastRectangleFeature = RectangleDetector.main.detectRectangularFeature(image)
                                    self.borderDetectFrame = false
                                }
                                
                                if let lastRectFeature = self.borderDetectLastRectangleFeature {
                                    self.imageDetectionConfidence += 0.5
                                    
                                    UIView.animate(withDuration: 1.0) { [unowned self] in
                                        self.shapeLayer.draw(inRect: self.superview.frame, ciImage: image, biggestRectangleFeature: lastRectFeature)
                                    }
                                    
                                    self.infoLabel.alpha = 1.0
                                    self.infoLabel.text = "Move closer."
                                    self.infoLabel.frame = CGRect(x: self.infoLabel.frame.origin.x, y: self.infoLabel.frame.origin.y, width: 120, height: 30)
                                    
                                } else {
                                    self.imageDetectionConfidence = 0.0
                                    
                                    UIView.animate(withDuration: 1.0) { [unowned self] in
                                        self.shapeLayer.hide()
                                    }
                                    
                                    self.infoLabel.alpha = 1.0
                                    self.infoLabel.text = "Searching for document..."
                                    self.infoLabel.frame = CGRect(x: self.infoLabel.frame.origin.x, y: self.infoLabel.frame.origin.y, width: 220, height: 30)
                                }
                            }
                        }
                    }
                }
            }
        }
        
        if let context = self.context, let ciContext = self.coreImageContext {
            ciContext.draw(image, in: superview.bounds, from: image.extent)
            context.presentRenderbuffer(Int(GL_RENDERBUFFER))
            glkView.setNeedsDisplay()
        }
    }
}



extension CAShapeLayer {
    
    func draw(inRect previewRect: CGRect, ciImage: CIImage, biggestRectangleFeature: CIRectangleFeature) {
        let imageRect: CGRect = ciImage.extent
        let shapeFillColor = UIColor.blue.withAlphaComponent(0.3).cgColor
        let shapeStrokeColor = UIColor.white.cgColor
        
        /// find ratio between the video preview rect and the image rect; rectangle feature coordinates are relative to the CIImage
        let deltaX: CGFloat = previewRect.width / imageRect.width
        let deltaY: CGFloat = previewRect.height / imageRect.height
        
        /// transform to UIKit coordinate system
        var transform = CGAffineTransform(translationX: 0.0, y: previewRect.height)
        transform = transform.scaledBy(x: 1, y: -1)
        
        /// apply preview to image scaling
        transform = transform.scaledBy(x: deltaX, y: deltaY)
        
        
        let topLeft = biggestRectangleFeature.topLeft.applying(transform)
        let topRight = biggestRectangleFeature.topRight.applying(transform)
        let bottomRight = biggestRectangleFeature.bottomRight.applying(transform)
        let bottomLeft = biggestRectangleFeature.bottomLeft.applying(transform)
        
        
        let path = UIBezierPath()
        path.move(to: topLeft)
        path.addLine(to: topRight)
        path.addLine(to: bottomRight)
        path.addLine(to: bottomLeft)
        path.addLine(to: topLeft)
        path.close()
        
        if self.path != path.cgPath {
            let animation = CABasicAnimation(keyPath: "path")
            animation.fromValue = self.path
            animation.toValue   = path.cgPath
            animation.duration  = 0.25
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut) // kCAMediaTimingFunctionEaseOut /// kCAMediaTimingFunctionEaseInEaseOut
            animation.isRemovedOnCompletion = false
            animation.fillMode = kCAFillModeBoth
            
            self.add(animation, forKey: animation.keyPath)
        }
        
        self.fillColor = shapeFillColor
        self.strokeColor = shapeStrokeColor
        self.lineWidth = 2.0
        self.path = path.cgPath
    }
    
    func hide() {
        self.fillColor = UIColor.clear.cgColor
        self.strokeColor = UIColor.clear.cgColor
        self.lineWidth = 0.0
        
        self.removeAnimation(forKey: "path")
    }
}




extension VideoCamera {
}














/////

import Foundation
import AVKit
import AVFoundation

class RectangleDetector {
    
    // MARK: - Properties
    
    static let main = RectangleDetector()
    fileprivate var detector: CIDetector!
    
    
    // MARK: - Initializers
    
    private init() {
        detector = self.buildRectangleDetector
    }
}


// MARK: - Image from CMSampleBuffer

extension RectangleDetector {
    
    func sampleBufferToImage(_ sampleBuffer: CMSampleBuffer) -> CIImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }
        
        /// Force the type change - pass through opaque buffer
        let opaqueBuffer = Unmanaged<CVImageBuffer>.passUnretained(imageBuffer).toOpaque()
        let pixelBuffer = Unmanaged<CVPixelBuffer>.fromOpaque(opaqueBuffer).takeUnretainedValue()
        let sourceImage = CIImage(cvPixelBuffer: pixelBuffer, options: nil)
        
        return sourceImage
    }
}


extension RectangleDetector {
    
    /// -----------------------
    /// Create feature detector
    fileprivate var buildRectangleDetector: CIDetector {
        let options: [String: Any] = [CIDetectorAccuracy: CIDetectorAccuracyHigh, CIDetectorAspectRatio: 1.41]
        
        return CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: options)!
    }
    
    
    /// Calculates a comparable value of rectangle value
    /// i.e. half of perimeter
    fileprivate func featureSize(_ feature:CIRectangleFeature) -> Float {
        let p1 = feature.topLeft
        let p2 = feature.topRight
        let width = hypotf(Float(p1.x - p2.x), Float(p1.y - p2.y))
        
        let p3 = feature.bottomLeft
        let height = hypotf(Float(p1.x - p3.x), Float(p1.y - p3.y))
        
        return width + height
    }
    
    fileprivate func largestFeature(_ list:[CIRectangleFeature]) -> CIRectangleFeature? {
        if list.count == 0 {
            return nil
        }
        if list.count == 1 {
            return list[0]
        }
        
        let sorted = list.sorted { a,b in
            return featureSize(a) > featureSize(b)
        }
        
        return sorted.first
    }
    
    
    func detectRectangularFeature(_ image: CIImage) -> CIRectangleFeature? {
        let features = detector.features(in: image)
        return largestFeature(features as! [CIRectangleFeature])
    }
}


extension RectangleDetector {
    
    fileprivate func overlayFeature(_ rectFeature: CIRectangleFeature?, image: CIImage) -> CIImage {
        if let feature = rectFeature {
            return drawHighlightOverlayForPoints(image,
                                                 topLeft: feature.topLeft,
                                                 topRight: feature.topRight,
                                                 bottomLeft: feature.bottomLeft,
                                                 bottomRight: feature.bottomRight)
        } else {
            return image
        }
    }
    
    fileprivate func drawHighlightOverlayForPoints(_ image: CIImage, topLeft: CGPoint, topRight: CGPoint,
                                                   bottomLeft: CGPoint, bottomRight: CGPoint) -> CIImage {
        var overlay = CIImage(color: CIColor(red: 1.0, green: 0, blue: 0, alpha: 0.5))
        overlay = overlay.cropping(to: image.extent)
        overlay = overlay.applyingFilter("CIPerspectiveTransformWithExtent",
                                         withInputParameters: [
                                            "inputExtent": CIVector(cgRect: image.extent),
                                            "inputTopLeft": CIVector(cgPoint: topLeft),
                                            "inputTopRight": CIVector(cgPoint: topRight),
                                            "inputBottomLeft": CIVector(cgPoint: bottomLeft),
                                            "inputBottomRight": CIVector(cgPoint: bottomRight)
            ])
        return overlay.compositingOverImage(image)
    }
    
    fileprivate func correctPerspectiveFeature(_ feature: CIRectangleFeature, image: CIImage) -> CIImage {
        let params: [String: Any] = [
            "inputTopLeft": CIVector(cgPoint: feature.topLeft),
            "inputTopRight": CIVector(cgPoint: feature.topRight),
            "inputBottomLeft": CIVector(cgPoint: feature.bottomLeft),
            "inputBottomRight": CIVector(cgPoint: feature.bottomRight),
            ]
        
        return image.applyingFilter("CIPerspectiveCorrection", withInputParameters: params)
    }
}


extension CIImage {
    
    var contrastFilter: CIImage {
        return CIFilter(name: "CIColorControls", withInputParameters: ["inputContrast":1.1, kCIInputImageKey: self])!.outputImage!
    }
    
    var enhanceFilter: CIImage {
        return CIFilter(name: "CIColorControls", withInputParameters: ["inputBrightness":0.0, "inputContrast":1.14, "inputSaturation":0.0, kCIInputImageKey: self])!.outputImage!
    }
    
    var contrastFilterColor: CIImage {
        return CIFilter(name: "CIColorControls",
                        withInputParameters: [kCIInputContrastKey: 1.1, /// was  1.1
                            kCIInputImageKey: self])!.outputImage!
    }
    
    fileprivate func blackAndWhite(_ image: CIImage) -> CIImage {
        return CIFilter(name: "CIColorControls",
                        withInputParameters: [kCIInputBrightnessKey: 0.0,
                                              kCIInputContrastKey: 1.14,
                                              kCIInputSaturationKey: 0.0,
                                              kCIInputImageKey: image])!.outputImage!
    }
    
    var grayScaleFilter: CIImage {
        return CIFilter(name: "CIPhotoEffectMono",
                        withInputParameters: [kCIInputImageKey: self])!.outputImage!
    }
}
