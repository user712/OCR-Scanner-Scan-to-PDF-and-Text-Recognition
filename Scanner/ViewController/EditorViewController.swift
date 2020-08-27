//
//  EditorViewController.swift
//  Scanner
//
//   on 2/6/17.
//   
//

import UIKit

protocol EditorViewControllerDelegate: class {
    func didEndEditingImage(_ image: UIImage)
}

class EditorViewController: UIViewController {

    // MARK: - Properties
    
    var filePath: URL!
    var initialPath: URL?
    
    var currentFile: File? {
        didSet{
            if let fileData = DatabaseManager.getFile(file: currentFile!) {
                if let imageForFilter = originalImage {
                    filterType = ImageFilterType(rawValue: Int(fileData.colorType))!
                    if let image = imageProcessingFilter?.imageFilter(imageForFilter, type: filterType) {
                        let rotatedImage = image.rotatedImageWithDegree(CGFloat(fileData.rotateAngle))
                        rotateAngle = fileData.rotateAngle
                        self.imageView.image = rotatedImage
                        self.filterType = .colorful
                        
                        setValue()
                    }
                }
            }
        }
    }
    
    var rotateAngle: Int16 = 0
    
    weak var editorDelegate: EditorViewControllerDelegate?
    weak var processDelegate: Processable?
    
    fileprivate var filterType: ImageFilterType = .colorful
    
    fileprivate var originalImage: UIImage!
    
    fileprivate var contrastCurrentValue: Float = 1.00
    fileprivate var brightnessCurrentValue: Float = 0.50
    
    fileprivate var colorControlsFilter : CIFilter!
    fileprivate var ciImageContext: CIContext!
    
    fileprivate var imageProcessingFilter: ImageFilterManager?
    fileprivate var alertController: AlertManagerController!
    
    fileprivate lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    fileprivate lazy var cameraHeaderView: UIView = {
        let headerView = UIView()
        headerView.backgroundColor = .white
        
        return headerView
    }()
    
    fileprivate lazy var navigationView: UIView = {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.white
        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0, y: 63, width: 1000, height: 1)
        topBorder.backgroundColor = UIColor.rgb(red: 229, green: 231, blue: 235, alpha: 1).cgColor
        headerView.layer.addSublayer(topBorder)
        
