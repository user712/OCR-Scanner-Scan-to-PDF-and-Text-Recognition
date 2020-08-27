//
//  GPUImageViewController.swift
//  CameraQuality
//
//  Created by Developer on 3/1/17.
//  Copyright © 2017 
//

import UIKit
import GPUImage
import AVFoundation
import QuickLook

class GPUImageViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet weak var renderView: RenderView!
    
    fileprivate var videoCamera: Camera?
    fileprivate let pictureOutput = PictureOutput()
    
    fileprivate var qlController: QLPreviewController!
    fileprivate var previewItem: PreviewItem!
    fileprivate var pdfDatasource: PreviewDatasource!
    fileprivate let itemURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("capture.jpg")
    
    
    
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
            videoCamera?.runBenchmark = true
            videoCamera?.addTarget(renderView)
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
        }
    }
}


extension GPUImageViewController {
    
    @IBAction func takeTapped() {
        pictureOutput.encodedImageAvailableCallback = { imageData in
            try? imageData.write(to: self.itemURL)
            self.qlController.reloadData()
            self.present(self.qlController, animated: true, completion: { [unowned self] in
                self.stopCaptureSession()
            })
        }
        
        
//        pictureOutput.imageAvailableCallback = { image in
//            // Do something with the image
//            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
//        }
    }
}










