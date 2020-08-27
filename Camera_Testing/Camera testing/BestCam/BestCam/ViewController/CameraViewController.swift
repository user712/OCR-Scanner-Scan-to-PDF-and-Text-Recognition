//
//  CameraViewController.swift
//  BestCam
//
//  Created by Developer on 3/3/17.
//  Copyright © . 
//

import UIKit

class CameraViewController: UIViewController {
    
    // MARK: - Properties
    
    fileprivate var camera: Camera!
    
    
    
    // MAKR: - Initializers
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // MARK: - LyfeCicle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        camera = Camera(superview: self.view, applyFilterCallback: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        camera.startFiltering()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        camera.stopFiltering()
    }
}
