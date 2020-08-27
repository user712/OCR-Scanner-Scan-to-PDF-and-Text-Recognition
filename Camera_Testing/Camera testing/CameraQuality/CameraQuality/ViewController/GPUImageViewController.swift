//
//  GPUImageViewController.swift
//  CameraQuality
//
//  Created by Developer on 3/1/17.
//  Copyright © 2017 
//

//        pictureOutput.encodedImageAvailableCallback = { imageData in
//            try? imageData.write(to: self.itemURL)
//            self.qlController.reloadData()
//            self.present(self.qlController, animated: true, completion: { [unowned self] in
//                self.stopCaptureSession()
//            })
//        }
//

//        pictureOutput.imageAvailableCallback = { image in
//            // Do something with the image
//            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
//        }



import UIKit
import GPUImage
import AVFoundation
import QuickLook
import GLKit
import OpenGLES
import CoreMedia
import CoreImage
import QuartzCore

class GPUImageViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var renderView: RenderView!
    
    fileprivate var videoCamera: Camera?
    fileprivate let pictureOutput = PictureOutput()
    
    fileprivate var qlController: QLPreviewController!
    fileprivate var previewItem: PreviewItem!
    fileprivate var pdfDatasource: PreviewDatasource!
    fileprivate let itemURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("capture.jpg")
    fileprivate var shapeLayer = CAShapeLayer()
    fileprivate var timeKeeper: Timer?
    fileprivate var borderDetectFrame: Bool = false
    fileprivate var borderDetectLastRectangleFeature: CIRectangleFeature?
    fileprivate var glkView: GLKView?
    fileprivate var context: EAGLContext?
    fileprivate var coreImageContext: CIContext?
    
    
    
    // MARK: - LyfeCicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        qlController = QLPreviewController()
        previewItem = PreviewItem(itemURL: itemURL, itemTitle: itemURL.deletingPathExtension().lastPathComponent)
        pdfDatasource = PreviewDatasource(previewItem: previewItem)
        qlController.dataSource = pdfDatasource
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startCaptureSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopCaptureSession()
    }
    
    
    fileprivate func startCaptureSession() {
        do {
            videoCamera = try Camera(sessionPreset: AVCaptureSessionPresetHigh, location: .backFacing)
            videoCamera?.delegate = self
            videoCamera?.runBenchmark = true
            videoCamera?.addTarget(renderView)
            
//            renderView.layer.addSublayer(shapeLayer)
            
            self.timeKeeper = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(enableBorderDetection), userInfo: nil, repeats: true)
//            self.view.layer.addSublayer(shapeLayer)
            self.setupGLKView()
            videoCamera?.startCapture()
        } catch {
            videoCamera = nil
            print("Couldn't initialize camera with error: \(error)")
        }
        
        videoCamera?.addTarget(pictureOutput)
        pictureOutput.encodedImageFormat = .jpeg
    }
    
    fileprivate func stopCaptureSession() {
        if let videoCamera = videoCamera {
            videoCamera.stopCapture()
            videoCamera.removeAllTargets()
            self.timeKeeper?.invalidate()
        }
    }
    
    func enableBorderDetection() {
        self.borderDetectFrame = true
    }
    
    fileprivate func setupGLKView() {
        if let _ = self.context {
            return
        }
        
        self.context = EAGLContext(api: .openGLES2)
        self.glkView = GLKView(frame: renderView.bounds, context: self.context!)
        self.glkView?.frame = renderView.frame
        self.glkView?.autoresizingMask = ([UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight])
        self.glkView?.translatesAutoresizingMaskIntoConstraints = true
        self.glkView?.contentScaleFactor = 1.0
        self.glkView?.drawableDepthFormat = .format24
        self.view.insertSubview(self.glkView!, at: 0)
        
        if var renderBuffer = self.renderView.displayRenderbuffer {
            glGenRenderbuffers(1, &renderBuffer)
            glBindRenderbuffer(GLenum(GL_RENDERBUFFER), renderBuffer)
        }
        
        self.coreImageContext = CIContext(eaglContext: self.context!, options: [kCIContextUseSoftwareRenderer: true])
        EAGLContext.setCurrent(self.context!)
    }
}


extension GPUImageViewController {
    
    @IBAction func takeTapped() {

        pictureOutput.imageAvailableCallback = { image in
            if let photoVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PhotoViewController") as? PhotoViewController {
                photoVC.takenPhoto = image
                let navController = UINavigationController(rootViewController: photoVC)
                
                self.present(navController, animated: true, completion: { [unowned self] in
                    self.stopCaptureSession()
                })
            }
        }
    }
}


extension GPUImageViewController: CameraDelegate {
    
    func didCaptureBuffer(_ sampleBuffer: CMSampleBuffer) {
        print("didCaptureBuffer")

        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            
            if self.borderDetectFrame {
                self.borderDetectLastRectangleFeature = RectangleDetector.main.detectRectangularFeature(ciImage)
                self.borderDetectFrame = false
            }
            
            
            if let rectangeFeature = RectangleDetector.main.detectRectangularFeature(ciImage) {
                print(rectangeFeature.bounds)
                self.shapeLayer.draw(inRect: self.renderView.frame, ciImage: ciImage, biggestRectangleFeature: rectangeFeature)
            }
            
            if let context = self.context, let ciContext = self.coreImageContext, let glkView = self.glkView {
                ciContext.draw(ciImage, in: renderView.bounds, from: ciImage.extent)
                context.presentRenderbuffer(Int(GL_RENDERBUFFER))
                glkView.setNeedsDisplay()
            }
        }
    }
    
    func getImageFromSampleBuffer(_ buffer:CMSampleBuffer) -> UIImage? {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            
            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
            
            if let image = context.createCGImage(ciImage, from: imageRect) {
                return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right)
            }
            
        }
        
        return nil
    }
}
