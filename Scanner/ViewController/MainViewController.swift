//
//  MainViewController.swift
//  Scanner
//
//  
//   
//

import UIKit
import AVFoundation
import PhotosUI


class MainViewController: UIViewController, Contenteable, Customizeable, CloudShareable {

    // MARK: - Properties
    
    internal var initialPath: URL?
    
    internal var checkedURLPaths = Set<File>()
    fileprivate var imagesForPDF: NSMutableArray = []
    
    internal var files = [File]() {
        didSet {
            showHideBackgroundImageOfCollectionView(self)
        }
    }
    
    fileprivate var inSearchMode = false
    fileprivate var filteredURLs = [File]()
    fileprivate var blurredView: UIToolbar?
    
    fileprivate var selectedItemsArray = Array<Int>()
    
    fileprivate var transition: CircularTransition!
    
    fileprivate lazy var window: UIWindow = {
        guard let window = UIApplication.shared.keyWindow else { return UIWindow() }
        
        return window
    }()
    
    fileprivate var rootUrl: URL! = {
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let rootUrl = documentsUrl.appendingPathComponent("Scanner")
        return rootUrl
    }()
    
    fileprivate lazy var blackView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.alpha = 0.0
        view.frame = self.window.frame
        
        return view
    }()

    
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
//        layout.minimumLineSpacing = 42.0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MainCollectionViewCell.self, forCellWithReuseIdentifier: MainCollectionViewCell.reuseIdentifier)
        
        return collectionView
    }()
    
    internal lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "noFiles")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true

        return imageView
    }()
    
    fileprivate lazy var cameraButton: UIBarButtonItem =  {
        return UIBarButtonItem(image: UIImage(named: "camera"), style: .plain, target: self, action: #selector(cameraTapped(_:)))
    }()
    
    fileprivate lazy var galleryButton: UIBarButtonItem =  {
        return UIBarButtonItem(image: UIImage(named: "library"), style: .plain, target: self, action: #selector(galleryTapped(_:)))
    }()
    
    fileprivate lazy var settingsButton: UIBarButtonItem =  {
        return UIBarButtonItem(image: UIImage(named: "btnSettings"), style: .plain, target: self, action: #selector(settingsTapped(_:)))
    }()
    
    fileprivate lazy var editButton: UIBarButtonItem =  {
        return UIBarButtonItem(image: UIImage(named: "btnEditDefault"), style: .plain, target: self, action: #selector(editTapped(_:)))
    }()
    
    ///
    fileprivate let newFolderButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(named: "newFolder_1"), style: .plain, target: self, action: #selector(addNewFolderTapped(_:)))
        /// set text font if will be text
        
        
        return button
    }()
    
    internal lazy var shareButton: UIBarButtonItem =  {
        return UIBarButtonItem(image: UIImage(named: "share"), style: .plain, target: self, action: #selector(shareTapped(_:)))
    }()
    
    internal lazy var moveButton: UIBarButtonItem =  {
        return UIBarButtonItem(image: UIImage(named: "moveFolder"), style: .plain, target: self, action: #selector(moveTapped(_:)))
    }()
    
    internal lazy var mergeButton: UIBarButtonItem =  {
        return UIBarButtonItem(image: UIImage(named: "toPDF"), style: .plain, target: self, action: #selector(mergeTapped(_:)))
    }()
    
    internal lazy var deleteButton: UIBarButtonItem =  {
        return UIBarButtonItem(image: UIImage(named: "trash"), style: .plain, target: self, action: #selector(deleteTapped(_:)))
    }()
    
    fileprivate lazy var editToolBar: UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.isTranslucent = false
        toolBar.barTintColor = UIColor.white
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil);
        toolBar.setItems([self.newFolderButton, flexibleSpace, self.shareButton, flexibleSpace, self.moveButton, flexibleSpace, self.mergeButton, flexibleSpace, self.deleteButton], animated: true)
        self.isEnabledToolbarButtons(false)
        
        return toolBar
    }()
    
    fileprivate lazy var cameraToolBar: UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.isTranslucent = false
        toolBar.barTintColor = UIColor.white
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil);
        toolBar.setItems([flexibleSpace, self.cameraButton, flexibleSpace, self.galleryButton], animated: true)
        toolBar.addTopBorder()
        
        return toolBar
    }()
    
    fileprivate lazy var titleNavigationLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: self.view.frame.width / 2, height: 30))
        /// titleNavigationLabel.drawBottomDashedLine(UIColor.darkSkyBlue)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(editFolderNameGestureTapped(_:)))
        tapGesture.numberOfTapsRequired = 1
        label.addGestureRecognizer(tapGesture)
        
        return label
    }()
    
    fileprivate var inputTextField: UITextField?
    fileprivate var alertController: AlertManagerController!
    fileprivate weak var actionToEnable: UIAlertAction?
    
    
    // MARK: - LyfeCicle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let initialPath = initialPath {
