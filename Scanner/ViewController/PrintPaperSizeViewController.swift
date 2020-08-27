//
//  PrintPaperSizeViewController.swift
//  Scanner
//
//   on 2/3/17.
//   
//

import UIKit

class PrintPaperSizeViewController: UIViewController, UserDefaultable {

    // MARK: - Properties
    
    fileprivate var originalImages = [UIImage]()
    fileprivate var croppedImages = [UIImage]()
    fileprivate var checkedURLPaths = Set<File>()
    fileprivate var selectedPaperSize = [ResizeImageType]()
    
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0.0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.paleGrey
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        
        collectionView.register(ProcessCollectionViewCell.self, forCellWithReuseIdentifier: ProcessCollectionViewCell.reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        return collectionView
    }()
    
    fileprivate var cellIndexPath: IndexPath? {
        for cell in self.collectionView.visibleCells {
            if let previewCell = cell as? ProcessCollectionViewCell {
                let indexPath = self.collectionView.indexPath(for: previewCell)
                
                return indexPath
            }
        }
        
        return nil
    }
    
    fileprivate lazy var cancelButton: UIBarButtonItem = {
        return UIBarButtonItem(image: UIImage(named: "shape"), style: .done, target: self, action: #selector(cancelTapped(_:)))
    }()
    
    fileprivate lazy var printButton: UIBarButtonItem = {
        return UIBarButtonItem(image: UIImage(named: "printImage"), style: .done, target: self, action: #selector(printTapped(_:)))
    }()
    
    fileprivate lazy var sizeButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "A3 (1122px x 1587px)", style: .done, target: self, action: #selector(sizeTapped(_:)))
        button.title?.addTextSpacing(-0.7)
        button.tintColor = UIColor.darkSkyBlue
        button.setTitleTextAttributes([NSFontAttributeName : UIFont.textStyleFontLight(22)], for: .normal)
        
        return button
    }()
    
    fileprivate lazy var toolBar: UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.barTintColor = UIColor.paleGrey
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil);
        toolBar.setItems([flexibleSpace, self.sizeButton, flexibleSpace], animated: true)
        
        return toolBar
    }()
    
    
    
    // MARK: - Initializers
    
    init(checkedPaths: Set<File>) {
        self.checkedURLPaths = checkedPaths
        super.init(nibName: nil, bundle: nil)
        
        for file in checkedPaths {
            if file.filePath.isPDF {
                let images = file.filePath.getImagesFromPDFAtPath(file.filePath)
                
                for image in images {
                    if let imageData = image.toFullData {
                        if let index = self.userDefaultsGetValue(userDefaultsPaperSizeKey) as? Int {
                            if let originalSizeUserDefaultsSize = ResizeImageType(rawValue: index) {
                                if let croppedImage = self.resizeData(imageData, withSize: originalSizeUserDefaultsSize.size) {
                                    self.originalImages.append(croppedImage)
                                    self.croppedImages.append(croppedImage)
                                    
                                    self.selectedPaperSize.append(originalSizeUserDefaultsSize)
                                }
                            }
                        } else {
                            if let croppedImage = self.resizeData(imageData, withSize: ResizeImageType.a3.size) {
                                self.originalImages.append(croppedImage)
                                self.croppedImages.append(croppedImage)
                                
                                let originalSize = ResizeImageType.a3
                                self.selectedPaperSize.append(originalSize)
                            }
                        }
                    }
                }
                
            } else {
                if let imageData = file.filePath.toData {
                    if let index = self.userDefaultsGetValue(userDefaultsPaperSizeKey) as? Int {
                        if let originalSizeUserDefaultsSize = ResizeImageType(rawValue: index) {
                            if let croppedImage = self.resizeData(imageData, withSize: originalSizeUserDefaultsSize.size) {
                                self.originalImages.append(croppedImage)
                                self.croppedImages.append(croppedImage)
                                
                                self.selectedPaperSize.append(originalSizeUserDefaultsSize)
                            }
                        }
                    } else {
                        if let croppedImage = self.resizeData(imageData, withSize: ResizeImageType.a3.size) {
                            self.originalImages.append(croppedImage)
                            self.croppedImages.append(croppedImage)
                            
                            let originalSize = ResizeImageType.a3
                            self.selectedPaperSize.append(originalSize)
                        }
                    }
                }
            }
        }
        
        setupUI()
        
        if let index = self.userDefaultsGetValue(userDefaultsPaperSizeKey) as? Int {
            self.sizeButton.title = paperSizesPixels[index]
        } else {
            self.sizeButton.title = paperSizesPixels[3]
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    
    // MARK: - LyfeCicle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Deinitializers
    
    deinit {
        originalImages.removeAll()
        croppedImages.removeAll()
        checkedURLPaths.removeAll()
        selectedPaperSize.removeAll()
    }
}


extension PrintPaperSizeViewController {
    
    fileprivate func setupUI() {
        self.view.backgroundColor = UIColor.paleGrey
        
        self.navigationItem.title = "Select Print Size".localized()
        self.setCustomColoredNavigationBarTitle()
        
        self.navigationItem.setLeftBarButton(cancelButton, animated: true)
        self.navigationItem.setRightBarButton(printButton, animated: true)
        
        view.addSubview(collectionView)
        view.addSubview(toolBar)
        
        self.view.addConstraintsWithFormat("H:|[v0]|", views: collectionView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: toolBar)
        
        self.view.addConstraintsWithFormat("V:|[v0][v1]|", views: collectionView, toolBar)
    }
}



// MARK: - UICollectionViewDataSource

extension PrintPaperSizeViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return croppedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProcessCollectionViewCell.reuseIdentifier, for: indexPath) as! ProcessCollectionViewCell
        let image = croppedImages[indexPath.row]
        cell.imageView.image = image
        
        return cell
    }
}


