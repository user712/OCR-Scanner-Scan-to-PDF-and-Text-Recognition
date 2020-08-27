//
//  ShareManager.swift
//  Scanner
//
//  
//   
//

import UIKit

class ShareManager {
    
    // MARK: - Properties
    
    static let `default` = ShareManager()
    
    fileprivate lazy var shareContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.alpha = 1.0
        view.frame = CGRect(x: 0, y: self.window.frame.height - 300, width: self.window.frame.width, height: 300)
        
        return view
    }()
    
    
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



extension ShareManager {
    
    func prepareShare() {
        print("share")
        
        window.addSubview(blackView)
        window.addSubview(shareContainerView)
        blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
        
        let contHeight: CGFloat = window.frame.height / 2 + 87 /// difference between superContainerView and blackView height
        let contY = window.frame.height - contHeight
        
        shareContainerView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: contHeight)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { [unowned self] in
            
            self.blackView.alpha = 1.0
            self.shareContainerView.frame = CGRect(x: 0, y: contY, width: self.shareContainerView.frame.width, height: self.shareContainerView.frame.height)
            }, completion: nil)
    }
    
    @objc func handleDismiss() {
        UIView.animate(withDuration: 0.5) { [unowned self] in
            self.blackView.alpha = 0.0
            self.shareContainerView.frame = CGRect(x: 0, y: self.window.frame.height, width: self.shareContainerView.frame.width, height: self.shareContainerView.frame.height)
        }
    }

}
