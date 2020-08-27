//
//  Contenteable.swift
//  Scanner
//
//   on 1/17/17.
//   
//

import UIKit

typealias PathCompletion = (String) -> ()

protocol Contenteable: Fileable {
    var files: [File] { get set }
    var checkedURLPaths: Set<File> { get set }
    
    func createFolderWithName(_ name: String, message: String, actionButtonTitle: String, forController viewController: UIViewController, appendPathCompletion: @escaping PathCompletion)
    func removeContensPath(_ contents: inout [File], withCheckedURLPathSet checkedURLPath: inout Set<File>, andCollectionView collectionView: UICollectionView)
}


extension Contenteable {
    /* Original Do not delete
    func createFolderWithName(_ name: String, message: String, actionButtonTitle: String, fileStatus: FileStatusType, inputTextField: UITextField?, forController viewController: UIViewController,
                              appendPathCompletion: @escaping PathCompletion) {
        var inputTextField = inputTextField
        let createFolderPromptAlertController = UIAlertController(title: name, message: message, preferredStyle: UIAlertControllerStyle.alert)
        createFolderPromptAlertController.addAction(UIAlertAction(title: "Cancel".localized(), style: UIAlertActionStyle.default, handler: nil))
        createFolderPromptAlertController.addTextField(configurationHandler: { (textField: UITextField!) in
            
            let text = self.setTextfieldPlaceholderName(self.loadFolders())
            textField.placeholder = text
            inputTextField = textField
        })
        
        createFolderPromptAlertController.addAction(UIAlertAction(title: actionButtonTitle, style: .default, handler: { action -> Void in
            if let isEmpty = inputTextField?.text?.isEmpty, isEmpty == true {
                let text = self.setTextfieldPlaceholderName(self.loadFolders())
                
                switch fileStatus {
                case .create:
                    appendPathCompletion(text)
                case .delete:
                    print("delete")
                }
                
            } else {
                switch fileStatus {
                case .create:
                    if let folderName = inputTextField?.text {
                        appendPathCompletion(folderName)
                    }
                case .delete:
                    print("delete")
                }
            }
            
        }))
        viewController.present(createFolderPromptAlertController, animated: true, completion: nil)
    }*/

    func createFolderWithName(_ name: String, message: String, actionButtonTitle: String, forController viewController: UIViewController,
                              appendPathCompletion: @escaping PathCompletion) {
        let alertController = UIAlertController(title: name, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Cancel".localized(), style: UIAlertActionStyle.default, handler: nil))
        alertController.addTextField(configurationHandler: { (textField: UITextField!) in
            
            textField.placeholder = "Folder"
            textField.clearButtonMode = .always
        })
        
        alertController.addAction(UIAlertAction(title: actionButtonTitle, style: .default, handler: { action -> Void in
            if let textfield = alertController.textFields?.first {
                if let isEmpty = textfield.text?.isEmpty, isEmpty == true {
                    appendPathCompletion("Folder")
                } else {
                    if let folderName = textfield.text {
                        appendPathCompletion(folderName)
                    }
                }
            }
        }))
        
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Incrementing folder name
    
    /// ----------- Methods for incrementing folders starts ----------------- ///
    private func loadFolders() -> [String] {
        
        var onlyNewFoldersName = [String]()
        
        if let initialPath = initialPath, let contents = self.getItemsAtPath(initialPath) {
            for path in contents {
                if path.lastPathComponent.hasPrefix("New".localized()) && path.isDirectory {
                    onlyNewFoldersName.append(path.lastPathComponent)
                }
            }
        }
        
        return onlyNewFoldersName
    }
    
    private func getNumberOfFolderForTextfield() -> [Int] {
        let folders = loadFolders()
        var tempArrayOfIntegers = Set<Int>()
        var extensionNumbersOfFoldersPathArray = Set<Int>()
        
        for (index, value) in folders.enumerated() {
            tempArrayOfIntegers.insert(index)
            let customArray = value.components(separatedBy: "Folder".localized() + " ")
            if customArray.count > 1 {
                if let value = Int(customArray[1]) {
                    extensionNumbersOfFoldersPathArray.insert(value)
                }
            }
        }
        
        /// Finding missing number in set
        return tempArrayOfIntegers.subtracting(extensionNumbersOfFoldersPathArray).sorted()
    }
    
    private func setTextfieldPlaceholderName(_ folders: [String]) -> String {
        let newFolderZero = "New Folder".localized()
        guard let initialPath = initialPath else { return "Folder name".localized() }
        let newFolder = initialPath.appendingPathComponent(newFolderZero)
        var missingNumbers = getNumberOfFolderForTextfield()
        
        if !filesManager.fileExists(atPath: newFolder.path) {
            return newFolderZero
        }
        
        if missingNumbers.isEmpty {
            return "\(newFolderZero) \(folders.count)"
        } else {
            if missingNumbers.count > 1 {
                if let firstNumber = missingNumbers.first, firstNumber == 0 {
                    missingNumbers.removeFirst()
                }
                return "\(newFolderZero) \(missingNumbers.first!)" /// Unwrap value
            } else {
                return "\(newFolderZero) \(folders.count)"
            }
        }
    }
    
    /// ----------- Methods for incrementing folders ends ----------------- ///
}



extension Contenteable {
    
    func removeContensPath(_ contents: inout [File], withCheckedURLPathSet checkedURLPath: inout Set<File>, andCollectionView collectionView: UICollectionView) {
        for (_, filePath) in checkedURLPath.enumerated() {
            for (index, file) in contents.enumerated() {
                
                if file.filePath == filePath.filePath {
                    contents.remove(at: index)
                    
                    self.remove(fileAtPath: filePath.filePath)
                    checkedURLPath.remove(filePath)
                    
                    if let thumbnailURL = filePath.thumbnailURL {
                        
                        do {
                            try filesManager.removeItem(at: thumbnailURL)
                        } catch {
                            print("Cannot remove \(thumbnailURL), error \(error)")
                        }
                    }
                    
                    collectionView.reloadData()
                }
            }
        }
    }
}


extension Contenteable {
    
    func removeContensPath(_ contents: [File], checkedURLPath: Set<File>, collectionView: UICollectionView, viewController: UIViewController) {
        var contents = contents
        var checkedURLPath = checkedURLPath
        
        let alertController = UIAlertController(title: "Are you sure?",
                                                message: "Selected file(s) will be deleted permanently!".localized(), preferredStyle: .alert)
        
        let destructiveAction = UIAlertAction(title: "Cancel".localized(), style: .destructive) {
            (result : UIAlertAction) -> Void in
            
        }
        
        // Replace UIAlertActionStyle.Default by UIAlertActionStyle.default
        let okAction = UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default) { (result : UIAlertAction) in
            for (_, filePath) in checkedURLPath.enumerated() {
                for (index, file) in contents.enumerated() {
                    
                    if file.filePath == filePath.filePath {
                        contents.remove(at: index)
                        
                        self.remove(fileAtPath: filePath.filePath)
                        checkedURLPath.remove(filePath)
                        
                        if let thumbnailURL = filePath.thumbnailURL {
                            
                            do {
                                try FileManager.default.removeItem(at: thumbnailURL)
                            } catch {
                                print("Cannot remove \(thumbnailURL), error \(error)")
                            }
                        }
                        
                        collectionView.reloadData()
                    }
                }
            }
        }
        
        alertController.addAction(destructiveAction)
        alertController.addAction(okAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
}
