//
//  OCRLangsViewController.swift
//  Scanner
//
//   on 2/22/17.
//   
//

import UIKit

protocol OCRLangsViewDelegate: class {
    func donePressed()
    func selectedLanguageChanged()
}

class OCRLangsViewController: UITableViewController, UserDefaultable, OCRDatable, OCRLAnguageDownloadable {

    weak var delegate: OCRLangsViewDelegate?
    // MARK: - Properties
    
    internal var initialPath: URL?
    fileprivate var checkedURLPaths = Set<String>()
    
    
    
    // MARK: - LyfeCicle
    
    init() {
        super.init(style: .plain)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    
    
    // MARK: - LyfeCicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //FIXME: lucram aici
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK - Deinitializers
    
    deinit {

    }
}


// MARK: - Setup Views

extension OCRLangsViewController {
    
    fileprivate func setupUI() {
        self.title = "Choose Language".localized()
        self.tableView.backgroundColor = .white
        self.tableView.hideEmptyCells(UIColor.paleGrey)
        setCustomColoredNavigationBarTitle()
        self.tableView.register(OCRLangsTableViewCell.self, forCellReuseIdentifier: OCRLangsTableViewCell.reuseIdentifier)
        self.tableView.register(UINib(nibName: OCRLangsTableViewCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: OCRLangsTableViewCell.reuseIdentifier)
        self.tableView.separatorStyle = .none
        
        let doneNavButton = UIBarButtonItem(title: "Done".localized(), style: .plain, target: self, action: #selector(doneTapped(_:)))
        self.navigationItem.setRightBarButton(doneNavButton, animated: true)
    }
}


// MARK: - Table view data source

extension OCRLangsViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return section.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.items[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OCRLangsTableViewCell.reuseIdentifier, for: indexPath) as! OCRLangsTableViewCell
        
        cell.downloadButton.tag = indexPath.row
        
        let item = self.items[indexPath.section][indexPath.row]
        cell.nameLabel.text = item
        
        let iconName = self.searchedFlags[indexPath.row]
        cell.flagImageView.image = UIImage(named: iconName)
        
        let paramForDownload = ocrLanguages[indexPath.row]
        let filePath = ocrTessDataURL.appendingPathComponent(paramForDownload + ".traineddata")
        if filePath.fileExist {
            cell.isDownloaded = true
            let attr = try? FileManager.default.attributesOfItem(atPath: filePath.path)
            
            if let attr = attr {
                let size = attr[FileAttributeKey.size] as! UInt64
                let mbSize = Float(size)/1024.0/1024.0
                let twoDecimalPlaces = String(format: "%.2f", mbSize)
                cell.downloadButton.setTitle("\("Delete".localized())(\(twoDecimalPlaces)Mb)", for: .normal)
            }

            cell.downloadButton.setTitleColor(.red, for: .normal)
            cell.nameLabel.textColor = UIColor.darkSkyBlue
            cell.downloadButton.isEnabled = true
        } else {
            cell.isDownloaded = false
            
            cell.downloadButton.setTitle("Download".localized(), for: .normal)
            cell.downloadButton.setTitleColor(UIColor.darkSkyBlue, for: .normal)
            cell.nameLabel.textColor = UIColor.gri
            cell.downloadButton.isEnabled = true
        }
        
        if indexPath.row == 12 {
            cell.downloadButton.setTitle("", for: .normal)
            cell.downloadButton.isEnabled = false
            cell.downloadButton.setTitleColor(UIColor.gri, for: .normal)
        }
        
        if let index = self.userDefaultsGetValue(userDefaultsOCRIndexPath) as? Int {
            if indexPath.row == index && cell.isDownloaded {
//                print("shoult be selected \(item)")
                cell.checkMarkImageView.isHidden = false
            } else if cell.isDownloaded {
                cell.checkMarkImageView.isHidden = true
//                print("\(item) is downloaded but not selected")
            } else {
                cell.checkMarkImageView.isHidden = true
//                print("")
            }
        }

        cell.delegate = self
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.tableView.deselectRow(at: indexPath, animated: true)
        if let cell = tableView.cellForRow(at: indexPath) as? OCRLangsTableViewCell {
            if cell.isDownloaded {
                self.userDefaultsSaveValue(indexPath.row, key: userDefaultsOCRIndexPath)
                tableView.reloadData()
                delegate?.selectedLanguageChanged()
            }else{
                let alertController = UIAlertController(title: nil, message: "Download".localized(), preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "OK".localized(), style: .default) { (action) in
                    self.downloadLanguage(cell: cell, index: indexPath.row, select: true)
                }
                let cancelAction = UIAlertAction.init(title: "Cancel".localized(), style: .default, handler: nil)
                
                
                alertController.addAction(cancelAction)
                alertController.addAction(okAction)
                
                self.present(alertController, animated: true, completion:nil)
            }
        }

    }
}


// MARK: - Table view delegate

extension OCRLangsViewController {
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if let cell = cell as? OCRLangsTableViewCell {
//            let paramForDownload = ocrLanguages[indexPath.row]
//            let item = self.items[indexPath.section][indexPath.row]
//            cell.selectionStyle = .none
//            cell.nameLabel.text = item
//            cell.downloadLanguagesButton.tag = indexPath.row
//            let filePath = ocrTessDataURL.appendingPathComponent(paramForDownload + ".traineddata")
//            cell.downloadLanguagesButton.removeTarget(self, action: #selector(downloadLanguageButtonPressedFromCell(_:)), for: .touchUpInside)
//            cell.downloadLanguagesButton.removeTarget(self, action: #selector(didSelectCellAt(_:)), for: .touchUpInside)
//
//            if filePath.fileExist {
//                cell.isDownloaded = true
//                
//                cell.downloadLanguagesButton.addTarget(self, action: #selector(didSelectCellAt(_:)), for: .touchUpInside)
//                cell.downloadLanguagesButton.setTitleColor(UIColor.isDownloaded, for: .normal)
//                cell.nameLabel.textColor = UIColor.darkSkyBlue
//            } else {
//                cell.isDownloaded = false
//                
//                cell.downloadLanguagesButton.addTarget(self, action: #selector(downloadLanguageButtonPressedFromCell(_:)), for: .touchUpInside)
//                cell.downloadLanguagesButton.setTitleColor(UIColor.darkSkyBlue, for: .normal)
//                cell.nameLabel.textColor = UIColor.gri
//            }
//
//            let iconName = self.searchedFlags[indexPath.row]
//            cell.flagImageView.image = UIImage(named: iconName)
//
//            if let index = self.userDefaultsGetValue(userDefaultsOCRIndexPath) as? Int {
//                if indexPath.row == index && cell.isDownloaded {
//                    cell.downloadButton.setTitle("", for: .normal)
//                    cell.downloadButton.setImage(UIImage(named: "select"), for: .normal)
//                } else if cell.isDownloaded {
//                    cell.downloadButton.setTitle("Downloaded".localized(), for: .normal)
//                    cell.downloadButton.setImage(nil, for: .normal)
//                } else {
//                    cell.downloadButton.setTitleColor(UIColor.darkSkyBlue, for: .normal)
//                    cell.downloadButton.setTitle("Download".localized(), for: .normal)
//                    cell.downloadButton.setImage(nil, for: .normal)
//                }
//            }
//        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52.0
    }
}



// MARK: - @IBAction's

extension OCRLangsViewController: OCRLangsTableViewCellDelegate{
    
