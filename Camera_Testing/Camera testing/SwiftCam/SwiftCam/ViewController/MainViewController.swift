//
//  MainViewController.swift
//  SwiftCam
//
//  Created by Developer on 3/3/17.
//  Copyright © . 
//

import UIKit
import AVFoundation
import QuickLook

class MainViewController: UIViewController {

    // MARK: - Properties
    
    fileprivate lazy var captureController: CaptureViewController = {
        let controller = CaptureViewController(inputs: [.video])
        controller.captureDelegate = self
//        controller.captureManager.dataOutputDelegate = self
        
        return controller
    }()
    
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
        qlController.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    // MARK: - Transitions
    
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        captureController.captureManager.refreshOrientation()
    }
}


// MARK: - CaptureViewControllerDelegate

extension MainViewController: CaptureViewControllerDelegate {
    
    func captureViewController(_ controller: CaptureViewController, didCaptureStillImage image: UIImage?) {
        controller.dismiss(animated: true)
        
        guard let image = image else {
            print("Woops, we didn't get an image!")
            return
        }
        
//        imageView.image = img
        
        
        if let dataImage = UIImageJPEGRepresentation(image, 1) {
            try? dataImage.write(to: self.itemURL)
            self.qlController.reloadData()
            self.present(self.qlController, animated: true, completion: nil)
        }
    }
}


//// MARK: - VideoDataOutputDelegate
//
//extension MainViewController: VideoDataOutputDelegate {
//    
//    func captureManagerDidOutput(_ sampleBuffer: CMSampleBuffer) {
//        print(1)
//    }
//}


// MARK: - QLPreviewControllerDelegate

extension MainViewController: QLPreviewControllerDelegate {
    
    func previewControllerWillDismiss(_ controller: QLPreviewController) {
        present(captureController, animated: true, completion: nil)
    }
}


extension MainViewController {
    
    @IBAction func handleTakePictureButton(_ sender: UIButton) {
        present(captureController, animated: true, completion: nil)
    }
}
