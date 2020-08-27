//
//  PasswordTableViewCell.swift
//  Scanner
//
//  
//   
//

import UIKit

protocol PasswordTableViewCellDelegate: class {
    func passcodeSwitchValueChange(_ sender: UISwitch)
}

class PasswordTableViewCell: UITableViewCell, Passcodeable {

    // MARK: - Properties
    
    weak var passDelegate: PasswordTableViewCellDelegate?
    
    fileprivate lazy var nameLabel: UILabel = {
        let label = createLabel(UIColor.gri, font: UIFont.textStyleFontRegular(18), spacing: -0.6)
        label.textAlignment = .left
        label.text = "Password".localized()
        return label
    }()
    
    fileprivate lazy var passcodeSwitch: UISwitch = {
        let passSwitch = UISwitch()
        passSwitch.addTarget(self, action: #selector(passcodeSwitchValueChange(_:)), for: .valueChanged)
        passSwitch.isOn = self.configuration.repository.hasPasscode
        
        return passSwitch
    }()
    
    static let reuseIdentifier = "PasswordTableViewCell"
    
    
    // MARK: - Initializers
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
}


// MARK: - Setup Views

extension PasswordTableViewCell {
    
    func setupViews() {
        addSubview(nameLabel)
        addSubview(passcodeSwitch)
        
        addConstraintsWithFormat("H:|-20-[v0]-50-[v1(51)]-20-|", views: nameLabel, passcodeSwitch)
        
        addConstraintsWithFormat("V:|-15-[v0]-15-|", views: nameLabel)
        addConstraintsWithFormat("V:|-11-[v0]-11-|", views: passcodeSwitch)
    }
}


// MARK: - passcodeSwitchValueChange

extension PasswordTableViewCell {
    
    @objc fileprivate func passcodeSwitchValueChange(_ sender: UISwitch) {
        passDelegate?.passcodeSwitchValueChange(passcodeSwitch)
    }
}
