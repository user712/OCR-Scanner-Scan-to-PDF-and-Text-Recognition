//
//  PreviewViewController.swift
//  Scanner
//
//   on 1/17/17.
//   
//
import QuickLook
import Foundation
import UIKit

protocol PreviewViewControllerDelegate: class {
    func didFinishDeletingFiles()
}

class PreviewViewController: UIViewController, CloudShareable, PDFconvetible {
    
    // MARK: - Properties
    
    internal var initialPath: URL?
    var checkedURLPaths: Set<File> = []
    var currentFile: File?
    
    weak var previewDelegate: PreviewViewControllerDelegate?
    
    fileprivate var progressPDFCounter = 0
    
    fileprivate var images: [UIImage]!
    fileprivate var filePath: URL!
    fileprivate weak var actionToEnable: UIAlertAction?
    fileprivate var transition: CircularTransition!
    fileprivate var isInPDFEditMode = false
    
    fileprivate var textFromImage = String()
    fileprivate var infoLaucher: InfoMessageLauncher!
    fileprivate var ocrManager: OCRManager?
    
    fileprivate var pdfData: Data!
    fileprivate var isOCRRecognizionRunning = false
    fileprivate var isPDFSessionIntrerupted = false
    
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0.0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.paleGrey
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        
        collectionView.register(PreviewCollectionViewCell.self, forCellWithReuseIdentifier: PreviewCollectionViewCell.reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        return collectionView
    }()
    
    fileprivate lazy var blackView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.alpha = 0.0
        view.frame = CGRect(x: -500, y: -500, width: 2000, height: 2000)
        
        return view
    }()
    
    fileprivate let alertController = AlertManagerController()
    
    fileprivate var visibleCurrentCell: IndexPath? {
        for cell in self.collectionView.visibleCells {
            if let previewCell = cell as? PreviewCollectionViewCell {
                let indexPath = self.collectionView.indexPath(for: previewCell)
                
                return indexPath
            }
        }
        
        return nil
    }
    
    fileprivate lazy var switchSegmentedControl: UISegmentedControl = {
        let segment = UISegmentedControl()
        segment.insertSegment(withTitle: "Image".localized(), at: 0, animated: true)
        segment.insertSegment(withTitle: "Text".localized() + " OCR", at: 1, animated: true)
        segment.tintColor = UIColor.darkSkyBlue
        segment.selectedSegmentIndex = 0
        segment.addTarget(self, action: #selector(switchSegmentedTapped(_:)), for: .valueChanged)
        
        return segment
    }()
    
    fileprivate lazy var titleNavigationLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: self.view.frame.width / 2, height: 30))
        /// titleNavigationLabel.drawBottomDashedLine(UIColor.darkSkyBlue)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(editFileNameGestureTapped(_:)))
        tapGesture.numberOfTapsRequired = 1
        label.addGestureRecognizer(tapGesture)
        
        return label
    }()
    
    fileprivate lazy var toolBarView: UIView = {
        let toolBar = UIView()
        toolBar.backgroundColor = UIColor.white
        toolBar.addTopBorder()
        
        return toolBar
    }()
    
    fileprivate let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "btnEditDefault"), for: .normal)
        button.addTarget(self, action: #selector(editTapped(_:)), for: .touchUpInside)
        
        return button
    }()
    
    fileprivate let editPDFTextButton: UIButton = {
        let button = UIButton(type: .system)
        button.contentHorizontalAlignment = .left
//        button.setImage(UIImage(named: "btnEditDefault"), for: .normal)
        button.setTitle("Edit".localized(), for: .normal)
        button.addTarget(self, action: #selector(editPDFTextTapped(_:)), for: .touchUpInside)
        
        return button
    }()
    
    fileprivate let shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "share"), for: .normal)
        button.addTarget(self, action: #selector(shareTapped(_:)), for: .touchUpInside)
        
        return button
    }()
    
    var hreni: String?
    
    fileprivate lazy var languageButton: UIBarButtonItem = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        let languageIndex = UserDefaults.standard.object(forKey: "ocr.downloaded.languages") as? Int ?? 0
        let imageName = self.searchedFlags[languageIndex]
        button.setImage(UIImage(named: imageName), for: .normal)
        button.addTarget(self, action: #selector(languagesTapped(_:)), for: .touchUpInside)
        
        return UIBarButtonItem(customView: button)
    }()
    
    fileprivate lazy var rescanButton: UIBarButtonItem =  {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 28, height: 28)
        button.setImage(UIImage(named: "rescan"), for: .normal)
        button.setImage(UIImage(named: "pressedRescan"), for: .highlighted)
        button.addTarget(self, action: #selector(rescanTapped(_:)), for: .touchUpInside)
        
        return UIBarButtonItem(customView: button)
    }()
    
    fileprivate var filePDFController: UIViewController!
    fileprivate var previewManager: PreviewManager!
    
    
    // MARK: - Initializers
    
    init(images: [UIImage], filePath: URL) {
        self.images = images
        self.filePath = filePath
        self.initialPath = filePath.deletingLastPathComponent()
        
        super.init(nibName: nil, bundle: nil)
        
        /// Dependency Infection
        setupUI()
        
        transition = CircularTransition()
        infoLaucher = InfoMessageLauncher()
        infoLaucher.delegate = self
        previewManager = PreviewManager()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        addPDFQuikLookController()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    
    // MARK: - LyfeCicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //        saveTextFromImageToTextFile()
    }
    
    
    // MARK: - Deinitializers
    
    deinit {
        initialPath = nil
        checkedURLPaths.removeAll()
        previewDelegate = nil
        images = nil
        filePath = nil
        actionToEnable = nil
        transition = nil
        textFromImage.removeAll()
        infoLaucher = nil
        ocrManager = nil
        previewManager = nil
        filePDFController = nil
        NotificationCenter.default.removeObserver(self)
    }
}


