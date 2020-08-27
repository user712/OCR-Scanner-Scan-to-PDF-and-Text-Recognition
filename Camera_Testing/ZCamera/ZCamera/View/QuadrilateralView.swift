//
//  QuadrilateralView.swift
//  ZCamera
//
//  Created by Developer on 3/10/17.
//  Copyright © . 
//

import UIKit
import AVFoundation

class QuadrilateralView: UIView {

    // MARK: - Properties
    
    fileprivate let rectangleDetector = RectangleManager()
    
    var image: UIImage?
    var session = AVCaptureSession()
    var device = AVCaptureDevice.devices().filter { (position) -> Bool in
        if let dev = position as? AVCaptureDevice{
            if (dev.position == .back){
                return true
            }
        }
        return false
    }
    
    lazy var videoInput : AVCaptureDeviceInput? = {
        if let device = self.device.first as? AVCaptureDevice{
            device.activeVideoMinFrameDuration = CMTimeMake(1, 30)
            device.activeVideoMaxFrameDuration = CMTimeMake(1, 30)
            let lazilyVideoInput = try? AVCaptureDeviceInput(device: device)
            return lazilyVideoInput
        }
        return nil
    }()
    
    lazy var videoOutput: AVCaptureVideoDataOutput? = {
        let output = AVCaptureVideoDataOutput()
        let format = kCVPixelFormatType_32BGRA
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable : Int(format)]
        output.alwaysDiscardsLateVideoFrames = true
        let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutputQueue", attributes: [])
        output.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        return output
    }()
    
    lazy var preview:AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer.init(session: self.session)
        layer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        return layer!
    }()
    
    lazy var quadView: QuadrilateralShowView = {
        let view = QuadrilateralShowView(frame: self.bounds)
        return view
    }()

    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
        self.session.startRunning()
        setupCamera()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit{
        self.session.stopRunning()
    }
    
    override func layoutSubviews() {
        self.preview.frame = self.bounds
    }
    
    
    // MARK: - Setup Camera
    
    func setupCamera(){
        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        }
        if session.canAddOutput(videoOutput){
            session.addOutput(videoOutput)
        }
        videoOutput?.connection(withMediaType: AVMediaTypeVideo).videoOrientation = .portrait
        self.layer.insertSublayer(preview, at: 0)
        self.addSubview(self.quadView)
    }
}


// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension QuadrilateralView: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
        let image = rectangleDetector.fixImageOrientation(rectangleDetector.imageFromSampleBuffer(sampleBuffer))
        guard let ciImage = CIImage(image: image) else { return }
        let points = rectangleDetector.quadfromImage(ciImage, quardView: quadView)
        
        DispatchQueue.main.async { [unowned self] in
            self.quadView.drawRectanglePath(points, imageSize: image.size, viewSize: self.bounds.size)
        }
    }
}























