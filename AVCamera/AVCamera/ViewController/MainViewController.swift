//
//  MainViewController.swift
//  AVCamera
//
//  Created  on 3/7/17.
//  Copyright © 2017 A. 
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
        if let cameraController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "AVCameraViewController") as? AVCameraViewController {
            self.present(cameraController, animated: true, completion: nil)
        }
    }
    
    @IBAction func standardCameraTapped() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
}


// MARK: - UIImagePickerControllerDelegate

extension MainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.dismiss(animated: true, completion: nil)
        
        if  let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let cropController = CustomCropViewController()
            cropController.image = image
            
            self.present(cropController, animated: true, completion: nil)
        }
    }
}
