//
//  MainViewController.swift
//  ZCamera
//
//  Created by Developer on 3/10/17.
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


// MARK: - @IBAction's

extension MainViewController {
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        if let cameraController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "CameraViewController") as? CameraViewController {
            self.present(cameraController, animated: true, completion: nil)
        }
    }
}
