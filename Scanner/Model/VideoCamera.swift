//
//  VideoCamera.swift
//  Scanner
//
//   on 1/23/17.
//   
//

import UIKit
import GLKit
import OpenGLES
import CoreMedia
import CoreImage
import QuartzCore
import AVFoundation

protocol CameraLifeCiclable: class {
    func cameraDidEnterBackground()
    func cameraDidEnterForeground()
}

enum VideoCameraFilterType: Int {
    case color, blackAndWhite, grayScale
}

enum CameraFlashMode: Int {
    case off, on, auto
}


enum ImageByFilterType {
    case color, blackAndWhite, grayScale
}

class VideoCamera: NSObject {
    
    // MARK: - Properties
    
    var borderDetectionEnabled = true
    var cameraView: VideoCameraView!
    var borderDetectionFrameColor: UIColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)
    
    var imageFilter: VideoCameraFilterType = .color {
        didSet {
            if let glkView = self.glkView {
                let effect = UIBlurEffect(style: .dark)
                let effectView = UIVisualEffectView(effect: effect)
                effectView.frame = cameraView.bounds
                cameraView.insertSubview(effectView, aboveSubview: glkView)
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.25 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
                                              execute: { () -> Void in
                                                effectView.removeFromSuperview()
                })
            }
        }
    }
    
    var cameraFlashMode: CameraFlashMode = .off {
        didSet {
            if captureSession.isRunning {
                if cameraFlashMode != oldValue {
                    self.updateFlasMode(cameraFlashMode)
                }
            }
        }
    }
    
    fileprivate var isCameraAvailable: Bool {
        return UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    fileprivate var isTorchAvailable: Bool {
        if let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as? [AVCaptureDevice] {
            return !devices.filter({ $0.hasTorch }).isEmpty
        }
        
        return false
    }
    
    fileprivate var captureSession = AVCaptureSession()
    fileprivate var captureDevice: AVCaptureDevice?
    fileprivate var objCaptureDeviceInput: AVCaptureDeviceInput?
    fileprivate var context: EAGLContext?
    fileprivate var stillImageOutput = AVCaptureStillImageOutput()
    fileprivate var forceStop: Bool = false
    fileprivate var coreImageContext: CIContext?
    fileprivate var renderBuffer: GLuint = 0
    fileprivate var glkView: GLKView?
    fileprivate var stopped: Bool = false
    fileprivate var imageDetectionConfidence = 0.0
    fileprivate var borderDetectFrame: Bool = false
    fileprivate var borderDetectLastRectangleFeature: CIRectangleFeature?
    fileprivate var capturing: Bool = false
    fileprivate var timeKeeper: Timer?
    fileprivate var filterImageManager: ImageFilterManager?
    fileprivate static let highAccuracyRectangleDetector = CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
    fileprivate var shapeLayer = CAShapeLayer()
    
    // MARK: - Initializers
    
    init(cameraView: VideoCameraView) {
        self.cameraView = cameraView
        filterImageManager = ImageFilterManager()
        cameraView.layer.addSublayer(shapeLayer)
        
        super.init()
        
        self.setupCameraView()
        self.cameraView.cameraLifeCicleDelegate = self
        self.cameraView.flashableDelegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(cameraDidEnterBackground), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(cameraDidEnterForeground), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    
    // MARK: - Deinitializers
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        filterImageManager = nil
        timeKeeper = nil
        borderDetectLastRectangleFeature = nil
        glkView = nil
        coreImageContext = nil
        context = nil
        objCaptureDeviceInput = nil
        captureDevice = nil
    }
}

extension VideoCamera {
    
    fileprivate func setupCameraView() {
        self.setupGLKView()
        
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
    
    func start() {
        self.stopped = false
        self.captureSession.startRunning()
        self.hideGlkView(false, completion: nil)
        self.timeKeeper = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(enableBorderDetection), userInfo: nil, repeats: true)
//        RunLoop.current.add(self.timeKeeper!, forMode: RunLoopMode.commonModes)
    }
    
    
    func stop() {
        self.stopped = true
        self.captureSession.stopRunning()
        self.hideGlkView(true, completion: nil)
        self.timeKeeper?.invalidate()
    }
    
}

extension VideoCamera: CameraLifeCiclable {
    
