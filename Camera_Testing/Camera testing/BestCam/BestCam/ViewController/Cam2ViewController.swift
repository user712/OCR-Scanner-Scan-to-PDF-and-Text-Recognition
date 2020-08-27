//
//  Cam2ViewController.swift
//  BestCam
//
//  Created by Developer on 3/3/17.
//  Copyright © . 
//

import UIKit
import AVFoundation


protocol VideoDataOutputDelegate: class {
    func captureManagerDidOutput(_ sampleBuffer: CMSampleBuffer, rectangleLayer: CAShapeLayer, previewLayerProvider: AVCaptureVideoPreviewLayer)
}


class Camera2ViewController: UIViewController {
    
    // MARK: - Properties
    
    var previewView: UIView!
    var boxView: UIView!
    let myButton = UIButton()
    
    
    weak var dataOutputDelegate: VideoDataOutputDelegate?
    fileprivate let rectangleDetector = RectangleDetector()
    fileprivate var rectangeLayer = CAShapeLayer()
    
    //Camera Capture requiered properties
    var videoDataOutput: AVCaptureVideoDataOutput!
    var videoDataOutputQueue: DispatchQueue!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var captureDevice: AVCaptureDevice!
    let session = AVCaptureSession()
    
    
    // MARK: - LyfeCicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        previewView = UIView(frame: CGRect(x: 0,
                                           y: 0,
                                           width: UIScreen.main.bounds.size.width,
                                           height: UIScreen.main.bounds.size.height))
        previewView.contentMode = UIViewContentMode.scaleAspectFit
        view.addSubview(previewView)
        self.setupAVCapture()
        
        self.dataOutputDelegate = rectangleDetector
    }
    
    
    // MARK: - Rotation
    
    override var shouldAutorotate: Bool {
        if (UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft ||
            UIDevice.current.orientation == UIDeviceOrientation.landscapeRight ||
            UIDevice.current.orientation == UIDeviceOrientation.unknown) {
            return false
        } else {
            return true
        }
    }
}


// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension Camera2ViewController:  AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func setupAVCapture() {
        session.sessionPreset = AVCaptureSessionPresetPhoto
        if #available(iOS 10.0, *) {
            guard let device = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .back) else {
                return
            }
            
            captureDevice = device
        } else {
            // Fallback on earlier versions
            
            if let aviableDevices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as? [AVCaptureDevice] {
                captureDevice = aviableDevices.first
            }
        }
        
        beginSession()
    }
    
    func beginSession() {
        var err : NSError? = nil
        var deviceInput:AVCaptureDeviceInput?
        
        do {
            deviceInput = try AVCaptureDeviceInput(device: captureDevice)
        } catch let error as NSError {
            err = error
            deviceInput = nil
        }
        
        if err != nil {
            print("error: \(err?.localizedDescription)");
        }
        
        if self.session.canAddInput(deviceInput){
            self.session.addInput(deviceInput);
        }
        
        videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutputQueue = DispatchQueue(label: "VideoDataOutputQueue")
        videoDataOutput.setSampleBufferDelegate(self, queue:self.videoDataOutputQueue)
        
        if session.canAddOutput(self.videoDataOutput) {
            session.addOutput(self.videoDataOutput)
        }
        
        videoDataOutput.connection(withMediaType: AVMediaTypeVideo).isEnabled = true
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        let rootLayer: CALayer = self.previewView.layer
        rootLayer.masksToBounds = true
        self.previewLayer.frame = rootLayer.bounds
        rootLayer.addSublayer(self.previewLayer)
        
        rootLayer.addSublayer(rectangeLayer)
        
        session.startRunning()
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!,  didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        // do stuff here
        
        DispatchQueue.main.async { [unowned self] in
            self.dataOutputDelegate?.captureManagerDidOutput(sampleBuffer, rectangleLayer: self.rectangeLayer, previewLayerProvider: self.previewLayer)
        }
    }
    
    // clean up AVCapture
    func stopCamera(){
        session.stopRunning()
    }
}