// MARK: - Setup UI

extension PreviewViewController {
    
    fileprivate func setupUI() {
        self.navigationController?.navigationBar.barTintColor = UIColor.rgb(red: 253, green: 253, blue: 255, alpha: 1)
        titleNavigationLabel.setTitle(filePath.lastPathComponent.deletingPathExtension)
        self.navigationItem.titleView = titleNavigationLabel
        
        view.addSubview(collectionView)
        view.addSubview(toolBarView)
        
        self.view.addConstraintsWithFormat("H:|[v0]|", views: collectionView)
        self.view.addConstraintsWithFormat("H:|[v0]|", views: toolBarView)
        
        self.view.addConstraintsWithFormat("V:|[v0][v1(44)]|", views: collectionView, toolBarView)
        
        toolBarView.addSubview(switchSegmentedControl)
        switchSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        let views = ["toolBar": toolBarView, "switchSegmentedControl": switchSegmentedControl]
        
        /// Center horisontally
        let horizontalConstraint = NSLayoutConstraint.constraints(
            withVisualFormat: "V" + ":[toolBar]-(<=1)-[switchSegmentedControl]",
            options: .alignAllCenterX,
            metrics: nil,
            views: views)
        
        toolBarView.addConstraints(horizontalConstraint)
        
        /// Center vertically
        let verticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H" + ":[toolBar]-(<=1)-[switchSegmentedControl]",
            options: .alignAllCenterY,
            metrics: nil,
            views: views)
        
        toolBarView.addConstraints(verticalConstraints)
        
        if filePath.isImage {
            toolBarView.addSubview(editButton)
            toolBarView.addConstraintsWithFormat("H:|-18-[v0(40)]", views: editButton)
            toolBarView.addConstraintsWithFormat("V:|-2-[v0]-2-|", views: editButton)
        }
        
        self.toolBarView.addSubview(shareButton)
        self.toolBarView.addSubview(editPDFTextButton)
        
//        toolBarView.addConstraintsWithFormat("H:[v0(40)]-6-[v1(40)]-18-|", views: editPDFTextButton, shareButton)
        
        toolBarView.addConstraintsWithFormat("H:[v0(40)]-8-|", views: shareButton)
        toolBarView.addConstraintsWithFormat("V:|-2-[v0]-2-|", views: shareButton)
        
        toolBarView.addConstraintsWithFormat("V:|-2-[v0]-2-|", views: editPDFTextButton)
        
        toolBarView.layoutIfNeeded()
        let width = switchSegmentedControl.frame.origin.x - 10
        toolBarView.addConstraintsWithFormat("H:|-8-[v0(\(String(describing: width)))]", views: editPDFTextButton)
        
        editPDFTextButton.alpha = 0.0
        
        self.navigationItem.titleView?.addSubview(blackView)
        blackView.alpha = 0.0
        
        self.getJPEGFile()
    }
}


// MARK: - UICollectionViewDataSource

extension PreviewViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PreviewCollectionViewCell.reuseIdentifier, for: indexPath) as! PreviewCollectionViewCell
        let image = images[indexPath.row]
        cell.image = image
        
        return cell
    }
}


// MARK: - UICollectionViewDelegate

extension PreviewViewController: UICollectionViewDelegate { }


// MARK: - UICollectionViewDelegateFlowLayout

extension PreviewViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height-64)
    }
}


// MARK: - Action's