    func downloadLanguageButtonPressed(cell: OCRLangsTableViewCell, index: Int) {
        if cell.isDownloaded == true {
            let alertController = UIAlertController(title: nil, message: "Are you sure?".localized(), preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK".localized(), style: .default) { (action) in
                let paramForDownload = self.ocrLanguages[index]
                let filePath = self.ocrTessDataURL.appendingPathComponent(paramForDownload + ".traineddata")
                do{
                    try FileManager.default.removeItem(at: filePath)
                    
                    cell.isDownloaded = false
                    
                    if index == self.userDefaultsGetValue(self.userDefaultsOCRIndexPath) as? Int {
                        self.userDefaultsSaveValue(12, key: self.userDefaultsOCRIndexPath)
                        self.delegate?.selectedLanguageChanged()
                    }
                    self.tableView.reloadData()
                }catch{
                    print("wtf???")
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .default) { (action) in print("Tapped on cancel") }
            
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion:nil)

        }else{
            downloadLanguage(cell: cell, index: index, select: false)
        }
    }
    
    fileprivate func downloadLanguage(cell: OCRLangsTableViewCell, index: Int, select: Bool){
        if self.isConnectedToNetwork {
            cell.downloadActivityIndicator.startAnimating()
            cell.downloadActivityIndicator.isHidden = false
            let tesseractLanguage = ocrLanguages[index]
            cell.downloadButton.isHidden = true
            
            self.downloadFileSync(tesseractLanguage, progressCompletion: { (completedUnitCount, totalUnitCount) in
                print("completedUnitCount = \(completedUnitCount)")
                print("totalUnitCount = \(totalUnitCount)")
            }, downloadCompletion: { [unowned self] (success, error) in
                if success {
                    cell.downloadActivityIndicator.stopAnimating()
                    cell.downloadButton.isHidden = false
                    cell.downloadActivityIndicator.isHidden = true
                    cell.isDownloaded = true
                    if select == true{
                        self.userDefaultsSaveValue(index, key: self.userDefaultsOCRIndexPath)
                        self.delegate?.selectedLanguageChanged()
                    }
                    self.tableView.reloadData()
//                    self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                }
            })
        } else {
            let alertController = UIAlertController(title: "Cannot Get Language".localized(), message: "No Internet connection aviable.".localized(), preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK".localized(), style: .default) { (action) in print("Tapped on OK") }
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion:nil)
        }
    }
    
    @objc fileprivate func didSelectCellAt(_ sender: UIButton) {
//        let indexPath = IndexPath(row: sender.tag, section: 0)
//        self.tableView.deselectRow(at: indexPath, animated: true)
//        print("didSelectCellAt \(indexPath)")
//        
//        if let cell = self.tableView.cellForRow(at: indexPath) as? OCRLangsTableViewCell {
//            if cell.isDownloaded {
//                self.userDefaultsSaveValue(indexPath.row, key: userDefaultsOCRIndexPath)
//                tableView.reloadData()
//            }
//        }
    }
    
    @objc fileprivate func doneTapped(_ sender: Any) {
        delegate?.donePressed()
        self.dismiss(animated: true, completion: nil)
    }
}
