//
//  AlertController.swift
//  iScanner
//

import UIKit

class AlertController: UIAlertController {
    
    // MARK: - Properties
    
    
    
    // MARK: - LyfeCicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


// MARK: - Show alerts Methods

extension AlertController {
    
    class func showCancelAlertController(_ title: String?, message: String?, target: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert);
        let cancelAction = UIAlertAction(title: "OK".localized(), style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        target.present(alertController, animated: true, completion: nil)
    }
    
    class func showCancelAlertControllerWithBlock(_ title: String, message: String, target: UIViewController, actionHandler: @escaping (_ action: UIAlertAction) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK".localized(), style: .cancel, handler: { (action) in
            actionHandler(action)
        }))
        
        target.present(alertController, animated: true, completion: nil)
    }
    
    class func showChooseAlertControllerWithBlock(_ title: String?, message: String?, target: UIViewController, actionHandler: @escaping (_ action: UIAlertAction) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "OK".localized(), style: .destructive, handler: { (action) in
            actionHandler(action)
        }))
        
        target.present(alertController, animated: true, completion: nil)
    }
}
