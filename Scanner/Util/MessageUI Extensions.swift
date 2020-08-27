//
//  MessageUI Extensions.swift
//  Scanner
//
//   
//   
//

import MessageUI

extension MFMailComposeViewController {
    
    var mimeTypePDF: String {
        return "application/pdf"
    }
    
    var mimeTypePNG: String {
        return "image/png"
    }
    
    var mimeTypeDOC: String {
        return "doc"
    }
    
    var mimeTypeHTML: String {
        return "html"
    }
    
    var mimeTypeJPEG: String {
        return "image/jpeg"
    }
}

extension MFMailComposeViewController {
    
    func getData(_ fromURL: URL) -> Data? {
        do {
            return try Data(contentsOf: fromURL)
        } catch {
            print("Cannot get data from URL, error = \(error.localizedDescription)")
        }
        
        return nil
    }
}


extension MFMailComposeViewController {
    
    func addAttachmentFromPath(_ path: URL) {
        if let dataFromURL = self.getData(path) {
            if path.isPDF {
                self.addAttachmentData(dataFromURL, mimeType: self.mimeTypePDF, fileName: path.lastPathComponent)
            } else if path.isJPG {
                self.addAttachmentData(dataFromURL, mimeType: self.mimeTypeJPEG, fileName: path.lastPathComponent)
            }  else if path.isPNG {
                self.addAttachmentData(dataFromURL, mimeType: self.mimeTypePNG, fileName: path.lastPathComponent)
            }
        }
    }
}



// MARK: - MFMailComposeViewControllerDelegate

extension UIViewController: MFMailComposeViewControllerDelegate {
    
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        switch result {
        case .cancelled:
            print("Mail cancelled")
            
        case .saved:
            print("Mail saved")
            
        case .sent:
            print("Mail sent")
            
        case .failed:
            print("Mail sent failure: \(String(describing: error?.localizedDescription))")
            
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}
