//
//  ApplicationStarteable.swift
//  Scanner
//
//  
//   
//

import UIKit

protocol ApplicationStarteable: Fileable, Downloadable, UserDefaultable {
    func loadMainViewControllerWithInitialPath(andUIWindow window: inout UIWindow?)
}

extension ApplicationStarteable {
    
    func loadMainViewControllerWithInitialPath(andUIWindow window: inout UIWindow?) {
//        let theme = ThemeManager.currentTheme()
//        ThemeManager.applyTheme(theme)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.backgroundColor = .clear
        
        let mainController = MainViewController()
        mainController.initWithDirectoryPath(scannerURL)
        let navigationController = UINavigationController(rootViewController: mainController)
        window?.rootViewController = navigationController
        
        ///
        self.moveTessDataFolder()
    }
}



extension ApplicationStarteable {
    
    func downloadOCREnglishLanguage() {
        
        if !isFolderExistsAtPath(ocrTessDataURL) {
            do {
                try filesManager.createDirectory(at: ocrTessDataURL, withIntermediateDirectories: true, attributes: nil)
                let filePath = ocrTessDataURL.appendingPathComponent("eng.traineddata")
                if !filesManager.fileExists(atPath: filePath.path) {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                    self.userDefaultsSaveValue("eng", key: "ocr.downloaded.languages")
                    self.downloadLanguage(ocrTessDataURL, languageName: "eng", progressCompletion: { (bitDown, bitTotal) in
                        print(bitDown)
                        print(bitTotal)
                    }, downloadCompletion: { (success, error) in
                        if success {
                            print("eng downloaded")
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        }
                    })
                }
                
                print(ocrTessDataURL)
                print(filePath)
                
            } catch {
                print(error)
            }
        }
    }
}
