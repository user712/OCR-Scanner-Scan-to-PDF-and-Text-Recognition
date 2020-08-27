//
//  CloudShareable.swift
//  iScanner
//

import UIKit
import MessageUI
import Foundation

protocol CloudShareable: iCloudUploadable {
    var checkedURLPaths: Set<File> { get set }
    func managerApp(_ application: App?, inUIViewController controller: UIViewController, fromBarButtonItem barButtonItem: UIBarButtonItem?)
    func dismissShareController()
}


extension CloudShareable {
    
    func managerApp(_ application: App?, inUIViewController controller: UIViewController, fromBarButtonItem barButtonItem: UIBarButtonItem?) {
        if let application = application {
            switch application.type {
            case .eMail:
                print("1")
                self.shareToEmail(controller)
            case .eMailJPG:
                print("2")
                self.shareAsJPGToEmail(controller)
            case .openAs:
                print("3")
                if let barButtonItem = barButtonItem {
                    self.dismissShareController()
                    self.openAs(controller, barButtonItem: barButtonItem)
                }
            case .print:
                self.printer(controller)
            case .iCloud:
                self.iCloudAcces(controller)
            case .dropBox:
                self.dropBoxAcces(controller)
            case .googleDrive:
                self.googleDriveAcces(controller)
            case .evernote:
                self.evernoteAcces(controller)
            case .yandexDisk:
                self.yandexDiskAcces(controller)
            case .box:
                self.boxAcces(controller)
            case .none:
                print("Nothing to do)")
            }
        }
    }
}


// MARK: - #1 shareToEmail

extension CloudShareable {
    
    fileprivate func shareToEmail(_ controller: UIViewController) {
        let mailComposeController = MFMailComposeViewController()
        
        if MFMailComposeViewController.canSendMail() {
            mailComposeController.mailComposeDelegate = controller
            mailComposeController.setSubject("Have you heard about iScanner?".localized())
            mailComposeController.setMessageBody("Here is the link to get it from App Store".localized(), isHTML: false)
            
            for path in checkedURLPaths {
                mailComposeController.addAttachmentFromPath(path.filePath)
                print(path)
            }
            
            controller.present(mailComposeController, animated: true, completion: nil)
        }
    }
}


// MARK: - #2 shareAsJPGToEmail

extension CloudShareable {
    
    fileprivate func shareAsJPGToEmail(_ controller: UIViewController) {
        let mailComposeController = MFMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            mailComposeController.mailComposeDelegate = controller
            mailComposeController.setSubject("Have you heard about iScanner?".localized())
            mailComposeController.setMessageBody("This is what they sound like.".localized(), isHTML: false)
            
            
            for path in checkedURLPaths {
                
                if path.filePath.isPDF {
                    /// TODO: - Get pictures from pdf
                    //                mailComposeController.addAttachmentFromPath(path)
                } else if path.filePath.isPNG {
                    /// TODO: - Convert png to jpg
                    //                mailComposeController.addAttachmentFromPath(path)
                } else {
                    /// TODO: - Nothing to do
                }
                print(path)
            }
            
            switch deviceType {
            case .phone:
                controller.present(mailComposeController, animated: true, completion: nil)
                
            case .pad:
                controller.modalPresentationStyle = .formSheet
                controller.modalTransitionStyle = .crossDissolve
                controller.present(mailComposeController, animated: true, completion: nil)
            default:
                break
            }
        }
    }
}



// MARK: - #3 openAs

extension CloudShareable {
    
    fileprivate func openAs(_ controller: UIViewController, barButtonItem: UIBarButtonItem) {
        var imageToShare = [UIImage]()
        
        for path in checkedURLPaths {
            print(path)
            
            if !path.filePath.isPDF {
                if let image = path.filePath.toUIImage {
                    imageToShare.append(image)
                }
            }
        }
        
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.barButtonItem = barButtonItem
        controller.present(activityViewController, animated: true, completion: nil)
    }
}



// MARK: - #4 Printer

extension CloudShareable {
    
    fileprivate func printer(_ controller: UIViewController) {
        let printPaperSizeController = PrintPaperSizeViewController(checkedPaths: checkedURLPaths)
        let navigationController = UINavigationController(rootViewController: printPaperSizeController)
        
        switch deviceType {
        case .pad:
            navigationController.modalPresentationStyle = .formSheet
            navigationController.modalTransitionStyle = .crossDissolve
        default:
            break
        }
        
        controller.present(navigationController, animated: true, completion: nil)
    }
}


// MARK: - #5 iCloud

extension CloudShareable {
    
    func iCloudAcces(_ controller: UIViewController) {
        
        self.checkiCloudAviability { (succes) in
            if succes {
                for filePath in self.checkedURLPaths {
                    self.saveDocumentToiCloud(filePath.filePath)
                }
                ToastManager.main.makeToast(controller.view, message: "Saved".localized(), duration: 3.0, position: .center)
            } else {
                ToastManager.main.makeToast(controller.view, message: "Please Log in to iCloud".localized(), duration: 3.0, position: .center)
            }
        }
    }
}


// MARK: - #6 DropBox

extension CloudShareable {
    
    func dropBoxAcces(_ controller: UIViewController) {
        self.present(controller, withImageName: "dropBoxLarge", shareType: .dropBox)
    }
}


// MARK: - #7 Google Drive

extension CloudShareable {
    
    func googleDriveAcces(_ controller: UIViewController) {
        self.present(controller, withImageName: "gdriveLarge", shareType: .googleDrive)
    }
}


// MARK: - #8 Evernote

extension CloudShareable {
    
    func evernoteAcces(_ controller: UIViewController) {
        self.present(controller, withImageName: "evernoteLarge", shareType: .evernote)
    }
}


// MARK: - #9 Yandex Disk

extension CloudShareable {
    
    func yandexDiskAcces(_ controller: UIViewController) {
        self.present(controller, withImageName: "yandexLarge", shareType: .yandexDisk)
    }
}


// MARK: - #10 Box

extension CloudShareable {
    
    func boxAcces(_ controller: UIViewController) {
        self.present(controller, withImageName: "boxLarge", shareType: .box)
    }
}


// MARK: - General Share With Controllers

extension CloudShareable {
    
    fileprivate func present(_ controller: UIViewController, withImageName imageName: String, shareType: ShareAppType) {
        let cloudsController = CloudOAuthViewController()
        cloudsController.logoImage = UIImage(named: imageName)
        cloudsController.shareAppType = shareType
        cloudsController.checkedURLPaths = self.checkedURLPaths
        let navigationController = UINavigationController(rootViewController: cloudsController)
        
        switch deviceType {
        case .phone:
            controller.present(navigationController, animated: true, completion: nil)
        case .pad:
            navigationController.modalPresentationStyle = .formSheet
            navigationController.modalTransitionStyle = .crossDissolve
            controller.present(navigationController, animated: true, completion: nil)
        default:
            break
        }
    }
}
