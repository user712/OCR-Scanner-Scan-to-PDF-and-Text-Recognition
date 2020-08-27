//
//  CameraViewController.swift
//  CameraTest
//
//  Created by Developer on 2/28/17.
//  Copyright © . 
//

import UIKit
import GPUImage
import AVFoundation

class CameraViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet var filterView: RenderView!
    fileprivate var videoCamera: VideoCamera?
    
    
    // MARK: - LyfeCicle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        videoCamera = VideoCamera(superview: filterView)
        videoCamera?.startCapture()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let videoCamera = videoCamera {
            videoCamera.stopCapture()

        }
        
        super.viewWillDisappear(animated)
    }

}
