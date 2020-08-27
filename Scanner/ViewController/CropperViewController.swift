//
//  CropperViewController.swift
//  Scanner
//
//   on 2/7/17.
//   
//

import UIKit


protocol CropperViewControllerDelegate: class{
    func doneButtonPressed()
}

class CropperViewController: UIViewController, Fileable, CroppableImageViewDelegateProtocol {
 
    // MARK: - Properties
    
    weak var cropperDelegate: CropperViewControllerDelegate?
    
    internal var initialPath: URL?
    @IBOutlet weak var cropableViewHeight: NSLayoutConstraint!
    
    @IBOutlet var controlButtons: [UIButton]! {
        didSet{
            for button in controlButtons {
                button.backgroundColor = .clear
                button.layer.cornerRadius = button.frame.width/2
                button.layer.borderWidth = 2
                button.layer.borderColor = UIColor.rgb(red: 0, green: 122, blue: 255, alpha: 1).cgColor
            }
        }
    }
    
    
    @IBOutlet weak var segmentedControlOutlet: UISegmentedControl!{
        didSet{
            for idx in 0..<segmentedControlOutlet.numberOfSegments {
                segmentedControlOutlet.setTitle(segmentedControlOutlet.titleForSegment(at: idx)?.localized(), forSegmentAt: idx)
            }
        }
    }
    
    @IBOutlet weak var cropableView: CroppableImageView! {
        didSet{
            cropableView.cropDelegate = self
        }
    }
    
    var originalImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print(cropableView)
//        cropableView?.layoutIfNeeded()
//        print(cropableView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cropableView?.imageToCrop = originalImage
        print(cropableView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        dismissCurrentController()
    }
    
    @IBAction func doneButtonAction(_ sender: Any) {
        if let urlPath = self.userDefaultsGetValue("mainController.initialPath") as? String {
            let fileName = "\(self.dateForSaveImage()).jpg"
            let initialURL = URL(fileURLWithPath: urlPath)
            let fileURL = initialURL.appendingPathComponent(fileName)
            
            if !isOriginalImagesFolderExist(initialURL) && !isThumbnailFolderExist(initialURL) {
                self.create(folderAtPath: initialURL, withName: Constants.HiddenFolderName)
                self.create(folderAtPath: initialURL, withName: Constants.OriginalImageFolderName)
            }
            
            let originalImageURL = initialURL.appendingPathComponent(Constants.OriginalImageFolderName).appendingPathComponent(fileName)
            if let croppedImageData = cropableView.croppedImage()?.toFullData {
                try? croppedImageData.write(to: fileURL)
                try? croppedImageData.write(to: originalImageURL)
                dismissCurrentController()
                cropperDelegate?.doneButtonPressed()
            }
        }
    }
    
    @IBAction func segmentedControlAction(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            cropableView?.centerArea()
        }else{
            cropableView?.selectAllArea()
        }
    }
    
    private func dismissCurrentController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - croper delegates
    
    func haveValidCropRect(_: Bool) {
        
    }
    
    func imageSizeSetted(size: CGSize?) {
        if let size = size {
            let scale = size.width / (originalImage?.size.width)!
            let height = (originalImage?.size.height)! * scale
            
            cropableViewHeight.constant = height
        }
    }
    
    func cornerHasChanged() {
        if segmentedControlOutlet.selectedSegmentIndex == 1 {
            segmentedControlOutlet.selectedSegmentIndex = 0
        }
    }
}
