//
//  PasscodeSettingsViewController.swift
//  Scanner
//
//   on 1/25/17.
//   
//

import UIKit

class PasscodeSettingsViewController: UITableViewController {

    // MARK: - Properties
    
    fileprivate lazy var configuration: PasscodeLockConfigurationType =  {
        let repository = KeychainPasscodeRepository()
        var configuration = PasscodeLockConfiguration(repository: repository)
        
        return configuration
    }()
    
    fileprivate let cellID = "PasscodeCell"
    fileprivate var passcodeSwitch: UISwitch?
    
    
    // MARK: - LyfeCicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.rgb(red: 245, green: 245, blue: 247, alpha: 1)
        tableView.register(PasswordTableViewCell.self, forCellReuseIdentifier: PasswordTableViewCell.reuseIdentifier)
        tableView.hideEmptyCells(UIColor.rgb(red: 245, green: 245, blue: 247, alpha: 1))
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}


// MARK: - Table view data source

extension PasscodeSettingsViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PasswordTableViewCell.reuseIdentifier, for: indexPath) as! PasswordTableViewCell
        
        // Configure the cell...
        cell.selectionStyle = .none
        cell.passDelegate = self
        
        return cell
    }
}

// MARK: - Table view delegate

extension PasscodeSettingsViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52.0
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let customView = UIView(frame: tableView.bounds)
        let label = UILabel(frame: CGRect(x: 20, y: 0, width: self.view.frame.width - 40, height: 60))
        label.text = "With this option you can lock with passcode your app".localized()
        label.numberOfLines = 2
        label.font = UIFont.textStyleFontLight(18)
        label.text?.addTextSpacing(-0.6)
        label.textColor = UIColor.rgb(red: 183, green: 183, blue: 183, alpha: 1)
        customView.addSubview(label)
        
        return customView
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 60.0
    }
}


// MARK: - PasswordTableViewCellDelegate

extension PasscodeSettingsViewController: PasswordTableViewCellDelegate {
   
    internal func passcodeSwitchValueChange(_ sender: UISwitch) {
        self.passcodeSwitch = sender
        
        let passcodeVC: PasscodeLockViewController
        
        if sender.isOn {
            passcodeVC = PasscodeLockViewController(state: PasscodeLockViewController.LockState.setPasscode, configuration: configuration)
        } else {
            passcodeVC = PasscodeLockViewController(state: PasscodeLockViewController.LockState.removePasscode, configuration: configuration)
            passcodeVC.successCallback = { lock in
                lock.repository.deletePasscode()
                passcodeVC.dismiss(animated: true, completion: nil)
            }
        }
        
        switch deviceType {
        case .pad:
            passcodeVC.modalPresentationStyle = .formSheet
            passcodeVC.modalTransitionStyle = .crossDissolve
            self.present(passcodeVC, animated: true, completion: nil)
        default:
            self.present(passcodeVC, animated: true, completion: nil)
        }
        
        passcodeVC.dismissCompletionCallback = { [unowned self] in
            self.passcodeSwitch?.isOn = false
        }
    }
}