extension PreviewViewController: OCRDatable {
    
    @objc fileprivate func deleteTapped(_ button: UIBarButtonItem) {
        deleteImage { (succes) in
            if succes {
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc fileprivate func switchSegmentedTapped(_ sender: UISegmentedControl) {
        self.segmentedControlSelectedIndex(sender.selectedSegmentIndex)
    }
    
    fileprivate func segmentedControlSelectedIndex(_ index: Int) {
        var ocrLanguage: String
        
        if let index = self.userDefaultsGetValue(userDefaultsOCRIndexPath) as? Int {
            let tesseractLanguage = ocrLanguages[index]
            ocrLanguage = tesseractLanguage
        } else {
            ocrLanguage = "eng"
        }
        
        if let indexPath = visibleCurrentCell {
            if let cell = collectionView.cellForItem(at: indexPath) as? PreviewCollectionViewCell {
                let initialURL = self.filePath.deletingLastPathComponent()
                let pdfURL = initialURL.appendingPathComponent(Constants.OriginalImageFolderName).appendingPathComponent(self.filePath.lastPathComponent)
                
                switch index {
                case 0:
                    print("image")
                    self.collectionView.isScrollEnabled = true
                    self.navigationItem.rightBarButtonItems?.removeAll()
                    
                    UIView.animate(withDuration: 0.25) { [unowned self] in
                        self.filePDFController.view.alpha = 0.0
                        cell.imageView.alpha = 1.0
                        cell.textView.alpha = 0.0
                        self.editPDFTextButton.alpha = 0.0
                    }
                    
                    /// Close edit pdf mode
                    self.isInPDFEditMode = false
                    self.editPDFTextButton.setTitle("Edit".localized(), for: .normal)
                    
                case 1:
                    print("text OCR")
                    self.collectionView.isScrollEnabled = false
                    self.navigationItem.setRightBarButtonItems([languageButton, rescanButton], animated: true)
                    print("ocrLanguage = \(ocrLanguage)")
                    
                    if filePath.isPDF {
                        
                        // TODO: - Start pdf OCR
                        
                        let ocrSessionWasAborted = self.userDefaultsBoolForKey(self.filePath.lastPathComponent)
                       
                        if ocrSessionWasAborted {
                            print("session was aborted")
                            self.createContinueRecognitionAction(pdfURL, ocrLanguage: ocrLanguage)
                        } else {
                            print("session not was aborted")
                            startOCRPDFSession(pdfURL, ocrLanguage: ocrLanguage)
                        }
                    } else {
                        let fileTextURL = TextURL(fileURL: filePath)
                        
                        if let textFromTxtFile = self.getContentFromTextDocumentURL(fileTextURL, indexPath: indexPath) {
                            cell.textView.isHidden = false
                            cell.textView.text = textFromTxtFile
                        } else {
                            self.infoLaucher.showAction(onController: self)
                            self.recognizeImageFromCell(cell, language: ocrLanguage)
                        }
                        
                        UIView.animate(withDuration: 0.25) {
                            cell.imageView.alpha = 0.0
                            cell.textView.alpha = 1.0
                        }
                    }
                default:
                    break
                }
            }
        }
    }
    
    @objc fileprivate func editTapped(_ button: UIButton) {
        let initialPath = filePath.path.deletingLastPathComponent
        let initialPathURL = URL(fileURLWithPath: initialPath)
        
//        print(initialPathURL.appendingPathComponent(Constants.OriginalImageFolderName))
        
        if let image = initialPathURL.appendingPathComponent(Constants.OriginalImageFolderName).appendingPathComponent(filePath.lastPathComponent).toUIImage {
            let editorController = EditorViewController(originalImage: image, initialPath: initialPathURL)
            editorController.currentFile = currentFile
            editorController.filePath = self.filePath
            editorController.transitioningDelegate = self
            editorController.modalPresentationStyle = .custom
            editorController.editorDelegate = self
            self.present(editorController, animated: true, completion: nil)
        }
    }
    
    @objc fileprivate func editPDFTextTapped(_ button: UIButton) {
        if let indexPath = visibleCurrentCell {
            if let cell = collectionView.cellForItem(at: indexPath) as? PreviewCollectionViewCell {
                
                if isInPDFEditMode {
                    isInPDFEditMode = false
//                    button.setImage(UIImage(named: "btnEditDefault"), for: .normal)
                    
                    /// Modified pdf
                    if let editedText = cell.textView.text {
                        let wrapper = PDFCreatorManager()
                        let documentPDFName = self.filePath.lastPathComponent.deletingPathExtension + ".pdf"
                        let documentTextName = self.filePath.lastPathComponent.deletingPathExtension
                        let initialURL = self.filePath.deletingLastPathComponent()
                        let pdfURL = initialURL.appendingPathComponent(Constants.OriginalImageFolderName).appendingPathComponent(documentPDFName)
                        
                        let fileTextURL = TextURL(fileURL: filePath)
                        try? self.filesManager.removeItem(at: pdfURL) /// clear
                        wrapper.createPDF(withName: documentPDFName, withText: [NSAttributedString(string: editedText)], withWritePath: pdfURL.path)
                        
                        let newFileText = FileText(documentName: documentTextName, content: editedText, fileTextURL: fileTextURL)
                        self.createTextDocument(self, fileTextContent: newFileText)
                        self.previewManager.quickLookPreviewController.reloadData()
                    }
                    
                    
                    UIView.animate(withDuration: 0.25) { [unowned self] in
                        button.setTitle("Edit".localized(), for: .normal)
                        
                        self.filePDFController.view.alpha = 1.0
                        cell.textView.alpha = 0.0
                        cell.textView.isHidden = true
                    }
                    
                } else {
                    isInPDFEditMode = true
//                    button.setImage(UIImage(named: "btnEditSelected"), for: .normal)
                    
                    UIView.animate(withDuration: 0.25) { [unowned self] in
                        button.setTitle("Save".localized(), for: .normal)
                        
                        self.filePDFController.view.alpha = 0.0
                        cell.textView.alpha = 1.0
                        cell.textView.isHidden = false
                        
                        
                        let fileTextURL = TextURL(fileURL: self.filePath)
                        if let textFromTxtFile = self.getContentFromTextDocumentURL(fileTextURL, indexPath: indexPath) {
                            cell.textView.text = textFromTxtFile
                            
                            ToastManager.main.makeToast(cell.textView, message: "Text copied to clipboard".localized(), duration: 1.5, position: .center)
                            UIPasteboard.general.string = textFromTxtFile
                        }
                    }
                }
            }
        }
    }
    
    @objc fileprivate func editFileNameGestureTapped(_ gesture: UITapGestureRecognizer) {
        let initialPathURL = URL(fileURLWithPath: filePath.path.deletingLastPathComponent)
        print("initialPathURL = \(initialPathURL)")
        
        let alertController = UIAlertController(title: self.filePath.lastPathComponent.deletingPathExtension, message: "", preferredStyle: .alert)
        
        alertController.addTextField(configurationHandler: { [unowned self] (textField: UITextField!) in
            textField.clearButtonMode = .whileEditing
            textField.placeholder = self.filePath.deletingPathExtension().lastPathComponent
            textField.addTarget(self, action: #selector(self.nameFileChanged(_:)), for: .editingChanged)
        })
        
        let cancelButtonAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
        let createButtonAction = UIAlertAction(title: "Save".localized(), style: .default) { [unowned self] (alertAction) in
            if let textfield = alertController.textFields?.first {
                if let fileName = textfield.text {
                    self.titleNavigationLabel.setTitle(fileName)
                    
                    let newFilePath = self.filePath.deletingLastPathComponent().appendingPathComponent((Constants.OriginalImageFolderName))
                    
                    if let data = self.filePath.toData {
                        if self.filePath.isImage {
                            let renamedFileURL = initialPathURL.appendingPathComponent(fileName + ".jpg")
                            self.reloadContentImage(data, initialPathURL: initialPathURL, filePath: self.filePath, fileName: fileName)
                            
                            let contentText = self.filePath.deletingLastPathComponent().appendingPathComponent((Constants.OriginalImageFolderName)).appendingPathComponent(self.filePath.lastPathComponent)
                            self.createTextDocumentAtPath(newFilePath, documentName: fileName, content: self.getTextDocumentAtPath(contentText))
                            
                            self.filePath = renamedFileURL
                        } else if self.filePath.isPDF {
                            
                            /// Move scanned text files
                            let initPathURL = self.filePath.deletingLastPathComponent().appendingPathComponent(Constants.OriginalImageFolderName)
                            let basePDFFolderURL = initPathURL.appendingPathComponent(self.filePath.lastPathComponent.deletingPathExtension)
                            print("basePDFFolderURL = \(basePDFFolderURL)")
                            
                            let pdfFolderToMoveURL = initPathURL.appendingPathComponent(fileName)
                            print("pdfFolderToMoveURL = \(pdfFolderToMoveURL)")
                            try? self.filesManager.moveItem(at: basePDFFolderURL, to: pdfFolderToMoveURL)
                            
                            
                            let renamedFileURL = initialPathURL.appendingPathComponent(fileName + ".pdf")
                            try? data.write(to: renamedFileURL)
                            initialPathURL.remove(fileAtPath: self.filePath)
                            self.filePath = renamedFileURL
                        }
                        
                        self.previewDelegate?.didFinishDeletingFiles()
                    }
                }
            }
        }
        
        alertController.addAction(cancelButtonAction)
        alertController.addAction(createButtonAction)
        
        createButtonAction.isEnabled = false
        self.actionToEnable = createButtonAction
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc fileprivate func nameFileChanged(_ textField: UITextField) {
        let initialPathURL = URL(fileURLWithPath: filePath.path.deletingLastPathComponent)
        if let fileName = textField.text {
            if self.filePath.isImage {
                let renamedFileURL = initialPathURL.appendingPathComponent(fileName + ".jpg")
                self.actionToEnable?.isEnabled = (fileName.characters.count >= 1) && !renamedFileURL.fileExist
                
            } else if self.filePath.isPDF {
                let renamedFileURL = initialPathURL.appendingPathComponent(fileName + ".pdf")
                self.actionToEnable?.isEnabled = (fileName.characters.count >= 1) && !renamedFileURL.fileExist
            }
        }
    }
    
    @objc fileprivate func languagesTapped(_ button: UIButton) {
        let ocrLanguages = OCRLangsViewController()
        ocrLanguages.delegate = self
        let ocrNavigationController = UINavigationController(rootViewController: ocrLanguages)
        
        switch deviceType {
        case .pad:
            ocrNavigationController.modalPresentationStyle = .formSheet
            ocrNavigationController.modalTransitionStyle = .crossDissolve
        default:
            break
        }
        
        self.present(ocrNavigationController, animated: true, completion: nil)
    }
    
    @objc fileprivate func rescanTapped(_ button: UIButton) {
        let initialURL = self.filePath.deletingLastPathComponent()
        let pdfURL = initialURL.appendingPathComponent(Constants.OriginalImageFolderName).appendingPathComponent(self.filePath.lastPathComponent)
        
        var ocrLanguage: String
        if let index = self.userDefaultsGetValue(userDefaultsOCRIndexPath) as? Int {
            let tesseractLanguage = ocrLanguages[index]
            ocrLanguage = tesseractLanguage
        } else {
            ocrLanguage = "eng"
        }
        
        if let indexPath = visibleCurrentCell {
            if let cell = collectionView.cellForItem(at: indexPath) as? PreviewCollectionViewCell {
                
                if filePath.isPDF {
                    self.createContinueRecognitionAction(pdfURL, ocrLanguage: ocrLanguage)
                } else {
                    cell.textView.text.removeAll()
                    self.textFromImage.removeAll()
                    
                    self.recognizeImageFromCell(cell, language: ocrLanguage)
                    self.infoLaucher.showAction(onController: self)
                }
            }
        }
    }
    
    @objc fileprivate func shareTapped(_ button: UIButton) {
        let shareController = ShareViewController()
        shareController.shareDelegate = self
        shareController.shareWith = .with
        self.getJPEGFile()
        
        switch deviceType {
        case .phone:
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { [unowned self] in
                self.blackView.alpha = 1.0
                
                }, completion: nil)
            
            shareController.modalPresentationStyle = .overFullScreen
            self.present(shareController, animated: true, completion: nil)
            
        case .pad:
            self.showPopoverFrom(shareController, barButtonItem: UIBarButtonItem(customView: shareButton), withSourceView: self.view, preferredContentSize: CGSize(width: 780, height: 454))
        default:
            break
        }
    }
}


// MARK: - Delete image

extension PreviewViewController {
    
    fileprivate func deleteImage(_ completion: @escaping (Bool) -> ()) {
        _ = self.alertController.showAlert(title: "Are you sure?".localized(),
                                           subTitle: "Selected file(s) will be deleted permanently!".localized(),
                                           style: .warning,
                                           buttonTitle:"Cancel".localized(),
                                           buttonColor:UIColor.colorFromRGB(rgbValue: 0xD0D0D0),
                                           otherButtonTitle: "Yes, delete it!".localized(),
                                           otherButtonColor: UIColor.colorFromRGB(rgbValue: 0xDD6B55)) {
                                            [unowned self] (success) in
                                            
                                            if success {
                                                
                                            } else {
                                                if let indexPath = self.visibleCurrentCell {
                                                    self.images.remove(at: indexPath.row)
                                                    
                                                    _ = AlertManagerController().showAlert(title: "Deleted!".localized(), subTitle: "Your file(s) has been deleted!".localized(), style: .success)
                                                    
                                                }
                                                
                                                self.collectionView.reloadData()
                                                self.previewDelegate?.didFinishDeletingFiles()
                                                
                                                if self.images.isEmpty {
                                                    completion(true)
                                                } else {
                                                    completion(false)
                                                }
                                            }
        }
        
    }
}


// MARK: - UIViewControllerTransitioningDelegate

extension PreviewViewController: UIViewControllerTransitioningDelegate {
    
    internal func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        transition.startingPoint = CGPoint(x: 20, y: view.frame.height - 20)
        transition.circleColor = UIColor.paleGrey
        
        return transition
    }
    
    internal func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        transition.startingPoint = CGPoint(x: 20, y: view.frame.height - 20)
        transition.circleColor = UIColor.paleGrey
        
        return transition
    }
}


// MARK: - Recognazeable

extension PreviewViewController: OCRDelegate, UserDefaultable, Texteable {
    
    internal func progressImageRecognition(_ progress: Float, counter: UInt) {
        
        if filePath.isPDF {
            print("pdf counter = \(counter)")
            let imageProgress = 100 / self.images.count
            progressPDFCounter += Int(counter) * imageProgress / 100
            print("FINAL PROGRESS = ", progressPDFCounter / 1000)
        } else {
            
        }
    }
    
    fileprivate func saveTextFromImageToTextFile() {
        
        if let indexPath = visibleCurrentCell {
            if let cell = collectionView.cellForItem(at: indexPath) as? PreviewCollectionViewCell {
                
                let textFromTextView = cell.textView.text
                UIPasteboard.general.string = textFromTextView
                
                var documentName: String
                
                if filePath.isPDF {
                    documentName = "page_\(indexPath.row)"
                } else {
                    documentName = filePath.lastPathComponent.deletingPathExtension
                }
                
                let fileTextURL = TextURL(fileURL: filePath)
                let newFileText = FileText(documentName: documentName, content: textFromTextView, fileTextURL: fileTextURL)
                self.createTextDocument(self, fileTextContent: newFileText)
            }
        }
    }
}


// MARK: - EditorViewControllerDelegate
extension PreviewViewController: EditorViewControllerDelegate {
    
    internal func didEndEditingImage(_ image: UIImage) {
        if let indexPath = self.visibleCurrentCell {
            if let cell = collectionView.cellForItem(at: indexPath) as? PreviewCollectionViewCell {
                self.images.remove(at: indexPath.row)
                self.images.insert(image, at: indexPath.row)
                cell.imageView.image = image
            }
        }
    }
}



// MARK: - ShareViewControllerDelegate & CloudShareable

extension PreviewViewController: ShareViewControllerDelegate {
    
    internal func didEndDismissController() {
        dismissBlackView()
    }
    
    internal func didSelectItemAt(_ indexPath: IndexPath, application: App?) {
        self.managerApp(application, inUIViewController: self, fromBarButtonItem: UIBarButtonItem(customView: shareButton))
    }
    
    fileprivate func dismissBlackView() {
        UIView.animate(withDuration: 0.5) { [unowned self] in
            self.blackView.alpha = 0.0
        }
    }
    
    internal func dismissShareController() {
        dismissBlackView()
    }
    
    internal func didSelectFileTypeSegmentTapped(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            print("JPEG")
            self.getJPEGFile()
            
        case 1:
            print("PDF Text")
            self.getPDFTextFile()
        default:
            break
        }
    }
}


// MARK: - InfoMessageLauncherDelegate

extension PreviewViewController: InfoMessageLauncherDelegate {
    