        return headerView
    }()
    
    fileprivate lazy var doneButton: UIBarButtonItem =  {
        return UIBarButtonItem(image: UIImage(named: "select"), style: .plain, target: self, action: #selector(doneTapped(_:)))
    }()
    
    fileprivate lazy var cancelButton: UIBarButtonItem =  {
        return UIBarButtonItem(image: UIImage(named: "shape"), style: .plain, target: self, action: #selector(cancelTapped(_:)))
    }()

    fileprivate lazy var rotateButton: UIBarButtonItem =  {
        return UIBarButtonItem(image: UIImage(named: "transform90"), style: .plain, target: self, action: #selector(rotateTapped(_:)))
    }()
    
    fileprivate lazy var filterButton: UIBarButtonItem =  {
        return UIBarButtonItem(image: UIImage(named: "filter"), style: .plain, target: self, action: #selector(filterTapped(_:)))
    }()
    
    fileprivate lazy var cropButton: UIBarButtonItem =  {
        let button = UIBarButtonItem(image: UIImage(named: "crop"), style: .plain, target: self, action: #selector(filterTapped(_:)))
        button.tintColor = UIColor.darkSkyBlue /// TODO: - Add crop method
        
        return button
    }()
    
    fileprivate lazy var toolBar: UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.backgroundColor = .white
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil);
        toolBar.setItems([self.cancelButton, flexibleSpace, self.rotateButton, flexibleSpace, self.filterButton, flexibleSpace, self.doneButton], animated: true)
        
        return toolBar
    }()
    
    fileprivate lazy var contrastSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = -1.00
//        slider.maximumValue = 1.00
        slider.maximumValue = 3.00
        
        if let currentFile = self.currentFile {
            if let contrast = DatabaseManager.getFile(file: currentFile)?.contrast {
                slider.value = contrast
            }else{
                slider.value = 1
            }
        }else{
            slider.value = 1
        }
            
//        slider.value = self.colorControlsFilter.value(forKey: kCIInputContrastKey) as? Float ?? self.contrastCurrentValue
        slider.tintColor = UIColor.darkSkyBlue
        slider.addTarget(self, action: #selector(contrastValueDidChange(_:)), for: .valueChanged)
        slider.setThumbImage(UIImage(named: "contrast"), for: .normal)
        
        self.contrastValueDidChange(slider)
        
        return slider
    }()
    
    fileprivate lazy var brightnessSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = -1.00
//        slider.minimumValue = 0.00
        slider.maximumValue = 1.00
        
        if let currentFile = self.currentFile {
            if let brightness = DatabaseManager.getFile(file: currentFile)?.brightness {
                slider.value = brightness
            }else{
                slider.value = 0
            }
        }else{
            slider.value = 0
        }
        
//        slider.value = self.colorControlsFilter.value(forKey: kCIInputBrightnessKey) as? Float ?? self.brightnessCurrentValue
        slider.tintColor = UIColor.darkSkyBlue
        slider.addTarget(self, action: #selector(brightnessValueDidChange(_:)), for: .valueChanged)
        slider.setThumbImage(UIImage(named: "brightness"), for: .normal)
        
        self.brightnessValueDidChange(slider)
        
        return slider
    }()
    
    
    // MARK: - Initializers
    
    init(originalImage: UIImage, initialPath: URL!) {
        self.originalImage = originalImage
        self.initialPath = initialPath
        
        ciImageContext = CIContext(options: nil)
        colorControlsFilter = CIFilter(name: "CIColorControls")!
        imageProcessingFilter = ImageFilterManager()
        
        super.init(nibName: nil, bundle: nil)
//        setupUI()
        
        imageView.image = originalImage
        self.alertController = AlertManagerController()
        self.setValue()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    
    // MARK: - LyfeCicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Deinitializers
    
    deinit {
        filePath = nil
        initialPath = nil
        
        editorDelegate = nil
        processDelegate = nil
        
        originalImage = nil
        
        colorControlsFilter = nil
        ciImageContext = nil
        
        imageProcessingFilter = nil
        alertController = nil
    }
}


extension EditorViewController {
    
    fileprivate func setupUI() {
        self.view.backgroundColor = .white
        
        view.addSubview(navigationView)
        view.addSubview(imageView)
        view.addSubview(toolBar)
        
        view.addConstraintsWithFormat("H:|[v0]|", views: navigationView)
        view.addConstraintsWithFormat("H:|[v0]|", views: imageView)
        view.addConstraintsWithFormat("H:|[v0]|", views: toolBar)
        
        view.addConstraintsWithFormat("V:|[v0(64)][v1][v2(44)]|", views: navigationView, imageView, toolBar)
        
        setupNavigationBarUI()
    }
    
    fileprivate func setupNavigationBarUI() {
        
        navigationView.addSubview(contrastSlider)
        navigationView.addSubview(brightnessSlider)
        navigationView.addConstraintsWithFormat("H:|-14-[v0(v1)]-28-[v1]-14-|", views: contrastSlider, brightnessSlider)
        
        navigationView.addConstraintsWithFormat("V:[v0(30)]-8-|", views: contrastSlider)
        navigationView.addConstraintsWithFormat("V:[v0(30)]-8-|", views: brightnessSlider)
    }
}





// MARK: - Action's

extension EditorViewController: Fileable, Imageable {
    
    @objc fileprivate func cancelTapped(_ button: UIBarButtonItem) {
        //        self.processDelegate?.didFinishImageTransfer()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func doneTapped(_ button: UIBarButtonItem) {
        if let initialPath = self.initialPath, let filePath = filePath {
            print(initialPath)
            
            if let imageData = imageView.image?.toFullData {
                let thumbnailImageURL = initialPath.appendingPathComponent(Constants.HiddenFolderName).appendingPathComponent(filePath.lastPathComponent)
                
                do {
                    try self.filesManager.removeItem(at: filePath)
                    try self.filesManager.removeItem(at: thumbnailImageURL)
                } catch {
                    print(error)
                }
                
                do {
                    let contentFileURL = initialPath.appendingPathComponent(filePath.lastPathComponent)
                    print(contentFileURL)
                    try imageData.write(to: contentFileURL)
                    
                    if let thumbnailImage = self.resizeData(imageData) {
                        if let thumbnailImageData = thumbnailImage.getJPEGData {
                            try? thumbnailImageData.write(to: thumbnailImageURL)
                        }
                    }
                } catch {
                    print(error)
                }
                
                
                
                self.dismiss(animated: true, completion: { [unowned self] in
                    if let image = self.imageView.image {
                        self.editorDelegate?.didEndEditingImage(image)
                        
                        if let currentFile = self.currentFile {
                            currentFile.brightness = self.brightnessSlider.value
                            currentFile.contrast = self.contrastSlider.value
                            currentFile.colorType = Int16(self.filterType.rawValue)
                            currentFile.rotateAngle = self.rotateAngle
                            
                            DatabaseManager.update(file: currentFile)
                        }
                    }
                })
            }
        }
    }
    
    @objc fileprivate func contrastValueDidChange(_ slider: UISlider) {
        colorControlsFilter.setValue(slider.value, forKey: kCIInputContrastKey)
        
        if let outputImage = self.colorControlsFilter.outputImage {
            if let cgImageNew = self.ciImageContext.createCGImage(outputImage, from: (outputImage).extent) {
                let newImg = UIImage(cgImage: cgImageNew)
                self.imageView.image = newImg
            }
        }
    }
    
    @objc fileprivate func brightnessValueDidChange(_ slider: UISlider) {
        colorControlsFilter.setValue(slider.value, forKey: kCIInputBrightnessKey)
        
        if let outputImage = self.colorControlsFilter.outputImage {
            if let cgImageNew = self.ciImageContext.createCGImage(outputImage, from: (outputImage).extent) {
                let newImg = UIImage(cgImage: cgImageNew)
                self.imageView.image = newImg
            }
        }
    }
    
    @objc fileprivate func rotateTapped(_ button: UIBarButtonItem) {
        let rotationStep: CGFloat = 90.0
        if let originalImage = originalImage, let imageAtIndexPath = imageView.image {
            if let rotatedImage = imageAtIndexPath.rotatedImageWithDegree(rotationStep),
                let rotatedOriginalImageAtIndexPath = originalImage.rotatedImageWithDegree(rotationStep) {
                self.rotateAngle += 90
                if self.rotateAngle > 270 {
                    self.rotateAngle -= 360
                }
                print(self.rotateAngle)
                
                UIView.animate(withDuration: 0.5, animations: { [unowned self] in
                    self.imageView.transform = CGAffineTransform(rotationAngle: rotationStep * .pi / 180)
                }, completion: { (success) in
                    self.imageView.transform = CGAffineTransform(rotationAngle: 0)
                    self.imageView.image = rotatedImage
                    self.originalImage = rotatedOriginalImageAtIndexPath
                    self.setValue()
                })
            }
        }
    }
    
    @objc fileprivate func filterTapped(_ button: UIBarButtonItem) {
        let actionSheet = UIActionSheet(title: "Choice Filter Color".localized(),
                                        delegate: self,
                                        cancelButtonTitle: "Cancel".localized(),
                                        destructiveButtonTitle: nil,
                                        otherButtonTitles: "Color".localized(),
                                        "Grayscale".localized(),
                                        "Black and White".localized())
        actionSheet.tag = Constants.FilterActionSheetTag
        actionSheet.show(in: self.view)
    }
}


extension EditorViewController {
    
    fileprivate func setDefaultValueOfSliders() {
        colorControlsFilter.setDefaults()
        let brightnessValue = self.colorControlsFilter.value(forKey: kCIInputBrightnessKey) as? Float
        let contrastValue = self.colorControlsFilter.value(forKey: kCIInputContrastKey) as? Float
        
        contrastSlider.value = contrastValue ?? 1.00
        contrastSlider.maximumValue = 3.00
        contrastSlider.minimumValue = -1.00
        
        brightnessSlider.value = brightnessValue ?? 0.0
        brightnessSlider.maximumValue = 1.00
        brightnessSlider.minimumValue = -1.00
    }
}


// MARK: - UIActionSheetDelegate /// Filter Image

extension EditorViewController: UIActionSheetDelegate {
    
    internal func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        switch actionSheet.tag {
        case Constants.FilterActionSheetTag:
            self.filterActionSheet(actionSheet, clickedButtonAt: buttonIndex)
        default:
            break
        }
    }
    
    fileprivate func filterActionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        func resetSliders() {
            contrastSlider.value = 1
            brightnessSlider.value = 0
        }
        
        if let imageForFilter = originalImage {
            switch buttonIndex {
            case 1: /// Color
                if let colorImage = imageProcessingFilter?.imageFilter(imageForFilter, type: .colorful) {
                    self.imageView.image = colorImage
                    self.filterType = .colorful
                    resetSliders()
                }
            case 2: /// Grayscale
                if let colorImage = imageProcessingFilter?.imageFilter(imageForFilter, type: .grayScale) {
                    self.imageView.image = colorImage
                    self.filterType = .grayScale
                    resetSliders()
                }
            case 3: /// Black and White
                if let colorImage = imageProcessingFilter?.imageFilter(imageForFilter, type: .blackAndWhite) {
                    self.imageView.image = colorImage
                    self.filterType = .blackAndWhite
                    resetSliders()
                }
                
            default:
                break
            }
            
            setValue()
        }
    }

    fileprivate func setValue() {
        if let cgimg = imageView.image?.cgImage {
            let coreImage = CIImage(cgImage: cgimg)
            self.colorControlsFilter.setValue(coreImage, forKey: kCIInputImageKey)
            colorControlsFilter.setDefaults()
        }
    }
}
