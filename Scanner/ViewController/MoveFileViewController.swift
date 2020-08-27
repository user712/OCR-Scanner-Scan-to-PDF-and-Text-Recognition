//
//  MoveFileViewController.swift
//  Scanner
//
//
//   
//

import UIKit

protocol MoveFileViewControllerDelegate: class {
    func didFinishMovingFiles()
}

class MoveFileViewController: UITableViewController, Contenteable {

    // MARK: - Properties
    
    var files = [File]()
    var checkedURLPaths = Set<File>()
    var initialPath: URL?
    
    weak var moveDelegate: MoveFileViewControllerDelegate?
    
    fileprivate var onlyDirectories = [File]()
    fileprivate let cellID = "MoveFileCell"
    fileprivate let navigationBarTitle = "Move to...".localized()
    fileprivate let cancelImage = UIImage(named: "shape")
    fileprivate var inputTextField: UITextField?
    fileprivate let alertController = AlertManagerController()
    
    fileprivate lazy var cancelButton: UIButton =  {
        let button = UIButton(type: .custom)
        button.setImage(self.cancelImage, for: .normal)
        button.addTarget(self, action: #selector(cancelTapped(_:)), for: .touchUpInside)
        
        return button
    }()
    
    func isRootPath() -> Bool{
        if let initialPath = initialPath{
            if initialPath.lastPathComponent == "Scanner" {
                return true
            }
        }
        return false
    }
    
    fileprivate lazy var cancelnavButton: UIBarButtonItem =  {
        let button = UIBarButtonItem(image: self.cancelImage, style: .plain, target: self, action: #selector(cancelTapped(_:)))
        
        return button
    }()
    
    fileprivate lazy var navigationContainerView: UIView =  {
        let customView = UIView()
        customView.backgroundColor = .clear
        
        
        return customView
    }()
    
    fileprivate lazy var titleNavigationLabel: UILabel =  {
        let label = UILabel()
        label.textColor = UIColor.darkSkyBlue
        label.text?.addTextSpacing(-0.7)
        label.text = self.navigationBarTitle
        label.textAlignment = .center
        label.font = UIFont.textStyleFontRegular(22)
        
        return label
    }()
    
    
    // MARK: - LyceCicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if onlyDirectories.isEmpty {
            self.prepareData()
        }
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.backgroundColor = UIColor.paleGrey
        tableView.hideEmptyCells(UIColor.rgb(red: 228, green: 228, blue: 234, alpha: 1.0))
        
        if deviceType == .pad {
            navigationItem.setLeftBarButton(cancelnavButton, animated: true)
            navigationItem.title = navigationBarTitle
            setCustomColoredNavigationBarTitle()
        } else {
            navigationContainerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 32)
            titleNavigationLabel.frame = CGRect(x: 0, y: 0, width: 120, height: 30)
            cancelButton.frame = CGRect(x: -3, y: 0, width: 30, height: 30)
            
            titleNavigationLabel.center = navigationContainerView.center
            navigationContainerView.addSubview(titleNavigationLabel)
            navigationContainerView.addSubview(cancelButton)
            navigationItem.titleView = navigationContainerView
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tableView.reloadData()
    }
    
    
    // MARK: - Deinitializers
    
    deinit {
        files.removeAll()
        checkedURLPaths.removeAll()
        initialPath = nil
        moveDelegate = nil
    }
}


// MARK: - Table view data source

extension MoveFileViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return isRootPath() ? 2 : 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if isRootPath() {
            switch section {
            case 0:
                return 1
            default:
                return onlyDirectories.count
            }
        }
        
        switch section {
        case 0, 1:
            return 1
        default:
            return onlyDirectories.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        if isRootPath() {
            switch indexPath.section {
            case 0:
                cell.imageView?.image = UIImage(named: "addFolder")
                cell.textLabel?.text = "Create new folder".localized()
            default:
                let item = onlyDirectories[indexPath.row]
                
                cell.imageView?.image = UIImage(named: "documentsFolder")
                cell.textLabel?.text = item.filePath.lastPathComponent
            }
        }else{
            switch indexPath.section {
            case 0:
                cell.imageView?.image = UIImage(named: "addFolder")
                cell.textLabel?.text = ".."
            case 1:
                cell.imageView?.image = UIImage(named: "addFolder")
                cell.textLabel?.text = "Create new folder".localized()
            default:
                let item = onlyDirectories[indexPath.row]
                
                cell.imageView?.image = UIImage(named: "documentsFolder")
                cell.textLabel?.text = item.filePath.lastPathComponent
            }
        }
        
        // Configure the cell...
        
        cell.textLabel?.textColor = UIColor.gri
        cell.textLabel?.text?.addTextSpacing(-0.6)
        
        return cell
    }
}


// MARK: - Table view delegate

extension MoveFileViewController{
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isRootPath() {
            switch indexPath.section {
            case 0:
                createFolderTapped()
            default:
                let item = files[indexPath.row]
                
                self.moveFiles(toPath: item.filePath) { [unowned self] (success) in
                    if success {
                        self.dismissCurrentController()
                        self.moveDelegate?.didFinishMovingFiles()
                    } else {
                        print("Something wrong")
                    }
                }
            }
        }else{
            switch indexPath.section {
            case 0:
                if let lastPathComponent = initialPath?.lastPathComponent{
                    let strUrl = initialPath?.absoluteString.replace(target: ("/\(lastPathComponent)/"), withString: "")
                    let url = URL(string: strUrl!)!
                    
                    self.moveFiles(toPath: url) { [unowned self] (success) in
                        if success {
                            self.dismissCurrentController()
                            self.moveDelegate?.didFinishMovingFiles()
                        } else {
                            print("Something wrong")
                        }
                    }
                }
            case 1:
                createFolderTapped()
            default:
                let item = files[indexPath.row]
                
                self.moveFiles(toPath: item.filePath) { [unowned self] (success) in
                    if success {
                        self.dismissCurrentController()
                        self.moveDelegate?.didFinishMovingFiles()
                    } else {
                        print("Something wrong")
                    }
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
}


extension MoveFileViewController {
    
    @objc fileprivate func cancelTapped(_ button: UIBarButtonItem) {
        dismissCurrentController()
    }
    
    fileprivate func createFolderTapped() {

        self.createFolderWithName("Create new folder".localized(), message: "Type new folder name below.".localized(), actionButtonTitle: "Create".localized(), forController: self) { [unowned self] (folderName) in
            
            if let initialPathUnwrapped = self.initialPath {
                let newFolderNameValidated = self.validateFileName(folderName, atURL: initialPathUnwrapped)
                
                if !self.isContain(self.files, folderName: newFolderNameValidated) {
                    self.create(folderAtPath: initialPathUnwrapped, withName: newFolderNameValidated)
                    let newFolder = File(filePath: initialPathUnwrapped.appendingPathComponent(newFolderNameValidated))
                    self.files.append(newFolder)
                    self.prepareData()
                    self.moveDelegate?.didFinishMovingFiles()
                    self.tableView.reloadData()
                } else {
                    ToastManager.main.makeToast(self.view, message: "The folder already exist, please use another name.".localized(), duration: 3.0, position: .center)
                }
            }
        }
    }
    
    fileprivate func dismissCurrentController() {
        self.dismiss(animated: true, completion: nil)
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
    
    fileprivate func prepareData() {
        // Prepare data
        onlyDirectories = getOnlyDirectories(files)
    }
}


extension MoveFileViewController {
    
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
}