// MARK: - UICollectionViewDelegate

extension PrintPaperSizeViewController: UICollectionViewDelegate { }


// MARK: - UICollectionViewDelegateFlowLayout

extension PrintPaperSizeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height-64)
    }
}



// MARK: - Action's

extension PrintPaperSizeViewController {
    
    @objc fileprivate func cancelTapped(_ button: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func printTapped(_ button: UIBarButtonItem) {
        let printController = UIPrintInteractionController.shared
        printController.delegate = self
        
        for image in croppedImages {
            if let imageData = image.toFullData {
                if UIPrintInteractionController.canPrint(imageData) {
                    let printInfo = UIPrintInfo(dictionary: nil)
                    printInfo.outputType = .photo
                    printController.printInfo = printInfo
                    printController.showsNumberOfCopies = true
                }
            }
        }
        
        printController.printingItems = croppedImages
        printController.present(from: view.frame, in: self.view, animated: true, completionHandler: nil)
    }
    
    @objc fileprivate func sizeTapped(_ button: UIBarButtonItem) {
        let legal = "Legal".localized()
        let letter = "Letter".localized()
        let bc = "Business Card".localized()
        
        let actionSheet = UIActionSheet(title: "Select Print Size".localized(),
                                        delegate: self,
                                        cancelButtonTitle: "Cancel".localized(),
                                        destructiveButtonTitle: nil,
                                        otherButtonTitles: "\(letter) (816px x 1056px)",
                                        "A4 (793px x 1122px)",
                                        "\(legal) (816px x 1344px)",
                                        "A3 (1122px x 1587px)",
                                        "A5 (559px x 793px)",
                                        "\(bc) (336px x 192px)")
        
        actionSheet.tag = Constants.SizesActionSheetTag
        actionSheet.show(in: self.collectionView)
    }
}


// MARK: - UIPrintInteractionControllerDelegate

extension PrintPaperSizeViewController: UIPrintInteractionControllerDelegate {
 
    func printInteractionControllerParentViewController(_ printInteractionController: UIPrintInteractionController) -> UIViewController? {
        return self.navigationController
    }
}


// MARK: - UIActionSheetDelegate

extension PrintPaperSizeViewController: UIActionSheetDelegate {
    
    internal func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if !originalImages.isEmpty {
            switch actionSheet.tag {
            case Constants.SizesActionSheetTag:
                self.sizeActionSheet(actionSheet, clickedButtonAt: buttonIndex)
            default:
                break
            }
        }
    }
    
    // MARK: - Sizes
    
    fileprivate func sizeActionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        switch buttonIndex {
        case 1:
            self.resizeImage(.letter)
        case 2:
            self.resizeImage(.a4)
        case 3:
            self.resizeImage(.legal)
        case 4:
            self.resizeImage(.a3)
        case 5:
            self.resizeImage(.a5)
        case 6:
            self.resizeImage(.businessCard)
        default:
            break
        }
    }
}


// MARK: - Imageable

extension PrintPaperSizeViewController: Imageable, PaperSizeable {
    
    fileprivate func resizeImage(_ type: ResizeImageType) {
        if let indexPath = self.cellIndexPath {
            if let cell = collectionView.cellForItem(at: indexPath) as? ProcessCollectionViewCell {
                if let imageData = originalImages[indexPath.row].toFullData {
                    
                    switch type {
                    case .letter:
                        self.setSize(indexPath, imageData: imageData, cell: cell, type: type, index: 0)
                    case .a4:
                        self.setSize(indexPath, imageData: imageData, cell: cell, type: type, index: 1)
                    case .legal:
                        self.setSize(indexPath, imageData: imageData, cell: cell, type: type, index: 2)
                    case .a3:
                        self.setSize(indexPath, imageData: imageData, cell: cell, type: type, index: 3)
                    case .a5:
                        self.setSize(indexPath, imageData: imageData, cell: cell, type: type, index: 4)
                    case .businessCard:
                        self.setSize(indexPath, imageData: imageData, cell: cell, type: type, index: 5)
                    }
                }
            }
        }
        
        collectionView.reloadData()
    }
    
    fileprivate func setSize(_ indexPath: IndexPath, imageData: Data, cell: ProcessCollectionViewCell, type: ResizeImageType, index: Int) {
        if let croppedImage = self.resizeData(imageData, withSize: type.size) {
            cell.imageView.image = croppedImage
            
            self.croppedImages.remove(at: indexPath.row)
            self.croppedImages.insert(croppedImage, at: indexPath.row)
            
            self.selectedPaperSize.remove(at: indexPath.row)
            self.selectedPaperSize.insert(type, at: indexPath.row)
            
            self.sizeButton.title = paperSizesPixels[index]
        }
    }
}


// MARK: - UIScrollView

extension PrintPaperSizeViewController {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let currentPage = Int(targetContentOffset.pointee.x / view.frame.width)
        print(currentPage)
        
        let indexPath = IndexPath(row: currentPage, section: 0)
        print(indexPath)
        
        let legal = "Legal".localized()
        let letter = "Letter".localized()
        let bc = "Business Card".localized()
        
        switch selectedPaperSize[indexPath.row] {
        case .a3:
            self.sizeButton.title = "A3 (1122px x 1587px)"
        case .a4:
            self.sizeButton.title = "A4 (793px x 1122px)"
        case .a5:
            self.sizeButton.title = "A5 (559px x 793px)"
        case .letter:
            self.sizeButton.title = "\(letter) (816px x 1056px)"
        case .legal:
            self.sizeButton.title = "\(legal) (816px x 1344px)"
        case .businessCard:
            self.sizeButton.title = "\(bc) (336px x 192px)"
        }
    }
}
