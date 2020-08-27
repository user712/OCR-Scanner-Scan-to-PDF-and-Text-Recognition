//
//  SettingsCloudCell.swift
//  Scanner
//
//  Created  on 6/27/17.
//   
//

import Foundation
import UIKit


class SettingsCloudCell: UITableViewCell, DropboxAutorizable, GoogleDriveProtocol, EvernoteAutorizable, YDiskProtocol, BoxAutorizable {
    static let identifier = "SettingsCloudCell"
    
    @IBOutlet weak var cloudImageView: UIImageView!
    @IBOutlet weak var cloudLabel: UILabel!
    @IBOutlet weak var coudButtonState: UIButton!
    
    var parrentController = UIViewController()
    
    var cloudType: ShareAppType? {
        didSet{
            if let cloudType = cloudType {
                switch cloudType {
                case .dropBox:
                    cloudLabel?.text = "Dropbox"
                    cloudImageView?.image = #imageLiteral(resourceName: "icDropBox")
                case .googleDrive:
                    cloudLabel?.text = "Google Drive"
                    cloudImageView?.image = #imageLiteral(resourceName: "icGoogleDrive")
                case .evernote:
                    cloudLabel?.text = "Evernote"
                    cloudImageView?.image = #imageLiteral(resourceName: "icEvernote")
                case .yandexDisk:
                    cloudLabel?.text = "Yandex Disk"
                    cloudImageView?.image = #imageLiteral(resourceName: "icYadi")
                case .box:
                    cloudLabel?.text = "Box"
                    cloudImageView?.image = #imageLiteral(resourceName: "icBox")
                default:
                    break
                }
                
                setButtonTitleFor(cloudType: cloudType)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func cloudButtonAction(_ sender: UIButton) {
        if let cloudType = cloudType {
            handleAuthorizeActionFor(cloudType: cloudType)
        }
    }
    
    private func setButtonTitleFor(cloudType: ShareAppType) {
        var isAuthorized = false
        
        switch cloudType {
        case .dropBox:
            if let _ = dropboxClient {
                isAuthorized = true
            }else{
                isAuthorized = false
            }
        case .googleDrive:
            isAuthorized = gDriveIsAuthorized()
        case .evernote:
            isAuthorized = evernoteIsAuthenticated()
        case .yandexDisk:
            isAuthorized = YDiskIsAuthenticated()
        case .box:
            isAuthorized = boxIsAuthenticated()
        default:
            break
        }

        coudButtonState.setTitle(isAuthorized ? "Log Out".localized() : "Log In".localized(), for: .normal)
    }
    
    private func handleAuthorizeActionFor(cloudType: ShareAppType) {
        
        switch cloudType {
        case .dropBox:
            if let _ = dropboxClient {
                dropboxLogOut()
                setButtonTitleFor(cloudType: cloudType)
            }else{
                dropboxAutorize(targetController: parrentController)
            }
        case .googleDrive:
            if gDriveIsAuthorized() {
                gDriveLogout()
                setButtonTitleFor(cloudType: cloudType)
            }else{
                gDriveAuthorize(targetController: parrentController.navigationController!)
            }
        case .evernote:
            if evernoteIsAuthenticated() {
                evernoteLogout()
                setButtonTitleFor(cloudType: cloudType)
            }else{
                evernoteAuthenticate(targetController: parrentController)
            }
        case .yandexDisk:
            if YDiskIsAuthenticated() {
                YDiskLogOut()
                setButtonTitleFor(cloudType: cloudType)
            }else{
                YDiskAuthenticate(targetController: parrentController)
            }
        case .box:
            if boxIsAuthenticated() {
                boxLogOutBox()
                setButtonTitleFor(cloudType: cloudType)
            }else{
                boxAuthenticate()
            }
        default:
            break
        }
    }
    
    //MARK: clouds delegates
    func serviceAuthenticated(appType: ShareAppType, succes: Bool) {
        setButtonTitleFor(cloudType: appType)
    }
    
    func uploadDidFinish() {
        
    }
    
    func uploadDidStart() {
        
    }
}
