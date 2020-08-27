//
//  MainViewController.swift
//  BestCam
//
//  Created by Developer on 3/3/17.
//  Copyright © . 
//

import UIKit

class MainViewController: UIViewController {

    // MARK: - Properties
    
    
    
    // MARK: - LyfeCicle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


extension MainViewController {
    
    @IBAction func cameraTapped() {
        let cameraController = Camera2ViewController()
        self.present(cameraController, animated: true, completion: nil)
    }
}
