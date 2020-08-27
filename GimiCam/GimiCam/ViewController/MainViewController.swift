//
//  MainViewController.swift
//  GimiCam
//
//  Created  on 3/4/17.
//  Copyright © 2017 A. 
//

import UIKit
import QuickLook

class MainViewController: UIViewController {

    // MARK: - Properties
    
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
}


// MARK: - @IBAction's

extension MainViewController {
    
    @IBAction func cameraTapped() {
        if let cameraController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "CameraViewController") as? CameraViewController {
            cameraController.captureDelegate = self
            self.present(cameraController, animated: true, completion: nil)
        }
    }
}


// MARK: - CaptureViewControllerDelegate

extension MainViewController: CaptureViewControllerDelegate {
    
    func captureViewController(_ controller: CameraViewController, didCaptureStillImage image: UIImage?) {
        if let image = image, let imageData = UIImageJPEGRepresentation(image, 1) {
            try? imageData.write(to: itemURL)
            qlController.reloadData()
            controller.present(qlController, animated: true, completion: {
                
            })
        }
    }
}
