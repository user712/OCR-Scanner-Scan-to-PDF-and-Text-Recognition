//
//  ViewController.swift
//  CameraTest
//
//  Created by Developer on 2/28/17.
//  Copyright © . 
//

import UIKit
import GPUImage
import AVFoundation

let deviceType = UIDevice.current.userInterfaceIdiom

class ViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet var filterView: RenderView!
    
    var videoCamera: Camera?
    
    
    // MARK: - LyfeCicle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        do {
            switch deviceType {
            case .pad:
                videoCamera = try Camera(sessionPreset: AVCaptureSessionPresetPhoto, location:.backFacing)
            case .phone:
                videoCamera = try Camera(sessionPreset: AVCaptureSessionPresetHigh, location:.backFacing)
            default:
                break
            }
            
            videoCamera?.runBenchmark = true
            videoCamera?.addTarget(filterView)
        } catch {
            videoCamera = nil
            print("Couldn't initialize camera with error: \(error)")
        }
        
        
        if let videoCamera = videoCamera {
            videoCamera.startCapture()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func viewWillDisappear(_ animated: Bool) {
        if let videoCamera = videoCamera {
            videoCamera.stopCapture()
            videoCamera.removeAllTargets()
        }
        
        super.viewWillDisappear(animated)
    }
}