//            print(initialPath)
            
            let title = initialPath.lastPathComponent.capitalized
            
            if navigationController?.viewControllers.count == 1 {
                self.navigationItem.title = "Scanner".localized()
            } else {
                self.navigationItem.titleView = titleNavigationLabel
                titleNavigationLabel.setTitle(title)
            }
            
            self.setCustomColoredNavigationBarTitle()
            self.prepareData()
        }
        
        setupViews()
        
        transition = CircularTransition()
        alertController = AlertManagerController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkActualController()
        prepareDataAndReloadCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkToolbarButtonStatus(self)
        self.isEnabledToolbarButtons(false)
        self.collectionView.reloadData()
    }
    
    
    // MARK: - Deinitializers
    
    deinit {
        checkedURLPaths.removeAll()
        imagesForPDF.removeAllObjects()
        files.removeAll()
        filteredURLs.removeAll()
        blurredView = nil
        transition = nil
        inputTextField = nil
        alertController = nil
        actionToEnable = nil
    }
}


// MARK: - Helper Methods - initWithDirectoryPath

extension MainViewController {
    
    func initWithDirectoryPath(_ initialPath: URL) {
        self.initialPath = initialPath
    }
    
     func prepareData() {
        if let initialPath = initialPath {
            files = filesForDirectory(initialPath)
        }
    }
    
    fileprivate func spreadData(_ indexPath: IndexPath) -> File {
        var file: File
        
        if inSearchMode {
            file = filteredURLs[indexPath.row]
        } else {
            file = files[indexPath.row]
        }
        
        return file
        
    }
}


// MARK: - Setup UI

extension MainViewController {
    
    fileprivate func setupViews() {
        view.backgroundColor = UIColor.paleGrey
        view.addSubview(backgroundImageView)
        
        let bgWidth: CGFloat = 200
        let bgHeight: CGFloat = 191
        
        switch deviceType {
        case .phone:
            backgroundImageView.frame = CGRect(x: 0, y: 0, width: bgWidth, height: bgHeight)
        default:
            backgroundImageView.frame = CGRect(x: 0, y: 0, width: bgWidth * 2, height: bgHeight * 2)
        }
        
        backgroundImageView.center = view.center
        
        navigationItem.setLeftBarButton(settingsButton, animated: true)
        navigationItem.setRightBarButton(editButton, animated: true)
        
        printDeviceModel()
        
        view.addSubview(collectionView)
        view.addSubview(cameraToolBar)
        
        view.addConstraintsWithFormat("H:|[v0]|", views: collectionView)
        view.addConstraintsWithFormat("H:|[v0]|", views: cameraToolBar)
        
        view.addConstraintsWithFormat("V:|-64-[v0][v1(44)]|", views: collectionView, cameraToolBar)
        
        cameraToolBar.addSubview(editToolBar)
        editToolBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44)
        editToolBar.alpha = 0.0
        
        navigationController?.view.addSubview(blackView)
        blackView.alpha = 0.0
    }
    
    fileprivate func checkActualController() {
        if navigationController?.viewControllers.count == 1 {
            self.showHideSetingsBarButton(true)
        } else {
            self.showHideSetingsBarButton(false)
        }
    }
}


// MARK: - UICollectionViewDataSource