    internal func cameraDidEnterBackground() {
        self.forceStop = true
    }
    
    internal func cameraDidEnterForeground() {
        self.forceStop = false
    }
}

extension VideoCamera {
    
    func enableBorderDetection() {
        self.borderDetectFrame = true
    }
    
    fileprivate func setupGLKView() {
        if let _ = self.context {
            return
        }
        
        self.context = EAGLContext(api: .openGLES2)
        self.glkView = GLKView(frame: cameraView.bounds, context: self.context!)
        self.glkView?.frame = cameraView.frame
        self.glkView!.autoresizingMask = ([UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight])
        self.glkView!.translatesAutoresizingMaskIntoConstraints = true
        self.glkView!.contentScaleFactor = 1.0
        self.glkView!.drawableDepthFormat = .format24
        
        self.glkView!.layer.minificationFilter = kCAFilterTrilinear
        self.glkView!.layer.shouldRasterize = true
        self.glkView!.layer.rasterizationScale = UIScreen.main.scale
        
        cameraView.insertSubview(self.glkView!, at: 0)
        glGenRenderbuffers(1, &self.renderBuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), self.renderBuffer)
        
        self.coreImageContext = CIContext(eaglContext: self.context!, options: [kCIContextUseSoftwareRenderer: true])
        EAGLContext.setCurrent(self.context!)
    }
    
    fileprivate func hideGlkView(_ hide: Bool, completion:( () -> Void)?) {
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.glkView?.alpha = (hide) ? 0.0 : 1.0
        }, completion: { (finished) -> Void in
            completion?()
        })
    }
}


// MARK: - Detection Confidence Valid

extension VideoCamera {
    
    fileprivate func detectionConfidenceValid() -> Bool {
        return (self.imageDetectionConfidence > 1.0)
    }
}


// MARK: - Flashable

extension VideoCamera: ViewFlashable {
    
    var focus: CGPoint {
        get {
            guard let device = objCaptureDeviceInput?.device else { return CGPoint.zero }
            if isCameraAvailable {
                return cameraView.focusWithCaptureDevice(device)
            }
            
            return CGPoint.zero
        }
        
        set {
            guard let device = objCaptureDeviceInput?.device else { return }
            if isCameraAvailable {
                cameraView.setFocus(newValue, withCaptureDevice: device)
            }
        }
    }
}


// MARK: - FlashMode

extension VideoCamera {
    
    fileprivate func updateFlasMode(_ flashMode: CameraFlashMode) {
        self.captureSession.beginConfiguration()
        if let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as? [AVCaptureDevice] {
            for device in devices {
                if device.position == .back {
                    if let avFlashMode = AVCaptureFlashMode(rawValue: flashMode.rawValue) {
                        if device.isFlashModeSupported(avFlashMode) {
                            do {
                                try device.lockForConfiguration()
                            } catch { return }
                            device.flashMode = avFlashMode
                            device.unlockForConfiguration()
                        }
                    }
                }
            }
        }
        
        self.captureSession.commitConfiguration()
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
        
//        glkView!.layer.minificationFilter = kCAFilterTrilinear
//        glkView!.layer.shouldRasterize = true
//        glkView!.layer.rasterizationScale = UIScreen.main.scale
        
        if self.borderDetectionEnabled {
            if self.borderDetectFrame {
                self.borderDetectLastRectangleFeature = RectangleDetector.main.detectRectangularFeature(image)
                self.borderDetectFrame = false
            }
            
            if let lastRectFeature = self.borderDetectLastRectangleFeature {
                self.imageDetectionConfidence += 0.5

                self.shapeLayer.draw(inRect: self.cameraView.frame, ciImage: image, biggestRectangleFeature: lastRectFeature)
                
                print("lastRectFeature.bounds = \(lastRectFeature.bounds)\n\n")
                print("image.frame = \(image.extent)")
                print("self.cameraView.frame = \(self.cameraView.frame)")
            } else {
                self.imageDetectionConfidence = 0.0
                self.shapeLayer.hide()
            }
            
        } else {
            self.shapeLayer.hide()
        }
        
        if let context = self.context, let ciContext = self.coreImageContext, let glkView = self.glkView {
            ciContext.draw(image, in: cameraView.bounds, from: image.extent)
            context.presentRenderbuffer(Int(GL_RENDERBUFFER))
            glkView.setNeedsDisplay()
        }
    }
}


