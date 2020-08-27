//
//  FileBrowserController.swift
//  Scanner
//
//  Created  on 5/30/17.
//   
//

import Foundation
import UIKit


protocol FileBrowserDelegate: class {
    func addButtonPressed(url: URL, folderName: String)
}


class FileBrowserController: UIViewController {
    
    weak var delegate: FileBrowserDelegate?
    
    fileprivate var rootUrl: URL?
    fileprivate var initialUrl: URL?
    
    @IBOutlet weak var navigationItemOutlet: UINavigationItem!
    @IBOutlet weak var tableViewOutlet: UITableView!
    
    fileprivate var folders = Array<URL>()
    
    required init(rootUrl: URL, initialUrl: URL) {
        super.init(nibName: nil, bundle: nil)
        self.rootUrl = rootUrl
        self.initialUrl = initialUrl

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItemOutlet.title = initialUrl?.lastPathComponent
        
        tableViewOutlet.register(FileBrowserCell.self, forCellReuseIdentifier: FileBrowserCell.identifier)
        tableViewOutlet.register(UINib(nibName: FileBrowserCell.identifier, bundle: nil), forCellReuseIdentifier: FileBrowserCell.identifier)
        
        getData(url: initialUrl!)
        
        tableViewOutlet.tableFooterView = UIView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    fileprivate func isRootPath() -> Bool {
        return initialUrl!.lastPathComponent == rootUrl!.lastPathComponent
    }
    
    @IBAction func cancelButtonAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addFolderAction(_ sender: UIBarButtonItem) {
        delegate?.addButtonPressed(url: initialUrl!, folderName: initialUrl!.lastPathComponent)
        dismiss(animated: true, completion: nil)
    }
    
    func getData(url: URL){
        let dirs = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants, .skipsPackageDescendants])
        folders = Array<URL>()
        if let dirs = dirs{
            for dir in dirs{
                var isDir: ObjCBool = false
                
                if FileManager.default.fileExists(atPath: dir.path, isDirectory: &isDir){
                    if isDir.boolValue == true{
                        folders.append(dir)
                    }
                }
            }
            tableViewOutlet.reloadData()
        }
    }
}

extension FileBrowserController: UITableViewDelegate, UITableViewDataSource, FileBrowserDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return isRootPath() ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return isRootPath() ? folders.count : 1
        default:
            return folders.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return nil
        default:
            return initialUrl?.lastPathComponent
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return isRootPath() ? 0.1 : 30
        default:
            return 30
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isRootPath() {
            let folderCell = tableView.dequeueReusableCell(withIdentifier: FileBrowserCell.identifier, for: indexPath) as! FileBrowserCell
            folderCell.delegate = self
            folderCell.folderUrl = folders[indexPath.row]
            return folderCell
        }
        
        if indexPath.section == 0 {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "")
            cell.imageView?.image = UIImage(named: "icTop")
            cell.imageView?.contentMode = .left
            return cell
        }
        
        let folderCell = tableView.dequeueReusableCell(withIdentifier: FileBrowserCell.identifier, for: indexPath) as! FileBrowserCell
        folderCell.delegate = self
        folderCell.folderUrl = folders[indexPath.row]
        return folderCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        func navigateToNextUrl(){
            let url = folders[indexPath.row]
            initialUrl = url
            navigationItemOutlet.title = initialUrl?.lastPathComponent
            getData(url: url)
        }
        
        if isRootPath() {
            navigateToNextUrl()
            return
        }
        
        switch indexPath.section {
        case 0:
            let url = initialUrl?.deletingLastPathComponent()
            initialUrl = url
            navigationItemOutlet.title = initialUrl?.lastPathComponent
            getData(url: url!)
        default:
            navigateToNextUrl()
        }
    }
    
    func addButtonPressed(url: URL, folderName: String) {
        delegate?.addButtonPressed(url: url, folderName: folderName)
        dismiss(animated: true, completion: nil)
    }
}


class FileBrowserCell: UITableViewCell {
    static let identifier = "FileBrowserCell"
    
    weak var delegate: FileBrowserDelegate?
    
    @IBOutlet weak var addButtonOutlet: UIButton!{
        didSet{
            addButtonOutlet.imageView?.contentMode = .scaleAspectFit
        }
    }
    
    var folderUrl: URL?{
        didSet{
            if let folderUrl = folderUrl{
                folderNameLabel?.text = folderUrl.lastPathComponent
            }
        }
    }
    
    @IBOutlet weak var folderNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        delegate?.addButtonPressed(url: folderUrl!, folderName: folderUrl!.lastPathComponent)
    }
}
