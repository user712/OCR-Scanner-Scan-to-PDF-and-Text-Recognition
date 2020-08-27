////
////  CameraViewController.swift
////  CameraQuality
////
////  Created  on 2/28/17.
////  Copyright © 2017 
////
//
//import UIKit
//import QuickLook
//
//class CameraViewController: UIViewController {
//
//    // MARK: - Properties
//    
//    @IBOutlet weak var takePictureButton: UIButton!
//    
//    fileprivate var qlController: QLPreviewController!
//    fileprivate var previewItem: PreviewItem!
//    fileprivate var pdfDatasource: PreviewDatasource!
//    fileprivate var videoCamera: Camera!
//    fileprivate let itemURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("capture.jpg")
//    
//    
//    // MARK: - LyfeCicle
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Do any additional setup after loading the view.
//        
//        qlController = QLPreviewController()
//        previewItem = PreviewItem(itemURL: itemURL, itemTitle: itemURL.deletingPathExtension().lastPathComponent)
//        pdfDatasource = PreviewDatasource(previewItem: previewItem)
//        qlController.dataSource = pdfDatasource
//        
//        videoCamera = Camera(superView: self.view, captureCompletion: nil)
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        videoCamera.startCaptureSession()
//        self.view.bringSubview(toFront: takePictureButton)
//    }
//
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        videoCamera.stopCaptureSession()
//    }
//}
//
//
//extension CameraViewController {
//    
//    @IBAction func takePhotoTapped() {
//        self.videoCamera.captureImage { [unowned self] (image) in
////            let photoVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PhotoVC") as! PhotoViewController
////            photoVC.takenPhoto = image
////            self.present(photoVC, animated: true, completion: { [unowned self] in
////                self.videoCamera.stopCaptureSession()
////            })
//            
//            
//            if let dataImage = UIImageJPEGRepresentation(image, 1) {
//                try? dataImage.write(to: self.itemURL)
//                self.qlController.reloadData()
//                self.present(self.qlController, animated: true, completion: { [unowned self] in
//                    self.videoCamera.stopCaptureSession()
//                })
//            }
//        }
//    }
//}
