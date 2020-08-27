//
//  PreviewManager.swift
//  Scanner
//
// 
//   
//

import UIKit
import WebKit
import Foundation
import QuickLook

class PreviewManager: NSObject {
    
    // MARK: - Properties
    
    var quickLookPreviewController: QLPreviewController!
    
    var fileURL: URL?
    
    
    // MARK: - Initializers
    
    func initWithFile(_ fileURL: URL) {
        self.fileURL = fileURL
    }
}


// MARK: - QLPreviewControllerDataSource

extension PreviewManager: QLPreviewControllerDataSource {
    
    func previewViewControllerForFile(_ fileURL: URL, fromNavigation: Bool) -> UIViewController {
        if fileURL.pathExtension == "plist" || fileURL.pathExtension == "json" {
            let webviewPreviewViewContoller = WebviewPreviewViewContoller()
            webviewPreviewViewContoller.fileURL = fileURL
            
            return webviewPreviewViewContoller
            
        } else {
            let previewTransitionViewController = PreviewTransitionViewController()
            previewTransitionViewController.quickLookPreviewController.dataSource = self
            
            self.fileURL = fileURL
            if fromNavigation == true {
                return previewTransitionViewController.quickLookPreviewController
            }
            
            return previewTransitionViewController
        }
    }
    
    func previewViewControllerForFileFromNavigation() -> UIViewController {
        let previewTransitionViewController = PreviewTransitionViewController()
        previewTransitionViewController.quickLookPreviewController.dataSource = self
        self.quickLookPreviewController = previewTransitionViewController.quickLookPreviewController
        
        return previewTransitionViewController.quickLookPreviewController
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        let item = PreviewItem()
        
        if let fileURL = fileURL {
            item.filePath = fileURL
        }
        
        return item
    }
}


/// Preview Transition View Controller was created because of a bug in QLPreviewController. It seems that QLPreviewController has issues being presented from a 3D touch peek-pop gesture and is produced an unbalanced presentation warning. By wrapping it in a container, we are solving this issue.
class PreviewTransitionViewController: UIViewController {
    
    // MARK: - Properties
    
    let quickLookPreviewController = QLPreviewController()
    
    
    // MARK: - LyfeCicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addChildViewController(quickLookPreviewController)
        self.view.addSubview(quickLookPreviewController.view)
        
        quickLookPreviewController.view.frame = view.bounds
        quickLookPreviewController.didMove(toParentViewController: self)
    }
}


/// Webview for rendering items QuickLook will struggle with.
class WebviewPreviewViewContoller: UIViewController {
    
    // MARK: - Properties
    
    var webView = WKWebView()
    
    var fileURL: URL? {
        didSet {
            self.title = fileURL?.lastPathComponent
            self.processForDisplay()
        }
    }
    
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(webView)
        
        // Add share button
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(WebviewPreviewViewContoller.shareFile))
        self.navigationItem.rightBarButtonItem = shareButton
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        webView.frame = self.view.bounds
    }
    
    func reload() {
        webView.reload()
    }
}


// MARK: - Helper Methods

extension WebviewPreviewViewContoller {
    
    // MARK: - Share
    
    func shareFile() {
        guard let fileURL = fileURL else {
            return
        }
        let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
        
    }
    
    
    // MARK: - Processing
    
    func processForDisplay() {
        guard let fileURL = fileURL, let data = try? Data(contentsOf: fileURL) else {
            return
        }
        
        var rawString: String?
        
        /// Prepare plist for display
        if fileURL.pathExtension == "plist" {
            do {
                if let plistDescription = try (PropertyListSerialization.propertyList(from: data, options: [], format: nil) as AnyObject).description {
                    rawString = plistDescription
                }
            } catch {}
            
        } else if fileURL.pathExtension == "json" {
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                if JSONSerialization.isValidJSONObject(jsonObject) {
                    let prettyJSON = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
                    var jsonString = String(data: prettyJSON, encoding: String.Encoding.utf8)
                    // Unescape forward slashes
                    jsonString = jsonString?.replacingOccurrences(of: "\\/", with: "/")
                    rawString = jsonString
                }
            } catch {}
        }
        
        // Default prepare for display
        if rawString == nil {
            rawString = String(data: data, encoding: String.Encoding.utf8)
        }
        
        // Convert and display string
        if let convertedString = convertSpecialCharacters(rawString) {
            let htmlString = "<html><head><meta name='viewport' content='initial-scale=1.0, user-scalable=no'></head><body><pre>\(convertedString)</pre></body></html>"
            webView.loadHTMLString(htmlString, baseURL: nil)
        }
        
    }
    
    // Make sure we convert HTML special characters
    // Code from https://gist.github.com/mikesteele/70ae98d04fdc35cb1d5f
    func convertSpecialCharacters(_ string: String?) -> String? {
        guard let string = string else {
            return nil
        }
        var newString = string
        let char_dictionary = [
            "&amp;": "&",
            "&lt;": "<",
            "&gt;": ">",
            "&quot;": "\"",
            "&apos;": "'"
        ];
        for (escaped_char, unescaped_char) in char_dictionary {
            newString = newString.replacingOccurrences(of: escaped_char, with: unescaped_char, options: NSString.CompareOptions.regularExpression, range: nil)
        }
        
        return newString
    }
}