extension MainViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return inSearchMode ? filteredURLs.count : files.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainCollectionViewCell.reuseIdentifier, for: indexPath) as! MainCollectionViewCell
        
        cell.layer.borderWidth = 0
        cell.layer.borderColor = UIColor.clear.cgColor
        
        if selectedItemsArray.isEmpty == false {
            for idx in selectedItemsArray {
                if idx == indexPath.row {
                    cell.layer.borderWidth = 2.0
                    cell.layer.borderColor = UIColor.rgb(red: 0, green: 122, blue: 255, alpha: 1).cgColor
                }
            }
        } else {
            cell.layer.borderWidth = 0
            cell.layer.borderColor = UIColor.clear.cgColor
        }
        
        return cell
    }
}


// MARK: - UICollectionViewDelegate

extension MainViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? MainCollectionViewCell {
            let item = spreadData(indexPath)
            
            let isToolBarHidden = self.editToolBar.alpha == 0.0 ? true : false
            cell.checkmarkImageView.isHidden = isToolBarHidden
            cell.isChecked = checkedURLPaths.contains(item)
            
            item.type.getImage(item, imageView: cell.imageView)
            cell.countLabel.text = item.countAndSize
            cell.dateLabel.text = item.date
            
            if item.isDirectory || item.filePath.isImage {
                cell.documentImageView.image = UIImage()
            } else {
                if let initialPath = initialPath {
                     let pdfThumbnailURL = initialPath.appendingPathComponent(Constants.HiddenFolderName).appendingPathComponent(item.filePath.lastPathComponent.deletingPathExtension + ".jpg")
//                    print("documentThumbnail pdf = \(pdfThumbnailURL)")
                    
                    if let documentThumbnail = pdfThumbnailURL.toUIImage {
                        cell.documentImageView.image = documentThumbnail
                    }
                    
                    cell.countLabel.text = item.countAndSize
                }
            }
            
            if item.isDirectory || item.filePath.isPDF {
                let name = item.displayName.components(separatedBy: ".")[0]
                cell.nameLabel.text = name
            } else {
                cell.nameLabel.text = ""
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedItemsArray.removeAll()
        
        self.collectionView.deselectItem(at: indexPath, animated: true)
        if let cell = collectionView.cellForItem(at: indexPath) as? MainCollectionViewCell {
            let item = spreadData(indexPath)
            
            if editToolBar.alpha == 1.0 {
                if checkedURLPaths.contains(item) {
                    checkedURLPaths.remove(item)
                    cell.isChecked = false
                    checkToolbarButtonStatus(self)
                    
                    if item.filePath.isImage {
                        self.imagesForPDF.remove(item.filePath.path)
                    }
                    
                } else {
                    checkedURLPaths.insert(item)
                    cell.isChecked = true
                    checkToolbarButtonStatus(self)
                    
                    if item.filePath.isImage {
                        self.imagesForPDF.add(item.filePath.path)
                    }
                }
            } else {
                if item.isDirectory {
                    let mainController =  MainViewController()
                    mainController.initWithDirectoryPath(item.filePath)
                    mainController.navigationItem.title = item.displayName
                    self.navigationController?.pushViewController(mainController, animated: true)
                } else {
                    var imagesForPreview = [UIImage]()
                    
                    if item.filePath.isPDF {
                        let images = self.getImagesFromPDFAtPath(item.filePath)
                        imagesForPreview = images
                    } else {
                        if let image = item.filePath.toUIImage {
                            imagesForPreview.append(image)
                        }
                    }
                    let previewController = PreviewViewController(images: imagesForPreview, filePath: item.filePath)
                    previewController.currentFile = item
                    previewController.previewDelegate = self
                    previewController.checkedURLPaths.insert(item)
                    self.navigationController?.pushViewController(previewController, animated: true)
                }
            }
            
            print(checkedURLPaths.count)
//            print("imagesForPDF.count = \(imagesForPDF.count)")
//            print("imagesForPDF = \(imagesForPDF)")
        }
    }
}


// MARK: - UICollectionViewDelegateFlowLayout