    internal func cancelTapped() {
        self.progressPDFCounter = 0
        ocrManager?.stopOCR()
        
        /// Abort session
        self.userDefaultsSetBoolValueForKey(true, key: self.filePath.lastPathComponent)
    }
}


// MARK: - Keyboard Notification

extension PreviewViewController {
    
    @objc fileprivate func keyboardWillShow(_ notification: Notification) {
        if let indexPath = visibleCurrentCell {
            if let cell = collectionView.cellForItem(at: indexPath) as? PreviewCollectionViewCell {
                if let userInfo = notification.userInfo {
                    if let keyboardSize = userInfo[UIKeyboardFrameBeginUserInfoKey] as? CGRect {
                        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.height), 0.0)
                        
                        if let tableConvertedRect = cell.textView.superview?.convert(cell.textView.frame, to: self.view) {
                            var diff = self.view.bounds.size.height - (tableConvertedRect.origin.y + tableConvertedRect.size.height)
                            
                            switch deviceType {
                            case .pad:
                                diff -= 70
                            default:
                                break
                            }
                            
                            var tableViewContentInsets = contentInsets
                            tableViewContentInsets.bottom -= diff
                            
                            if let rate = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval {
                                UIView.animate(withDuration: rate) {
                                    cell.textView.contentInset = tableViewContentInsets
                                    cell.textView.scrollIndicatorInsets = tableViewContentInsets
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc fileprivate func keyboardWillHide(_ notification: Notification) {
        if let indexPath = visibleCurrentCell {
            if let cell = collectionView.cellForItem(at: indexPath) as? PreviewCollectionViewCell {
                if let userInfo = notification.userInfo {
                    if let rate = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval {
                        UIView.animate(withDuration: rate) {
                            var tableInsets: UIEdgeInsets = cell.textView.contentInset
                            tableInsets.bottom = 0
                            cell.textView.contentInset = tableInsets
                            cell.textView.scrollIndicatorInsets = cell.textView.contentInset
                        }
                    }
                }
            }
        }
        
        saveTextFromImageToTextFile()
    }
}


// MARK: - UIScrollView scrollViewWillEndDragging

extension PreviewViewController {
    
    internal func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let currentPage = Int(targetContentOffset.pointee.x / view.frame.width)
        print(currentPage)
        
        let indexPath = IndexPath(row: currentPage, section: 0)
        if let cell = collectionView.cellForItem(at: indexPath) as? PreviewCollectionViewCell {
            switch switchSegmentedControl.selectedSegmentIndex {
            case 0:
                UIView.animate(withDuration: 0.25) {
                    cell.imageView.alpha = 1.0
                    cell.textView.alpha = 0.0
                }
            case 1:
                UIView.animate(withDuration: 0.25) {
                    cell.imageView.alpha = 0.0
                    cell.textView.alpha = 1.0
                    cell.textView.isHidden = false
                    
                    let fileTextURL = TextURL(fileURL: self.filePath)
                    if let textFromTxtFile = self.getContentFromTextDocumentURL(fileTextURL, indexPath: indexPath) {
                        cell.textView.text = textFromTxtFile
                    }
                }
            default:
                break
            }
        }
    }
}


// MARK: - getTxtFileContent

extension PreviewViewController {
    
    fileprivate func getTxtFileContent() {
        if let indexPath = visibleCurrentCell {
            if let cell = collectionView.cellForItem(at: indexPath) as? PreviewCollectionViewCell {
                let fileTextURL = TextURL(fileURL: filePath)
                
                if let textFromTxtFile = self.getContentFromTextDocumentURL(fileTextURL, indexPath: indexPath) {
                    cell.textView.text = textFromTxtFile
                }
            }
        }
    }
}


// MARK: - createOCRPDFs

extension PreviewViewController {
    
    fileprivate func createOCRPDFs(_ language: String, pdfURL: URL, completion: @escaping () -> ()) {
        ocrManager = OCRManager(language: language)
        ocrManager?.delegate = self
        
        DispatchQueue.global(qos: .background).async { [unowned self] in
            self.isOCRRecognizionRunning = true
            self.ocrManager?.recognizeAndCreatePDFFromImages(self.images, fileName: self.filePath.lastPathComponent, fileURL: self.filePath)
            
            DispatchQueue.main.async {
                completion()
            }
        }
    }
}


// MARK: - recognizeImage

extension PreviewViewController {
    
    fileprivate func recognizeImageFromCell(_ cell: PreviewCollectionViewCell, language: String) {
        ocrManager = OCRManager(language: language)
        ocrManager?.delegate = self
        if let imageForRecognize = cell.image {
            DispatchQueue.global(qos: .background).async { [unowned self] in
                self.isOCRRecognizionRunning = true
                
                if let recognizedText = self.ocrManager?.recognizeFromImage(imageForRecognize) {
                    if self.textFromImage.isEmpty {
                        self.textFromImage = recognizedText
                    }
                }
                
                DispatchQueue.main.async { [unowned self] in
                    self.infoLaucher.hideAnimation()
                    cell.textView.isHidden = false
                    cell.textView.text = self.textFromImage
                    ToastManager.main.makeToast(self.view, message: "Text copied to clipboard".localized(), duration: 1.5, position: .center)
                    UIPasteboard.general.string = self.textFromImage
                    
                    self.saveTextFromImageToTextFile()
                }
            }
        }
    }
}


extension PreviewViewController {
    
    fileprivate func addPDFQuikLookController() {
        filePDFController = previewManager.previewViewControllerForFileFromNavigation()
        filePDFController.view.frame = CGRect(x: 0, y: 64.0, width: self.view.frame.width, height: self.view.frame.height - 108)
        filePDFController.view.alpha = 0.0
    }
    
    fileprivate func openPreviewPDFController(_ pdfURL: URL) {
        self.previewManager.initWithFile(pdfURL)
        self.previewManager.quickLookPreviewController.reloadData()
        self.filePDFController.view.alpha = 1.0
        self.view.addSubview(self.filePDFController.view)
        self.addChildViewController(self.filePDFController)
        self.filePDFController.didMove(toParentViewController: self)
        self.editPDFTextButton.alpha = 1.0
    }
    
    fileprivate func startOCRPDFSession(_ pdfURL: URL, ocrLanguage: String) {
        self.userDefaultsSetBoolValueForKey(false, key: self.filePath.lastPathComponent)
        
        if !filesManager.fileExists(atPath: pdfURL.path) {
            self.infoLaucher.showAction(onController: self)
            
            self.createOCRPDFs(ocrLanguage, pdfURL: pdfURL) { [unowned self] in
                UIView.animate(withDuration: 0.25) { [unowned self] in
                    self.infoLaucher.hideAnimation()
                    self.progressPDFCounter = 0
                    
                    self.openPreviewPDFController(pdfURL)
                }
            }
            
        } else {
            /// Open PDF
            
            UIView.animate(withDuration: 0.25) { [unowned self] in
                self.openPreviewPDFController(pdfURL)
            }
        }
    }
    
    fileprivate func createContinueRecognitionAction(_ pdfURL: URL, ocrLanguage: String) {
        let alertController = UIAlertController(title: "Recognition".localized(), message: nil, preferredStyle: .alert)
        
        let destructiveAction = UIAlertAction(title: "Cancel".localized(), style: .destructive) { [unowned self] (result : UIAlertAction) in
            UIView.animate(withDuration: 0.25) { [unowned self] in
                self.openPreviewPDFController(pdfURL)
            }
        }
        
        let okAction = UIAlertAction(title: "Rescan".localized(), style: .default) { (result : UIAlertAction) in
            try? self.filesManager.removeItem(at: pdfURL)
            self.startOCRPDFSession(pdfURL, ocrLanguage: ocrLanguage)
        }
        
        UIView.animate(withDuration: 0.25) { [unowned self] in
            self.openPreviewPDFController(pdfURL)
        }
        
        alertController.addAction(destructiveAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}


// MARK: - PDF's text + JPEG's

extension PreviewViewController {
    
    fileprivate func getJPEGFile() {
        self.checkedURLPaths.removeAll()
        let newFile = File(filePath: self.filePath)
        self.checkedURLPaths.insert(newFile)
    }
    
    fileprivate func getPDFTextFile() {
        let initialURL = self.filePath.deletingLastPathComponent()
        
        
        if self.filePath.isPDF {
            self.checkedURLPaths.removeAll()
            let pdfTextURL = initialURL.appendingPathComponent(Constants.OriginalImageFolderName).appendingPathComponent(self.filePath.lastPathComponent)
            let newFile = File(filePath: pdfTextURL)
            self.checkedURLPaths.insert(newFile)
        } else {
            if let indexPath = self.visibleCurrentCell {
                let wrapper = PDFCreatorManager()
                let documentName = self.filePath.lastPathComponent.deletingPathExtension + ".pdf"
                let pdfURL = initialURL.appendingPathComponent(Constants.OriginalImageFolderName).appendingPathComponent(documentName)
                
                let fileTextURL = TextURL(fileURL: filePath)
                if let textFromTxtFile = self.getContentFromTextDocumentURL(fileTextURL, indexPath: indexPath) {
                    wrapper.createPDF(withName: documentName, withText: [NSAttributedString(string: textFromTxtFile)], withWritePath: pdfURL.path)
                    
                    self.checkedURLPaths.removeAll()
                    let newFile = File(filePath: pdfURL)
                    self.checkedURLPaths.insert(newFile)
                    
                } else {
                    // alert - or get text from image
                }
            }
        }
    }
}

extension PreviewViewController: OCRLangsViewDelegate{
    func selectedLanguageChanged() {
        resetNavigationBarItems()
    }

    func donePressed() {
        resetNavigationBarItems()
    }
    
    private func resetNavigationBarItems(){
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        let languageIndex = UserDefaults.standard.object(forKey: "ocr.downloaded.languages") as? Int ?? 0
        let imageName = self.searchedFlags[languageIndex]
        button.setImage(UIImage(named: imageName), for: .normal)
        button.addTarget(self, action: #selector(languagesTapped(_:)), for: .touchUpInside)
        
        let item = UIBarButtonItem(customView: button)
        
        self.navigationItem.setRightBarButtonItems([item, rescanButton], animated: true)
    }
}
