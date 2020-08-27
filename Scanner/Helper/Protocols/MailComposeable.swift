//
//  MailComposeable.swift
//  Scanner
//
//   on 2/3/17.
//   
//

import UIKit
import MessageUI

protocol MailComposeable: MFMailComposeViewControllerDelegate, UIAlertViewDelegate {
    func sendMail(_ viewController: UIViewController)
}


extension MailComposeable {
    
    func sendMail(_ viewController: UIViewController) {
        self.sendMailWithBugsReportOrSuggestions(viewController)
    }
    
    func sendMailWithBugsReportOrSuggestions(_ viewController: UIViewController) {
        if MFMailComposeViewController.canSendMail() == false {
            showEmailNotSentAlert(viewController)
            
            return
        }
        
        let mailComposeViewController = MFMailComposeViewController()
        mailComposeViewController.mailComposeDelegate = self
//        mailComposeViewController.setToRecipients([AppOwnerEmail])
        mailComposeViewController.setSubject(Utilities.applicationName() + " " + "customerSupportKey".localized())
        
        let bodyMessage = (
            "***********************************\n" +
                "deviceModelKey".localized() + ": " + UIDevice.current.modelName + "\n" +
                "systemVersionKey".localized() + ": " + Utilities.systemVersion() + "\n" +
//                "appVersionKey".localized() + ": " + Utilities.applicationNameAndVersion() + "\n" +
            "***********************************")
        mailComposeViewController.setMessageBody(bodyMessage, isHTML: false)
        
        DispatchQueue.main.async {
            viewController.present(mailComposeViewController, animated: true, completion: nil)
        }
    }
    
//    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
//        showEmailNotSentAlert(controller)
        
//        controller.dismiss(animated: true, completion: nil)
//    }
    
    func showEmailNotSentAlert(_ viewController: UIViewController) {
        if Utilities.isSystemVersionLessThan( "8.0") {
            let alert = UIAlertView(title: "warningKey".localized(), message: "emailFailSendingKey".localized(), delegate: self, cancelButtonTitle: "OK".localized(), otherButtonTitles: "")
            alert.show()
        } else {
            let alertController = UIAlertController(title: "warningKey".localized(), message: "emailFailSendingKey".localized(), preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default, handler: nil))
            
            viewController.present(alertController, animated: true, completion: nil)
        }
    }
}
