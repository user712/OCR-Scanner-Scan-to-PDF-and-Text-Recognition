//
//  InfoMessageLauncher.swift
//  Scanner
//
//   on 1/20/17.
//   
//

import UIKit
import SVProgressHUD


typealias AnimationCompletion = (Bool) -> ()

protocol InfoMessageLauncherDelegate: class {
    func cancelTapped()
}

class InfoMessageLauncher: NSObject {
    
    // MARK: - Properties
    
    weak var delegate: InfoMessageLauncherDelegate?
    
    fileprivate static var isPresented = false
    
    fileprivate var onController: UIViewController?
    
    fileprivate lazy var blackView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.alpha = 0.0
        if let mainView = self.onController?.view {
            view.frame = mainView.frame
        }else{
            view.frame = UIScreen.main.bounds
        }
        
        return view
    }()
    
    fileprivate let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel".localized(), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 22)
        button.titleLabel?.textColor = UIColor.darkSkyBlue
        button.backgroundColor = UIColor.rgb(red: 245.0, green: 245.0, blue: 247.0, alpha: 1.0)
        button.layer.cornerRadius = 4.0
        
        return button
    }()
    
    
    fileprivate lazy var centerContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.alpha = 0.0
        
        return view
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Light", size: 22)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = UIColor.rgb(red: 245.0, green: 245.0, blue: 247.0, alpha: 1.0)
        label.text = "Recognition".localized()
        
        return label
    }()
    
    fileprivate var counter = 0
    fileprivate var isAnimationFinished = false
    fileprivate var animationCompletion: AnimationCompletion?
    fileprivate var progressTimmer: Float = 0.0
    
    // MARK: - Initializers
    
    override init() {
        super.init()
    }
    
    
    // MARK: - Deinitializers
    
    deinit {
        animationCompletion = nil
        delegate = nil
    }
}


// MARK: - Show&Hide View

extension InfoMessageLauncher {
    
    func showAction(onController: UIViewController) {
        if InfoMessageLauncher.isPresented == true {
            return
        }
        
        self.onController = onController
        /// 1
        onController.navigationController?.view.addSubview(blackView)
        onController.navigationController?.view.addSubview(cancelButton)
        onController.navigationController?.view.addSubview(centerContainerView)
        
        ///
        
        SVProgressHUD.setContainerView(blackView)
        SVProgressHUD.setForegroundColor(UIColor.rgb(red: 38.0, green: 128.0, blue: 228.0, alpha: 1.0))
        SVProgressHUD.setRingThickness(5)
        SVProgressHUD.show()
        
        centerContainerView.addSubview(nameLabel)
        
        ///
        centerContainerView.frame = CGRect(x: 0, y: 0, width: 158, height: 173)
        centerContainerView.center = onController.view.center
        
        nameLabel.frame = CGRect(x: 0, y: centerContainerView.frame.height - 26*2, width: centerContainerView.frame.width, height: 26)
        
        /// 2
        cancelButton.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        
        /// 3
        let margin: CGFloat = 7.0
        let contHeight: CGFloat = 60.0
        let contY = (onController.view.frame.height - contHeight) - margin
        
        /// 4
        self.cancelButton.frame = CGRect(x: margin, y: onController.view.frame.height, width: onController.view.frame.width - (margin * 2), height: contHeight)
        
        
        /// 5
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { [unowned self] in
            self.blackView.alpha = 1.0
            self.centerContainerView.alpha = 1.0
            self.nameLabel.alpha = 1.0
            
            self.cancelButton.frame = CGRect(x: margin, y: contY, width: self.cancelButton.frame.width, height: self.cancelButton.frame.height)
        }, completion: nil)
        
        InfoMessageLauncher.isPresented = true
    }
    
    func handleDismiss() {
        InfoMessageLauncher.isPresented = false
        self.delegate?.cancelTapped()
        self.hideAnimation()
    }
    
    func hideAnimation() {
        SVProgressHUD.dismiss()
        InfoMessageLauncher.isPresented = false
        UIView.animate(withDuration: 0.5) {
            self.blackView.alpha = 0.0
            self.centerContainerView.alpha = 0.0
            self.nameLabel.alpha = 0.0
            if let mainView = self.onController?.view{
                self.cancelButton.frame = CGRect(x: 7, y: mainView.frame.height, width: self.cancelButton.frame.width, height: self.cancelButton.frame.height)
            }else{
                self.cancelButton.frame = CGRect(x: 7, y: UIScreen.main.bounds.height, width: self.cancelButton.frame.width, height: self.cancelButton.frame.height)
            }
        }
    }
}
