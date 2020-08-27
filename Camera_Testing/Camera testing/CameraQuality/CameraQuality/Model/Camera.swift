//
//  Camera.swift
//  CameraQuality
//
//  Created  on 2/28/17.
//  Copyright © 2017 
//

import UIKit
import GLKit
import AVFoundation
import CoreMedia
import CoreImage
import OpenGLES
import QuartzCore
import ImageIO

typealias CaptureCompletion = (UIImage) -> ()

class VideoCamera: NSObject {

    // MARK: - Properties
    
    let superView: UIView
    var applyFilter: ((CIImage) -> CIImage?)?
    var videoDisplayView: GLKView!
    var videoDisplayViewBounds: CGRect!
    var renderContext: CIContext!
    var sessionQueue: DispatchQueue!
    var detector: CIDetector?
    
    fileprivate let captureSession = AVCaptureSession()
    fileprivate var stillImageOutput = AVCaptureStillImageOutput()
    fileprivate var infoLabel: UILabel!
    fileprivate var captureDevice: AVCaptureDevice?
    fileprivate var previewLayer: CALayer!
    fileprivate var shapeLayer = CAShapeLayer()
    
    
    // MARK: - Initializers
    
    init(superView: UIView, applyFilterCallback: ((CIImage) -> CIImage?)?) {
        self.superView = superView
        applyFilter = applyFilterCallback
        videoDisplayView = GLKView(frame: superView.frame, context: EAGLContext(api: .openGLES2))
//        videoDisplayView.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2))
        videoDisplayView.frame = superView.bounds
        superView.addSubview(videoDisplayView)
        superView.sendSubview(toBack: videoDisplayView)
        
        ///
        videoDisplayView.layer.addSublayer(shapeLayer)
        
        renderContext = CIContext(eaglContext: videoDisplayView.context)
        sessionQueue = DispatchQueue(label: "AVSessionQueue",attributes: [])
        
        videoDisplayView.bindDrawable()
        videoDisplayViewBounds = CGRect(x: 0, y: 0, width: videoDisplayView.drawableWidth, height: videoDisplayView.drawableHeight)
    }
    
    
    // MARK: - Deinitializers
    
    deinit {
        
    }
}


extension VideoCamera {
    
    fileprivate func prepareCamera() {
        self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        
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
        stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG, AVVideoScalingModeKey: AVVideoScalingModeResize]
        
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(captureDeviceInput)
        } catch {
            print(error.localizedDescription)
        }
        
        if let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) {
            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            self.previewLayer = previewLayer
            self.videoDisplayView.layer.addSublayer(self.previewLayer)
            self.previewLayer.frame = self.videoDisplayView.layer.frame
            captureSession.startRunning()
            /// Check here
            
            let dataOutput = AVCaptureVideoDataOutput()
            dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString): NSNumber(value: kCVPixelFormatType_32BGRA)]
            dataOutput.alwaysDiscardsLateVideoFrames = true
            
            if captureSession.canAddOutput(dataOutput) {
                captureSession.addOutput(dataOutput)
            }
            
            if captureSession.canAddOutput(stillImageOutput) {
                captureSession.addOutput(stillImageOutput)
            }
            
            captureSession.commitConfiguration()
            
            let queue = DispatchQueue(label: "com.mihailsalari.captureQueue")
            dataOutput.setSampleBufferDelegate(self, queue: queue)
        }
    }
}


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
    }
}


extension VideoCamera {
    
    fileprivate func setupInfoLabel() {
        self.infoLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 220, height: 30))
        self.infoLabel.backgroundColor = UIColor.red.withAlphaComponent(0.6)
        self.infoLabel.textColor = UIColor.white
        self.infoLabel.layer.cornerRadius = 8.0
        self.infoLabel.clipsToBounds = true
        self.infoLabel.textAlignment = .center
        self.infoLabel.numberOfLines = 0
        
        self.infoLabel.center = superView.center
        self.infoLabel.alpha = 0.0
        superView.addSubview(self.infoLabel)
    }
}


// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension VideoCamera: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        
        let opaqueBuffer = Unmanaged<CVImageBuffer>.passUnretained(imageBuffer!).toOpaque()
        let pixelBuffer = Unmanaged<CVPixelBuffer>.fromOpaque(opaqueBuffer).takeUnretainedValue()
        
        let sourceImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        let detectionResult = applyFilter?(sourceImage)
        var outputImage = sourceImage
        if detectionResult != nil{
            outputImage = detectionResult!
        }
        
        
        if let rectangeFeature = RectangleDetector.main.detectRectangularFeature(outputImage) {
            self.shapeLayer.draw(inRect: self.superView.frame, ciImage: outputImage, biggestRectangleFeature: rectangeFeature)
        }
        
        
        var drawFrame = outputImage.extent
        let imageAR = drawFrame.width/drawFrame.height
        let viewAR = videoDisplayViewBounds.width/videoDisplayViewBounds.height
        if imageAR > viewAR{
            drawFrame.origin.x += (drawFrame.width - drawFrame.height * viewAR) / 2.0
            drawFrame.size.width = drawFrame.height / viewAR
        } else {
            drawFrame.origin.y += (drawFrame.height - drawFrame.width / viewAR) / 2.0
            drawFrame.size.height = drawFrame.width / viewAR
        }
        
        videoDisplayView.bindDrawable()
        if videoDisplayView.context != EAGLContext.current(){
            EAGLContext.setCurrent(videoDisplayView.context)
        }
        
        glClearColor(0.5, 0.5, 0.5, 1.0)
        glClear(0x00004000)
        
        glEnable(0x0BE2)
        glBlendFunc(1, 0x0303)
        
        renderContext.draw(outputImage, in: videoDisplayViewBounds, from: drawFrame)
        videoDisplayView.display()
    }
    
    func captureImage(_ completion: @escaping (UIImage) -> ()) {
        if let stillImageConnection = stillImageOutput.connection(withMediaType: AVMediaTypeVideo) {
            if let avCaptureOrientation = AVCaptureVideoOrientation(rawValue: UIDevice.current.orientation.rawValue) {
                
                if stillImageConnection.isVideoOrientationSupported {
                    stillImageConnection.videoOrientation = avCaptureOrientation
                }
                
                stillImageConnection.videoScaleAndCropFactor = 1
                
                stillImageOutput.captureStillImageAsynchronously(from: stillImageConnection) { (imageDataSampleBuffer, error) in
                    if let jpegData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer) {
                        if let image = UIImage(data: jpegData) {
                            completion(image)
                        }
                    }
                }
            }
        }
    }
}
