//
//  Customizeable.swift
//  Scanner
//
//   on 1/19/17.
//   
//

import UIKit

protocol Customizeable {
    var shareButton: UIBarButtonItem { get set }
    var moveButton: UIBarButtonItem { get set }
    var mergeButton: UIBarButtonItem { get set }
    var deleteButton: UIBarButtonItem { get set }
    
    var backgroundImageView: UIImageView { get set }
    
    func checkToolbarButtonStatus(_ content: Contenteable)
    func isEnabledToolbarButtons(_ status: Bool)
    
    func showHideBackgroundImageOfCollectionView(_ content: Contenteable)
}



// MARK: - Deactivate all buttons on toolbar

extension Customizeable {
    
    func checkToolbarButtonStatus(_ content: Contenteable) {
        // Deactivate all buttons
        self.isEnabledToolbarButtons(false)

        if content.checkedURLPaths.count == 0 {
            self.isEnabledToolbarButtons(false)
            
        } else {
            var isFolderContain = false
            
            for path in content.checkedURLPaths {
                if path.isDirectory {
                    isFolderContain = true
                    break
                }
            }
            
            if isFolderContain {
                self.isEnabledFirstThreeToolbarButtons(false)
            } else {
                var isPDFContain = false
                for path in content.checkedURLPaths {
                    if path.filePath.isPDF {
                        isPDFContain = true
                        break
                    }
                }
                
                if isPDFContain {
                    disablePDFButton(true)
                } else {
                    self.isSelectedMoreTwoImagesForPDFMerge(content)
                }
            }
        }
    }
    
    func isEnabledToolbarButtons(_ status: Bool) {
        self.mergeButton.isEnabled = status
        self.shareButton.isEnabled = status
        self.moveButton.isEnabled = status
        self.deleteButton.isEnabled = status
    }
    
    private func isEnabledFirstThreeToolbarButtons(_ status: Bool) {
        self.shareButton.isEnabled = status
        self.moveButton.isEnabled = true
        self.mergeButton.isEnabled = status
        self.deleteButton.isEnabled = true
    }
    
    private func disablePDFButton(_ status: Bool) {
        self.shareButton.isEnabled = status
        self.moveButton.isEnabled = status
        self.mergeButton.isEnabled = false
        self.deleteButton.isEnabled = status
    }
    
    private func isSelectedMoreTwoImagesForPDFMerge(_ content: Contenteable) {
        if content.checkedURLPaths.count >= 2 {
            let checkedURLPathsArray = content.checkedURLPaths.reversed()
            let firstImageURL = checkedURLPathsArray[0].filePath
            let secondImageURL = checkedURLPathsArray[1].filePath
            
            if (firstImageURL.isJPG || firstImageURL.isJPEG) && (secondImageURL.isJPG || secondImageURL.isJPEG) {
//                print(content.checkedURLPaths.count)
                self.isEnabledToolbarButtons(true)
            } else {
                self.isEnabledToolbarButtons(true)
            }
        } else {
            self.disablePDFButton(true)
        }
    }
}


extension Customizeable {
    
    func showHideBackgroundImageOfCollectionView(_ content: Contenteable) {
        if content.files.isEmpty {
            self.backgroundImageView.isHidden = false
        } else {
            self.backgroundImageView.isHidden = true
        }
    }
}
