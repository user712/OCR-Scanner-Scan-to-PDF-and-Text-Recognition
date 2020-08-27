//
//  ShareLauncher.swift
//  Scanner
//
//   
//   
//

import UIKit

class ShareLauncher {

    // MARK: - Properties
    
    static let main = ShareLauncher()
    
    var shareContainerView: ShareViewController?
    
    fileprivate lazy var window: UIWindow = {
        guard let window = UIApplication.shared.keyWindow else { return UIWindow() }
        
        return window
    }()
    
    fileprivate lazy var blackView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.alpha = 0.0
        view.frame = self.window.frame
        
        return view
    }()
    
    
    // MARK: - Initializers
    
    private init() {}
}


extension ShareLauncher {
    
    func show() {
        if let shareContainerView = shareContainerView?.view {
            window.addSubview(blackView)
            window.addSubview(shareContainerView)
            
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            
            let contHeight: CGFloat = window.frame.height / 2 + 87 /// difference between superContainerView and blackView height
            let contY = window.frame.height - contHeight
            
            shareContainerView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: contHeight)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { [unowned self] in
                
                self.blackView.alpha = 1.0
                shareContainerView.frame = CGRect(x: 0, y: contY, width: shareContainerView.frame.width, height: shareContainerView.frame.height)
                }, completion: nil)
        }
    }
    
    @objc func handleDismiss() {
        if let shareContainerView = shareContainerView?.view {
            UIView.animate(withDuration: 0.5) { [unowned self] in
                self.blackView.alpha = 0.0
                shareContainerView.frame = CGRect(x: 0, y: self.window.frame.height, width: shareContainerView.frame.width, height: shareContainerView.frame.height)
            }
        }
    }
}
