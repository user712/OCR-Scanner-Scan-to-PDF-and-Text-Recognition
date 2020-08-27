//
//  GPUImageViewController.swift
//  GimiCam
//
//  Created  on 3/6/17.
//  Copyright © 2017 A. 
//

import UIKit
import GPUImage
import AVFoundation
import QuickLook

class GPUImageViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet weak var filterView: RenderView!
    @IBOutlet weak var cameraButton: UIButton!
    
    var videoCamera: Camera!
    let pictureOutput = PictureOutput()
    fileprivate var qlController: QLPreviewController!
    fileprivate var previewItem: PreviewItem!
    fileprivate var pdfDatasource: PreviewDatasource!
    fileprivate let itemURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("capture.jpg")
    
    
    // MARK: - LyfeCicle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        do {
            videoCamera = try Camera(sessionPreset: AVCaptureSessionPresetPhoto, location: .backFacing)
            videoCamera.runBenchmark = true
            videoCamera.addTarget(filterView)
            videoCamera.startCapture()
            filterView.fillMode = .preserveAspectRatioAndFill
            pictureOutput.encodedImageFormat = .jpeg
            videoCamera --> pictureOutput
        } catch {
            videoCamera = nil
            print("Couldn't initialize camera with error: \(error)")
        }

        ///
        qlController = QLPreviewController()
        previewItem = PreviewItem(itemURL: itemURL, itemTitle: itemURL.deletingPathExtension().lastPathComponent)
        pdfDatasource = PreviewDatasource(previewItem: previewItem)
        qlController.dataSource = pdfDatasource
        
        filterView.addSubview(cameraButton)
        filterView.bringSubview(toFront: cameraButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func takeTapped() {
        pictureOutput.encodedImageAvailableCallback = { [unowned self] imageData in
            // Do something with the NSData
            
            try? imageData.write(to: self.itemURL)
            
            DispatchQueue.main.async(execute: { 
                self.qlController.reloadData()
                self.present(self.qlController, animated: true, completion: nil)
            })
            
        }
    }
}