extension MainViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let lrMargins: CGFloat = 44.0
        let tbMargins: CGFloat = 20.0
        let scale: CGFloat = 1.8
        var newWidth: CGFloat = 0.0
        
        switch Device.size() {
        case .screen3_5Inch, .screen4Inch: // iPhone 4..5s
            newWidth = (screenWidth / 2) - lrMargins
            let newHeight = (newWidth * scale) - tbMargins
            
            return CGSize(width: newWidth, height: newHeight)
            
        case .screen4_7Inch, .screen5_5Inch: /// iPhone 6...7Plus
            newWidth = (screenWidth / 3) - lrMargins
            let newHeight = (newWidth * scale) - tbMargins
            
            return CGSize(width: newWidth, height: newHeight)
            
        case .screen7_9Inch: /// iPad mini
            newWidth = (screenWidth / 4.5) - lrMargins
            let newHeight = (newWidth * scale) - tbMargins
            
            return CGSize(width: newWidth, height: newHeight)
        default: /// All types of iPads
            newWidth = (screenWidth / 5.5) - lrMargins
            let newHeight = (newWidth * scale) - tbMargins
            
            return CGSize(width: newWidth, height: newHeight)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(10, 22, 10, 22)
    }
}


// MARK: - Action's

extension MainViewController: UserDefaultable, Imageable, FileBrowserDelegate {
    
    @objc fileprivate func settingsTapped(_ button: UIButton) {
        let settingsController = SettingsViewController()
        let settingsNavigationColtroller = UINavigationController(rootViewController: settingsController)
        
        switch deviceType {
        case .pad:
            settingsNavigationColtroller.modalPresentationStyle = .formSheet
            settingsNavigationColtroller.modalTransitionStyle = .crossDissolve
            self.present(settingsNavigationColtroller, animated: true, completion: nil)
        default:
            self.present(settingsNavigationColtroller, animated: true, completion: nil)
        }
    }
    
    @objc fileprivate func editTapped(_ button: UIButton) {
        selectedItemsArray.removeAll()
        
        self.checkToolbarButtonStatus(self)
        
        let isHidden: CGFloat = 0.0
        let isShowing: CGFloat = 1.0
        
        UIView.animate(withDuration: 0.25) { [unowned self] in
            if self.editToolBar.alpha == isHidden {
                self.editToolBar.alpha = isShowing
                self.cameraButton.tintColor = .clear
                self.cameraButton.isEnabled = false
                self.galleryButton.isEnabled = false
                self.galleryButton.tintColor = .clear
                self.editButton.image = UIImage(named: "btnEditSelected")
            } else {
                self.closeEditMode()
            }
        }
        
        if !checkedURLPaths.isEmpty {
            checkedURLPaths.removeAll()
        }
        
        self.collectionView.reloadData()
    }
    
    @objc fileprivate func cameraTapped(_ button: UIButton) {
        func presentCamera() {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            imagePicker.cameraCaptureMode = .photo
            imagePicker.videoQuality = .typeHigh
            imagePicker.delegate = self
            present(imagePicker, animated: true, completion: nil)
        }
        
        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) ==  AVAuthorizationStatus.authorized {
            // Already Authorized
            presentCamera()
        } else {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted: Bool) -> Void in
                if granted == true {
                    // User granted
                    presentCamera()
                } else {
                    let alert = UIAlertController(title: nil, message: "Camera Access Denied! Go to iOS Settings and turn on Camera Access for this app.".localized(), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alertAction) in
                        UIApplication.shared.openURL(NSURL(string: UIApplicationOpenSettingsURLString)! as URL)
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
        
//        let cameraController = CameraViewController()
//        cameraController.processDelegate = self
//        cameraController.transitioningDelegate = self
//        cameraController.modalPresentationStyle = .custom
//
        if let initialPath = initialPath {
            self.userDefaultsSaveValue(initialPath.path, key: "mainController.initialPath")
        }

//        self.present(cameraController, animated: true, completion: nil)
    }
    
    @objc fileprivate func galleryTapped(_ button: UIButton) {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            //Show error to user?
            return
        }
        
