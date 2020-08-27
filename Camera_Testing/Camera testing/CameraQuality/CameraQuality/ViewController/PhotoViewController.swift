//
//  PhotoViewController.swift
//  CameraQuality
//
//  Created  on 2/28/17.
//  Copyright © 2017 
//

import UIKit
import TesseractOCR

class PhotoViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    fileprivate var tesseract: G8Tesseract?
    fileprivate var isOCRRecognizionRunning = false
    fileprivate var textFromImage = String()
    
    var takenPhoto: UIImage?
    
    
    
    // MARK: - LyfeCicle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let availableImage = takenPhoto {
            imageView.image = availableImage
        }
        
        tesseract = G8Tesseract(language: "eng")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


extension PhotoViewController {
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func textImageSegmentTapped(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            UIView.animate(withDuration: 0.25) { [unowned self] in
                self.textView.alpha = 0.0
                self.imageView.alpha = 1.0
            }
        case 1:
            
            if !isOCRRecognizionRunning {
                if let imageForRecognize = takenPhoto {
                    self.isOCRRecognizionRunning = true
                    
                    DispatchQueue.global(qos: .background).async { [unowned self] in
                        if let recognizedText = self.recognizeFromImage(imageForRecognize) {
                            if self.textFromImage.isEmpty {
                                self.textFromImage = recognizedText
                            }
                        }
                        
                        DispatchQueue.main.async { [unowned self] in
                            UIView.animate(withDuration: 0.25) { [unowned self] in
                                self.textView.alpha = 1.0
                                self.imageView.alpha = 0.0
                                self.textView.text = self.textFromImage
                            }
                            
                        }
                    }
                }
            }
            
        default:
            break
        }
    }
}


extension PhotoViewController {
    
    func recognizeFromImage(_ image: UIImage) -> String? {
        if let tesseract = tesseract {
            tesseract.pageSegmentationMode = .auto
            tesseract.engineMode = .tesseractOnly
            tesseract.delegate = self
            tesseract.image = image ///.image_grayScale()
            tesseract.recognize()
            print(tesseract.absoluteDataPath)
            
            return tesseract.recognizedText
        }
        
        return nil
    }
}

extension PhotoViewController: G8TesseractDelegate {
    
    func progressImageRecognition(for tesseract: G8Tesseract!) {
        print(tesseract.progress)
        
        DispatchQueue.main.async { [unowned self] in
            self.navigationItem.title = "Progress \(tesseract.progress) %"
        }
    }
    
    func shouldCancelImageRecognition(for tesseract: G8Tesseract!) -> Bool {
        return false
    }
}
