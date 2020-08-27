//
//  ClassViewController.swift
//  Scanner
//
//   on 2/27/17.
//   
//

import UIKit

class ClassViewController: UIViewController, UserDefaultable, Fileable {

    // MARK: - Properties
    
    var initialPath: URL?
    var ocrManager: OCRManager?
    fileprivate var filePDFController: UIViewController!
    fileprivate var previewManager: PreviewManager!
    var filePath: URL!
    fileprivate var infoLaucher: InfoMessageLauncher!
    fileprivate var progressPDFCounter = 0
    
    
    // MARK: - LyfeCicle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    fileprivate func askRescanAction(_ pdfURL: URL, ocrLanguage: String) {
        let alertController = UIAlertController(title: "Recognition".localized(),
                                                message: nil, preferredStyle: .alert)
        
        let destructiveAction = UIAlertAction(title: "Cancel".localized(), style: .destructive) { [unowned self] (result : UIAlertAction) in
            self.ocrManager?.stopOCR()
        }
        
        let okAction = UIAlertAction(title: "Rescan".localized(), style: .default) { (result : UIAlertAction) in
            try? self.filesManager.removeItem(at: pdfURL)
            self.startOCRPDFSession(pdfURL, ocrLanguage: ocrLanguage)
        }
        
        alertController.addAction(destructiveAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func openPreviewPDFController() {
        self.filePDFController.view.alpha = 1.0
        self.view.addSubview(self.filePDFController.view)
        self.addChildViewController(self.filePDFController)
        self.filePDFController.didMove(toParentViewController: self)
    }
    
    fileprivate func startOCRPDFSession(_ pdfURL: URL, ocrLanguage: String) {
        self.addPDFQuikLookController(self.filePath)
        self.userDefaultsSetBoolValueForKey(false, key: self.filePath.lastPathComponent)
        
        if !filesManager.fileExists(atPath: pdfURL.path) {
            self.infoLaucher.showAction(onController: self)
            
            self.createOCRPDFs(ocrLanguage, pdfURL: pdfURL) { [unowned self] in
                UIView.animate(withDuration: 0.25) { [unowned self] in
                    self.infoLaucher.hideAnimation()
                    self.progressPDFCounter = 0
                    self.previewManager.fileURL = pdfURL
                    self.openPreviewPDFController()
                }
            }
            
        } else {
            /// Open PDF
            
            UIView.animate(withDuration: 0.25) { [unowned self] in
                self.openPreviewPDFController()
            }
        }
    }
    
    fileprivate func createContinueRecognitionAction(_ pdfURL: URL, ocrLanguage: String) {
        self.addPDFQuikLookController(self.filePath)
        let alertController = UIAlertController(title: "Recognition was aborted".localized(), message: nil, preferredStyle: .alert)
        
        let destructiveAction = UIAlertAction(title: "Cancel".localized(), style: .destructive) { [unowned self] (result : UIAlertAction) in
            UIView.animate(withDuration: 0.25) { [unowned self] in
                self.openPreviewPDFController()
            }
        }
        
        let okAction = UIAlertAction(title: "Rescan".localized(), style: .default) { (result : UIAlertAction) in
            try? self.filesManager.removeItem(at: pdfURL)
            self.startOCRPDFSession(pdfURL, ocrLanguage: ocrLanguage)
        }
        
        UIView.animate(withDuration: 0.25) { [unowned self] in
            self.openPreviewPDFController()
        }
        
        alertController.addAction(destructiveAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }

    fileprivate func addPDFQuikLookController(_ fileURL: URL) {
        let initialURL = fileURL.deletingLastPathComponent()
        let pdfURL = initialURL.appendingPathComponent(Constants.OriginalImageFolderName).appendingPathComponent(self.filePath.lastPathComponent)
        filePDFController = previewManager.previewViewControllerForFile(pdfURL, fromNavigation: true)
        filePDFController.view.frame = CGRect(x: 0, y: 64.0, width: self.view.frame.width, height: self.view.frame.height - 108)
        filePDFController.view.alpha = 0.0
    }
    
    fileprivate func createOCRPDFs(_ language: String, pdfURL: URL, completion: @escaping () -> ()) {
        
    }
}
