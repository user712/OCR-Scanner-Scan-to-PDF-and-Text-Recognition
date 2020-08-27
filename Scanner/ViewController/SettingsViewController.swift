//
//  SettingsViewController.swift
//  Scanner
//
//   on 1/25/17.
//   
//

import Foundation
import UIKit
import MessageUI


class SettingsViewController: UITableViewController, UserDefaultable {
    
    // MARK: - Properties
    
    fileprivate let section = ["App Settings".localized(), "Others".localized(), "Cloud services".localized()]
    fileprivate let items = [["Lock App".localized(), "Paper Size".localized()], ["Support".localized(), "Rate App".localized(), "Share App".localized()], ["Dropbox".localized(), "Evernote".localized(), "Google Диск".localized(), "Box".localized(), "One Drive".localized()]]
    
    fileprivate let cellID = "SettingsCell"
    
    fileprivate lazy var cancelButton: UIBarButtonItem =  {
        return UIBarButtonItem(image: UIImage(named: "shape"), style: .plain, target: self, action: #selector(cancelTapped(_:)))
    }()
    
    fileprivate lazy var doneButton: UIBarButtonItem =  {
        return  UIBarButtonItem(image: UIImage(named: "select"), style: .plain, target: self, action: #selector(doneTapped(_:)))
    }()
    
    fileprivate var selectedPaperRow: Int!
    
    
    // MARK: - LyfeCicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(SettingsCloudCell.self, forCellReuseIdentifier: SettingsCloudCell.identifier)
        tableView.register(UINib(nibName: SettingsCloudCell.identifier, bundle: nil), forCellReuseIdentifier: SettingsCloudCell.identifier)
        
        /// Hide empty cells
        self.tableView.hideEmptyCells(UIColor.white)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        self.navigationItem.title = "Settings".localized()
        setCustomColoredNavigationBarTitle()
        
//        navigationItem.setLeftBarButton(cancelButton, animated: true)
        navigationItem.setRightBarButton(doneButton, animated: true)
        
        if self.userDefaultsGetValue(userDefaultsPaperSizeKey) == nil {
            self.userDefaultsSaveValue(3, key: userDefaultsPaperSizeKey)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    
    // MARK: - Deinitializers
    
    deinit {
        selectedPaperRow = nil
    }
}


// MARK: - Table view data source

extension SettingsViewController: Passcodeable, PaperSizeable {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return section.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.items[section].count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return self.section[section]
        return " "
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCloudCell.identifier, for: indexPath) as! SettingsCloudCell
            switch indexPath.row {
            case 0:
                cell.cloudType = .dropBox
            case 1:
                cell.cloudType = .googleDrive
            case 2:
                cell.cloudType = .evernote
            case 3:
                cell.cloudType = .yandexDisk
            case 4:
                cell.cloudType = .box
            default:
                break
            }
            
            cell.parrentController = self
            return cell
        }
        
        let cell = UITableViewCell(style: .value1, reuseIdentifier: cellID)
        
        cell.selectionStyle = .none
        
        cell.textLabel?.text = self.items[indexPath.section][indexPath.row]
        cell.textLabel?.font = UIFont.textStyleFontLight(18)
        cell.textLabel?.text?.addTextSpacing(-0.6)
        cell.textLabel?.textColor = UIColor.gri
        cell.accessoryType = .disclosureIndicator
        
        cell.detailTextLabel?.font = UIFont.textStyleFontRegular(18)
        cell.detailTextLabel?.text?.addTextSpacing(-0.6)
        cell.detailTextLabel?.textColor = UIColor.tableViewLayer
        
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            cell.detailTextLabel?.text = self.configuration.repository.hasPasscode ? "On".localized() : "Off".localized()
        case (0, 1):
            if self.userDefaultsGetValue(userDefaultsPaperSizeKey) == nil {
                cell.detailTextLabel?.text = "A3"
            } else {
                if let index = self.userDefaultsGetValue(userDefaultsPaperSizeKey) as? Int {
                    cell.detailTextLabel?.text = paperSizesShort[index] /// 3 Default A3
                }
            }
        default:
            break
        }
        
        return cell
    }
}


// MARK: - Table view delegate

extension SettingsViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /// Show
        
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
//            let configuration = PasscodeLockConfiguration()
            let passwordViewController = PasscodeSettingsViewController() ///(configuration: configuration)
            passwordViewController.navigationItem.title = "App password".localized()
            
            switch deviceType {
            case .pad:
                passwordViewController.modalPresentationStyle = .formSheet
                passwordViewController.modalTransitionStyle = .crossDissolve
                self.navigationController?.pushViewController(passwordViewController, animated: true)
            default:
                self.navigationController?.pushViewController(passwordViewController, animated: true)
            }
            
        case (0, 1):
            let paperSizeController = PaperSizeViewController()
            paperSizeController.navigationItem.title = "Select Paper Size".localized()
            
            switch deviceType {
            case .pad:
                paperSizeController.modalPresentationStyle = .formSheet
                paperSizeController.modalTransitionStyle = .crossDissolve
                self.navigationController?.pushViewController(paperSizeController, animated: true)
            default:
                self.navigationController?.pushViewController(paperSizeController, animated: true)
            }
            
        case (1, 0):
            let mailComposeViewController = configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.present(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showSendMailErrorAlert()
            }
            
        case (1, 1):
            if let appLink = AppInfo.sharedManager().redirectStoreAppLink(){
                UIApplication.shared.openURL(URL(string: appLink)!)
            }
        case (1, 2):
            if let appUrl = AppInfo.sharedManager().shortAppURL(){
                let activityVC = UIActivityViewController(activityItems: ["checkOutAppMessageKey".localized(), appUrl], applicationActivities: nil)
                if deviceType == .pad {
                    activityVC.popoverPresentationController?.sourceView = self.view
                    activityVC.popoverPresentationController?.sourceRect = self.view.frame
                }
                
                present(activityVC, animated: true, completion: nil)
            }
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52.0
    }
    
    private func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["support@nordicnations.net"])
        mailComposerVC.setSubject("Customer support".localized())
        
        let currentVersion = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey! as String) as! String
        let appName = Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey! as String) as! String
        
        mailComposerVC.setMessageBody("********************\nDevice: \(UIDevice.current.modelName)\nModel: \(Utilities.systemVersion())\nApplication Version: \(String(describing: currentVersion))\nApplication Name: \(String(describing: appName))\n\n********************", isHTML: false)
        
        return mailComposerVC
    }
    
    private func showSendMailErrorAlert() {
        if Utilities.isSystemVersionLessThan( "8.0") {
            let alert = UIAlertView(title: "warningKey".localized(), message: "emailFailSendingKey".localized(), delegate: nil, cancelButtonTitle: "OK".localized(), otherButtonTitles: "")
            alert.show()
        } else {
            let alertController = UIAlertController(title: "warningKey".localized(), message: "emailFailSendingKey".localized(), preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default, handler: nil))
            
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismiss(animated: true, completion: nil)
    }
}


// MARK: - IBAction's

extension SettingsViewController {
    
    @objc fileprivate func cancelTapped(_ button: UIBarButtonItem) {
        dismissCurrentController()
    }
    
    @objc fileprivate func doneTapped(_ button: UIBarButtonItem) {
        dismissCurrentController()
    }
    
    fileprivate func dismissCurrentController() {
        self.dismiss(animated: true, completion: nil)
    }
}
