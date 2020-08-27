//
//  CloudOAuthViewController.swift
//  Scanner
//
//  
//   
//


import UIKit
import EvernoteSDK


class CloudOAuthViewController: UIViewController {
    
    // MARK: - Properties
    
    var shareAppType: ShareAppType = .none
    var checkedURLPaths = Set<File>()
    var logoImage: UIImage?
    
    lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = self.logoImage ?? UIImage(named: "noImage")
        
        return imageView
    }()
    
    fileprivate lazy var logInLogOutButton: UIButton = {
        let button = UIButton.createSendButton("")
        
        return button
    }()
    
    fileprivate lazy var cancelButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(named: "shape"), style: .done, target: self, action: #selector(cancelTapped(_:)))
        
        return button
    }()
    
//    fileprivate lazy var infoLaucher: InfoMessageLauncher = {
//        return InfoMessageLauncher()
//    }()
    
    static var infoLaucher = InfoMessageLauncher()
    
    
    // MARK: - LyfeCicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setViewLayout()
//        self.infoLaucher = InfoMessageLauncher()
        CloudOAuthViewController.infoLaucher.nameLabel.text = "Uploading".localized()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        manageLogButtons()
    }
    
    
    // MARK: - Deinitializers
    
    deinit {
        checkedURLPaths.removeAll()
        logoImage = nil
//        infoLaucher = nil
    }
}


// MARK: - UI&Layout

extension CloudOAuthViewController {
    
    fileprivate func setViewLayout() {
        self.view.backgroundColor = UIColor.paleGrey
        self.navigationItem.title = "Share to...".localized()
        self.navigationItem.setLeftBarButton(cancelButton, animated: true)
        
        self.view.addSubview(logInLogOutButton)
        self.view.addSubview(logoImageView)
        
        self.view.addConstraintsWithFormat("H:|-20-[v0]-20-|", views: logInLogOutButton)
        self.view.addConstraintsWithFormat("H:|-20-[v0]-20-|", views: logoImageView)
        
        self.view.addConstraintsWithFormat("V:|-100-[v0]-28-[v1(52)]-20-|", views: logoImageView, logInLogOutButton)
    }
}


// MARK: - Manage buttons

extension CloudOAuthViewController {
    
    fileprivate func manageLogButtons() {
        
        var urls = Array<URL>()
        for filePath in checkedURLPaths {
            urls.append(filePath.filePath)
        }
        
        switch shareAppType {
        case .dropBox:
            if let _ = dropboxClient{
                self.changeButtonState(logInLogOutButton, success: true)
                dropboxUpload(filePaths: urls)
            }else{
                self.changeButtonState(logInLogOutButton, success: false)
            }
            
        case .googleDrive:
            self.changeButtonState(logInLogOutButton, success: gDriveIsAuthorized())
            if gDriveIsAuthorized() {
                gDriveUploadFiles(filePath: urls)
            }
        case .evernote:
            self.changeButtonState(logInLogOutButton, success: evernoteIsAuthenticated())
            if evernoteIsAuthenticated() {
                evernoteUpload(filePaths: urls)
            }
        case .box:
            self.changeButtonState(logInLogOutButton, success: boxIsAuthenticated())
            if boxIsAuthenticated(){
                boxUploadFile(filePaths: urls)
            }
        case .yandexDisk:
            self.changeButtonState(logInLogOutButton, success: YDiskIsAuthenticated())
            if YDiskIsAuthenticated() {
                YDiskUploadFile(filePaths: urls)
            }
            
        default:
            break
        }
    }
}


// MARK: - @IBAction's

extension CloudOAuthViewController: EvernoteAutorizable, EvernoteUploadable, BoxAutorizable, BoxUploadable, YDiskProtocol, DropboxUploadable, GoogleDriveProtocol ,InfoMessageLauncherDelegate{
    
    @objc fileprivate func cancelTapped(_ button: UIBarButtonItem) {
        self.dismiss()
    }
    
    @objc fileprivate func logInTapped(_ button: UIButton) {
        print("logInTapped")
        
        switch shareAppType {
        case .dropBox:
            dropboxAutorize(targetController: self)
        case .googleDrive:
            gDriveAuthorize(targetController: navigationController!)
        case .evernote:
            evernoteAuthenticate(targetController: self)
        case .box:
            boxAuthenticate()
        case .yandexDisk:
            YDiskAuthenticate(targetController: self)
        default:
            break
        }
    }
    
    @objc fileprivate func logOutTapped(_ button: UIButton) {
        print("logOutTapped")
        
        switch shareAppType {
        case .dropBox:
            dropboxLogOut()
            
        case .googleDrive:
            gDriveLogout()
            
        case .evernote:
            evernoteLogout()
        
        case .box:
            boxLogOutBox()
        
        case .yandexDisk:
            YDiskLogOut()
            
        default:
            break
        }
    }
    
    fileprivate func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func uploadDidStart() {
        CloudOAuthViewController.infoLaucher.delegate = self
        CloudOAuthViewController.infoLaucher.showAction(onController: self)
    }
    
    func uploadDidFinish() {
        CloudOAuthViewController.infoLaucher.handleDismiss()
        self.dismiss()
    }
    
    func serviceAuthenticated(appType: ShareAppType, succes: Bool) {
        manageLogButtons()
    }
    
    func cancelTapped() {
        dismiss()
        
        switch shareAppType {
        case .dropBox:
            dropboxCancelUploads()
            
        case .googleDrive:
            gDriveCancelUploads()
            
        case .evernote:
            evernoteCancelUploads()
            
        case .box:
            boxCancelUploads()
            
        case .yandexDisk:
            YDiskCancelUploads()
            
        default:
            break
        }
    }
}


// MARK: - Is user Authentificated

extension CloudOAuthViewController {
    
    fileprivate func changeLabelState(_ sender: UILabel, success: Bool) {
        sender.text = success ? "Logged In".localized() : "Logged Off".localized()
        sender.textColor = success ? UIColor.black : UIColor.red
    }
    
    fileprivate func changeButtonState(_ button: UIButton, success: Bool) {
        if success {
            logInLogOutButton.setTitle("Log Out".localized(), for: .normal)
            logInLogOutButton.addTarget(self, action: #selector(logOutTapped(_:)), for: .touchUpInside)
        } else {
            logInLogOutButton.setTitle("Log In".localized(), for: .normal)
            logInLogOutButton.addTarget(self, action: #selector(logInTapped(_:)), for: .touchUpInside)
        }
    }
}