extension CAShapeLayer {
    
    func draw(inRect previewRect: CGRect, ciImage: CIImage, biggestRectangleFeature: CIRectangleFeature) {
        let imageRect: CGRect = ciImage.extent
        let shapeFillColor = UIColor.darkSkyBlue.withAlphaComponent(0.3).cgColor
        let shapeStrokeColor = UIColor.darkSkyBlue.cgColor
        
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
        
//        if self.path != path.cgPath { ///  check and with value to be differend, bool or something else
//            let animation = CABasicAnimation(keyPath: "path")
//            animation.fromValue = self.path
//            animation.toValue  = path.cgPath
//            animation.duration = 2.5
//            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
//            // kCAMediaTimingFunctionEaseOut /// kCAMediaTimingFunctionEaseInEaseOut /// kCAMediaTimingFunctionLinear
//            
//            animation.isRemovedOnCompletion = false
//            
//            animation.fillMode = kCAFillModeBoth
//            ///kCAFillModeBoth /// kCAFillModeForwards
//            
//            self.add(animation, forKey: "path")
//        }
        
        if self.path != path.cgPath {
            let animation = CABasicAnimation(keyPath: "path")
            animation.fromValue = self.path
            animation.toValue   = path.cgPath
            animation.duration  = 0.25
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut) // kCAMediaTimingFunctionEaseOut /// kCAMediaTimingFunctionEaseInEaseOut
            animation.isRemovedOnCompletion = false
            animation.fillMode = kCAFillModeBoth
            animation.delegate = self
            
            self.add(animation, forKey: animation.keyPath)
        }
        
        self.fillColor = shapeFillColor
        self.strokeColor = shapeStrokeColor
        self.lineWidth = 1.5
        self.path = path.cgPath
    }
    
    func hide() {
        self.fillColor = UIColor.clear.cgColor
        self.strokeColor = UIColor.clear.cgColor
        self.lineWidth = 0.0
        self.removeAnimation(forKey: "path")
    }
}

extension CAShapeLayer: CAAnimationDelegate {
    
    public func animationDidStart(_ anim: CAAnimation) {
        print("animation start")
    }
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        print("stop animaton")
    }
}


// MARK: - Capture Image

extension VideoCamera {
    
    func captureImage(_ completion: @escaping (UIImage) -> ()) {
        if self.capturing { return }
        
        self.hideGlkView(true) { [unowned self] in
            self.hideGlkView(false, completion: nil)
        }
        
        self.capturing = true
        
        var videoConnection: AVCaptureConnection?
        for connection in self.stillImageOutput.connections as! [AVCaptureConnection] {
            for port in connection.inputPorts as! [AVCaptureInputPort] {
                if port.mediaType == AVMediaTypeVideo {
                    videoConnection = connection
                    break
                }
            }
            
            if let _ = videoConnection { break }
        }
        
        self.stillImageOutput.captureStillImageAsynchronously(from: videoConnection!) { [unowned self] (imageSampleBuffer, error) in
            let jpg = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageSampleBuffer)
            var enhancedImage: CIImage = CIImage(data: jpg!)!
            
            var imageForCompletion = CIImage()
            
            if let filteredImage = self.filterImageManager?.filterImage(enhancedImage, filterType: self.imageFilter) {
                enhancedImage = filteredImage
                imageForCompletion = filteredImage
            }
            
            if self.borderDetectionEnabled && self.detectionConfidenceValid() {
                enhancedImage = imageForCompletion
            }
            
            UIGraphicsBeginImageContext(CGSize(width: enhancedImage.extent.size.height, height: enhancedImage.extent.size.width))
            
            UIImage(ciImage: enhancedImage, scale: 1.0,
                    orientation: UIImageOrientation.right).draw(in: CGRect(x: 0, y: 0,
                                                                           width: enhancedImage.extent.size.height,
                                                                           height: enhancedImage.extent.size.width))
            
            if let image = UIGraphicsGetImageFromCurrentImageContext() {
                UIGraphicsEndImageContext()
                
                self.hideGlkView(false, completion: nil)
                completion(image)
            }
        }
        
        self.capturing = false
    }
}