        func openGalery() {
            //Example Instantiating OpalImagePickerController with Closures
            let imagePicker = GalleryImagePickerController()
            
            //Present Image Picker
            self.presentGalleryImagePickerController(imagePicker, animated: true, select: { [unowned self] (assets) in
                //TODO: Save Images, update UI
                //print(assets.count)
                //Dismiss Controller
                
                let images = self.getImagesFrom(assets)
                self.saveImages(images, completion: { (success) in
                    
                })
                
                imagePicker.dismiss(animated: true, completion: {
                    self.selectedItemsArray.removeAll()
                    for i in 0..<images.count {
                        self.selectedItemsArray.append(i)
                    }
                    self.collectionView.reloadData()
                    if self.selectedItemsArray.isEmpty == false {
                        self.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                    }
                })
                }, cancel: {
                    //TODO: Cancel action?
            })
        }
        
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            openGalery()
        case .denied, .restricted :
            let alert = UIAlertController(title: nil, message: "Camera Access Denied! Go to iOS Settings and turn on Camera Access for this app.".localized(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alertAction) in
                UIApplication.shared.openURL(NSURL(string: UIApplicationOpenSettingsURLString)! as URL)
            }))
        
        self.present(alert, animated: true, completion: nil)
        case .notDetermined:
            // ask for permissions
            PHPhotoLibrary.requestAuthorization() { status in
                switch status {
                case .authorized:
                    openGalery()
                case .denied, .restricted:
                    let alert = UIAlertController(title: nil, message: "Let the app use device photo library in order to scan your documents".localized(), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alertAction) in
                        UIApplication.shared.openURL(NSURL(string: UIApplicationOpenSettingsURLString)! as URL)
                    }))
                case .notDetermined:
                    return
                    // won't happen but still
                }
            }
        }
    }
    
    @objc fileprivate func addNewFolderTapped(_ button: UIButton) {
        self.createFolderWithName("Create new folder".localized(), message: "Type new folder name below.".localized(), actionButtonTitle: "Create".localized(), forController: self) { [unowned self] (folderName) in
            
            if let initialPathUnwrapped = self.initialPath {
                let newFolderNameValidated = self.validateFileName(folderName, atURL: initialPathUnwrapped)
                
                if !self.isContain(self.files, folderName: newFolderNameValidated) {
                    self.create(folderAtPath: initialPathUnwrapped, withName: newFolderNameValidated)
                    let newFolder = File(filePath: initialPathUnwrapped.appendingPathComponent(newFolderNameValidated))
                    self.files.append(newFolder)
                    self.files = self.files.sorted(){ $0.timeStamp > $1.timeStamp }
                    
                    self.collectionView.reloadData()
                    
                    self.checkedURLPaths.removeAll()
                    self.closeEditMode()
                } else {
                    ToastManager.main.makeToast(self.view, message: "The folder already exist, please use another name.".localized(), duration: 3.0, position: .center)
                }
            }
        }
    }

    @objc fileprivate func shareTapped(_ button: UIButton) {
        let shareController = ShareViewController()
        shareController.shareDelegate = self
        shareController.shareWith = .none
        
        switch deviceType {
        case .phone:
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { [unowned self] in
                self.blackView.alpha = 1.0
                
                }, completion: nil)
            
            shareController.modalPresentationStyle = .overFullScreen
            self.present(shareController, animated: true, completion: nil)
            
        case .pad:
            self.showPopoverFrom(shareController, barButtonItem: shareButton, withSourceView: self.view, preferredContentSize: CGSize(width: 780, height: 388))
        default:
            break
        }
    }
    
    fileprivate func dismissBlackView() {
        UIView.animate(withDuration: 0.5) { [unowned self] in
            self.blackView.alpha = 0.0
        }
        
        self.closeEditMode()
    }
    
    @objc fileprivate func moveTapped(_ button: UIButton) {
        let fileBrowser = FileBrowserController.init(rootUrl: self.rootUrl, initialUrl: self.initialPath!)
        fileBrowser.delegate = self
        present(fileBrowser, animated: true, completion: nil)
        
//        let moveFileController = MoveFileViewController()
//        moveFileController.checkedURLPaths = self.checkedURLPaths
//        moveFileController.files = self.getOnlyDirectories(files)
//        
//        moveFileController.initialPath = self.initialPath
//        moveFileController.moveDelegate = self
//
//        let navigationController = UINavigationController(rootViewController: moveFileController)
//        
//        switch deviceType {
//        case .pad:
//            navigationController.modalPresentationStyle = .formSheet
//            navigationController.modalTransitionStyle = .crossDissolve
//            self.present(navigationController, animated: true, completion: nil)
//        default:
//            self.present(navigationController, animated: true, completion: nil)
//        }
    }
    
    func addButtonPressed(url: URL, folderName: String) {
        moveFiles(toPath: url) { (succes) in
            if succes{
                
            }else{

            }
        }
    }
    
    fileprivate func moveFiles(toPath path: URL, completion: (Bool) -> ()) {
        if !checkedURLPaths.isEmpty {
            self.createTHumbnailAndOriginalFolders(path)
            
            for pathToMove in checkedURLPaths {
                let initialURL = pathToMove.filePath.deletingLastPathComponent()
                self.moveMultipleURLs(initialURL, pathToMove: pathToMove, path: path)
            }
            
            completion(true)
        } else {
            // FIXME: - WTF?
            completion(false)
        }
    }
    
    fileprivate func moveMultipleURLs(_ initialURL: URL, pathToMove: File, path: URL) {
        let fileURL = pathToMove.filePath
        
        let sourceFileURL = initialURL.appendingPathComponent(fileURL.lastPathComponent)
        let destinationFileURL = path.appendingPathComponent(self.validateFileName(fileURL.lastPathComponent, atURL: path))
        
        let pdfName = fileURL.lastPathComponent.deletingPathExtension + ".pdf"
        let txtname = fileURL.lastPathComponent.deletingPathExtension + ".txt"
        
        let sourceOriginalFolderURL = initialURL.appendingPathComponent(Constants.OriginalImageFolderName)
        
        let sourcePDFFileURL = sourceOriginalFolderURL.appendingPathComponent(pdfName)
        let sourceTxtFileURL = sourceOriginalFolderURL.appendingPathComponent(txtname)
        let sourceOriginalFolderFileURL = sourceOriginalFolderURL.appendingPathComponent(fileURL.lastPathComponent)
        
        
        
        let destinationOriginalFolderURL = path.appendingPathComponent(Constants.OriginalImageFolderName)
        
        let destinationPDFFileURL = destinationOriginalFolderURL.appendingPathComponent(self.validateFileName(pdfName, atURL: path))
        let destinationTxtFileURL = destinationOriginalFolderURL.appendingPathComponent(self.validateFileName(txtname, atURL: path))
        let destinationOriginalFolderFileURL = destinationOriginalFolderURL.appendingPathComponent(self.validateFileName(fileURL.lastPathComponent, atURL: path))
        
        self.moveFile(sourceFileURL, toDestinationPath: destinationFileURL)
        self.moveFile(sourcePDFFileURL, toDestinationPath: destinationPDFFileURL)
        self.moveFile(sourceTxtFileURL, toDestinationPath: destinationTxtFileURL)
        self.moveFile(sourceOriginalFolderFileURL, toDestinationPath: destinationOriginalFolderFileURL)
    }
    
    @objc fileprivate func mergeTapped(_ button: UIButton) {
        self.createPDFDocumentWithName("Create new document".localized(), message: "Type new document name below.".localized(), actionButtonTitle: "Create".localized(), fileStatus: .create, inputTextField: self.inputTextField, forController: self) { [unowned self] (documentName) in
            
            if let pdfArray = Array(self.imagesForPDF) as? [String] {
                if let pdfDocument = self.convertPDFsFromPaths(pdfArray) {
                    if let initialPath = self.initialPath {
                        let pdfName = documentName + ".pdf"
                        let documentPath = initialPath.appendingPathComponent(pdfName)
                        let file = File(filePath: documentPath)
                        DatabaseManager.insert(file: file)
                        self.files.append(file)
                        self.files = self.files.sorted(){ $0.timeStamp > $1.timeStamp }
                        
                        do {
                            try pdfDocument.write(to: documentPath)
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
            
            self.checkedURLPaths.removeAll()
            self.imagesForPDF.removeAllObjects()
            self.checkToolbarButtonStatus(self)
            self.prepareDataAndReloadCollectionView()
            
            
            self.selectedItemsArray.removeAll()
            self.selectedItemsArray.append(0)
            self.collectionView.reloadData()
            if self.selectedItemsArray.isEmpty == false {
                self.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
    }
    
    @objc fileprivate func deleteTapped(_ button: UIButton) {
        let alertController = UIAlertController(title: "Are you sure?", message: "Selected file(s) will be deleted permanently!".localized(), preferredStyle: .alert)
        let destructiveAction = UIAlertAction(title: "Cancel".localized(), style: .destructive) { (result : UIAlertAction) in }
        
        // Replace UIAlertActionStyle.Default by UIAlertActionStyle.default
        let okAction = UIAlertAction(title: "OK".localized(), style: .default) { [unowned self] (result : UIAlertAction) in
            for (_, filePath) in self.checkedURLPaths.enumerated() {
                for (index, file) in self.files.enumerated() {
                    
                    if file.filePath == filePath.filePath {
                        self.files.remove(at: index)
                        
                        self.remove(fileAtPath: filePath.filePath)
                        self.checkedURLPaths.remove(filePath)
                        
                        if let thumbnailURL = filePath.thumbnailURL {
                            
                            do {
                                try FileManager.default.removeItem(at: thumbnailURL)
                            } catch {
                                print("Cannot remove \(thumbnailURL), error \(error)")
                            }
                        }
                        
                        self.collectionView.reloadData()
                    }
                }
            }
            
            self.closeEditMode()
        }
        
        alertController.addAction(destructiveAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc fileprivate func editFolderNameGestureTapped(_ gesture: UITapGestureRecognizer) {
        if let initialPath = self.initialPath {
            _ = URL(fileURLWithPath: initialPath.path.deletingLastPathComponent)
            let alertController = UIAlertController(title: initialPath.lastPathComponent.capitalized, message: "", preferredStyle: .alert)
            
            alertController.addTextField(configurationHandler: { [unowned self] (textField: UITextField!) in
                textField.placeholder = initialPath.lastPathComponent.capitalized
                textField.addTarget(self, action: #selector(self.nameFileChanged(_:)), for: .editingChanged)
            })
            
            let cancelButtonAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
            let createButtonAction = UIAlertAction(title: "Create".localized(), style: .default) { (alertAction) in
                if let textfield = alertController.textFields?.first {
                    if let fileName = textfield.text {
                        self.titleNavigationLabel.setTitle(fileName.capitalized)
                        let newPath = initialPath.deletingLastPathComponent().appendingPathComponent(fileName)
                        try? self.filesManager.moveItem(at: initialPath, to: newPath)
//                        self.create(folderAtPath: initialPathURL, withName: fileName)
//                        try? self.filesManager.removeItem(at: initialPath)
                    }
                }
            }
            
            alertController.addAction(cancelButtonAction)
            alertController.addAction(createButtonAction)
            
            createButtonAction.isEnabled = false
            self.actionToEnable = createButtonAction
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @objc fileprivate func nameFileChanged(_ textField: UITextField) {
        if let initialPath = initialPath {
            let initialPathURL = URL(fileURLWithPath: initialPath.path.deletingLastPathComponent)
            if let folderName = textField.text {
                print(folderName)
                let renamedFileURL = initialPathURL.appendingPathComponent(folderName)
                self.actionToEnable?.isEnabled = (folderName.characters.count >= 1) && !renamedFileURL.fileExist
            }
        }
    }
}


// MARK: - Show&Hide settings bar button

extension MainViewController {
    
    fileprivate func showHideSetingsBarButton(_ status: Bool) {
        if status {
            self.settingsButton.isEnabled = true
        } else {
            self.navigationItem.leftBarButtonItem = navigationItem.backBarButtonItem
            navigationItem.backBarButtonItem?.title?.addTextSpacing(-0.7)
        }
    }
    
    fileprivate func prepareDataAndReloadCollectionView() {
        self.prepareData()
        closeEditMode()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}


// MARK: - MoveFileViewControllerDelegate

extension MainViewController: MoveFileViewControllerDelegate {
    
    internal func didFinishMovingFiles() {
        prepareDataAndReloadCollectionView()
    }
}


// MARK: - PreviewViewControllerDelegate

extension MainViewController: PreviewViewControllerDelegate {
    
    internal func didFinishDeletingFiles() {
        prepareDataAndReloadCollectionView()
    }
}


// MARK: - Filter on search

extension MainViewController {
    
    fileprivate func filterContentForSearchText(_ searchText: String) {
        filteredURLs = files.filter({ (file: File) -> Bool in
            return file.displayName.lowercased().contains(searchText.lowercased())
        })
        
        collectionView.reloadData()
    }
}


// MARK: - ProcessImagesViewControllerDelegate

extension MainViewController: Processable {
    
    internal func didFinishImageTransfer() {
        prepareDataAndReloadCollectionView()
    }
}


// MARK: - ShareViewControllerDelegate

extension MainViewController: ShareViewControllerDelegate {
    
    internal func didEndDismissController() {
        dismissBlackView()
        self.closeEditMode()
        self.collectionView.reloadData()
    }
    
    internal func didSelectItemAt(_ indexPath: IndexPath, application: App?) {
        selectedItemsArray.removeAll()
        self.managerApp(application, inUIViewController: self, fromBarButtonItem: shareButton)
    }
    
    func didSelectFileTypeSegmentTapped(_ sender: UISegmentedControl) { }
}


// MARK: - CloudShareable

extension MainViewController {
    
    func dismissShareController() {
        dismissBlackView()
        self.closeEditMode()
        self.collectionView.reloadData()
    }
}


// MARK: - Save images from Gallery

extension MainViewController {
    
    fileprivate func saveImages(_ images: [UIImage], completion: (Bool) ->()) {
        
        if let initialPath = initialPath {
            for image in images {
                if let imageData = image.toFullData {
                    let newImageName = self.validateFileName("img.jpg", atURL: initialPath)
                    let imageURL = initialPath.appendingPathComponent(newImageName)
                    
                    let originalImagePaths = initialPath.appendingPathComponent(Constants.OriginalImageFolderName).appendingPathComponent(newImageName )
                    let thumbnailImage = initialPath.appendingPathComponent(Constants.HiddenFolderName).appendingPathComponent(newImageName)
                    
                    if !isOriginalImagesFolderExist(initialPath) && !isThumbnailFolderExist(initialPath) {
                        self.create(folderAtPath: initialPath, withName: Constants.HiddenFolderName)
                        self.create(folderAtPath: initialPath, withName: Constants.OriginalImageFolderName)
                    }
                    
                    if let imageData = imageData.resizeData() {
                        try? imageData.write(to: thumbnailImage)
                    }
                    
                    try? imageData.write(to: imageURL)
                    try? imageData.write(to: originalImagePaths)
                    
                    let file = File(filePath: imageURL)
                    DatabaseManager.insert(file: file)
                    self.files.append(file)
                    self.files = self.files.sorted(){ $0.timeStamp > $1.timeStamp }
                    
                    self.collectionView.reloadData()
                    completion(true)
                }
            }
        } else {
            completion(false)
        }
    }
}


// MARK: - UIViewControllerTransitioningDelegate

extension MainViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        transition.startingPoint = CGPoint(x: (view.frame.width / 2) - 20, y: view.frame.height - 20)
        transition.circleColor = UIColor.paleGrey
        
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        transition.startingPoint = CGPoint(x: (view.frame.width / 2) - 20, y: view.frame.height - 2)
        transition.circleColor = UIColor.paleGrey
        
        return transition
    }
}


// MARK: - UINavigationControllerDelegate

extension MainViewController: UINavigationControllerDelegate {}


// MARK: - Close edit mode

extension MainViewController {
    fileprivate func closeEditMode() {
        self.editToolBar.alpha = 0.0
        self.cameraButton.tintColor = UIColor.darkSkyBlue
        self.cameraButton.isEnabled = true
        self.galleryButton.tintColor = UIColor.darkSkyBlue
        self.galleryButton.isEnabled = true
        self.editButton.image = UIImage(named: "btnEditDefault")
    }
}



// MARK: - Move

extension MainViewController {
    
    fileprivate func checkIfFileExistInOriginalHiddenFolder() {
        
    }
}

extension MainViewController: UIImagePickerControllerDelegate, CropperViewControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: false) { 
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
//            image = image.rotatedImageWithDegree(90)!
            self.prepareDataAndReloadCollectionView()
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let cropController = storyboard.instantiateInitialViewController() as! CropperViewController
            cropController.originalImage = image
            
            cropController.cropperDelegate = self
            self.present(cropController, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func doneButtonPressed() {
        prepareDataAndReloadCollectionView()
        if let file = files.first {
            DatabaseManager.insert(file: file)
        }
        
        
        selectedItemsArray.removeAll()
        selectedItemsArray.append(0)
        collectionView.reloadData()
        if selectedItemsArray.isEmpty == false {
            collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
}