class RectangleDetector: VideoDataOutputDelegate {
    
    // MARK: - Properties
    
    fileprivate var detector: CIDetector!
    fileprivate var counter = 0
    fileprivate var borderDetectLastRectangleFeature: CIRectangleFeature?
    fileprivate var timeKeeper: Timer?
    fileprivate var borderDetectFrame = false
    
    
    // MARK: - Initializers
    
    init() {
        detector = self.buildRectangleDetector
        self.timeKeeper = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(enableBorderDetection), userInfo: nil, repeats: true)
        //RunLoop.current.add(self.timeKeeper!, forMode: RunLoopMode.commonModes)
    }
    
    
    // MARK: - Border Detections
    
    @objc fileprivate func enableBorderDetection() {
        self.borderDetectFrame = true
    }
    
    /// -----------------------
    /// Create feature detector
    fileprivate var buildRectangleDetector: CIDetector {
        let options: [String: Any] = [CIDetectorAccuracy: CIDetectorAccuracyHigh, CIDetectorAspectRatio: 1.41]
        
        return CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: options)!
    }
    
    
    /// Calculates a comparable value of rectangle value
    /// i.e. half of perimeter
    fileprivate func featureSize(_ feature: CIRectangleFeature) -> Float {
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
    
    func captureManagerDidOutput(_ sampleBuffer: CMSampleBuffer, rectangleLayer: CAShapeLayer, previewLayerProvider: AVCaptureVideoPreviewLayer) {
        counter += 1
        print("\(counter) frames")
        
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetHeight(pixelBuffer), height: CVPixelBufferGetWidth(pixelBuffer))
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            
            print("borderDetectFrame before \(borderDetectFrame)")
            
            if self.borderDetectFrame {
                self.borderDetectLastRectangleFeature = self.detectRectangularFeature(ciImage)
                self.borderDetectFrame = false
            }
            
            print("borderDetectFrame after \(borderDetectFrame)")
            let previewRect = previewLayerProvider.frame
            let cameraLayer = previewLayerProvider
            
            if let lastRectFeature = self.borderDetectLastRectangleFeature {
                
                self.drawRectangleLayer(inRect: rectangleLayer, previewRect: previewRect, imageRect: ciImage.extent, biggestRectangleFeature: lastRectFeature)
                
                print("lastRectFeature.bounds = \(lastRectFeature.bounds)\n\n")
                print("rectangleLayer.bounds = \(rectangleLayer.bounds)")
                print("imageRect = \(imageRect)")
                print("ciImage.extent = \(ciImage.extent)")
                print("previewLayerProvider?.previewLayer.frame = \(previewRect)")
                
                cameraLayer.setNeedsDisplay()
            } else {
                self.hideRectangleLayer(rectangleLayer)
            }
        }
    }
    
    func drawRectangleLayer(inRect layer: CAShapeLayer, previewRect: CGRect, imageRect: CGRect, biggestRectangleFeature: CIRectangleFeature) {
        //        let imageRect: CGRect = ciImage.extent
        let shapeFillColor = UIColor.blue.withAlphaComponent(0.3).cgColor
        let shapeStrokeColor = UIColor.blue.cgColor
        
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
        
        if layer.path != path.cgPath {
            let animation = CABasicAnimation(keyPath: "path")
            animation.fromValue = layer.path
            animation.toValue   = path.cgPath
            animation.duration  = 0.25
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut) // kCAMediaTimingFunctionEaseOut /// kCAMediaTimingFunctionEaseInEaseOut
            animation.isRemovedOnCompletion = false
            animation.fillMode = kCAFillModeBoth
            
            layer.add(animation, forKey: animation.keyPath)
        }
        
        layer.fillColor = shapeFillColor
        layer.strokeColor = shapeStrokeColor
        layer.lineWidth = 1.5
        layer.path = path.cgPath
    }
    
    func hideRectangleLayer(_ layer: CAShapeLayer) {
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.clear.cgColor
        layer.lineWidth = 0.0
        layer.removeAnimation(forKey: "path")
    }
}
