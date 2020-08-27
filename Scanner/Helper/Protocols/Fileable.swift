//
//  Fileable.swift
//  Scanner
//
//  
//   
//

import Foundation

private var _excludesFileExtensions = [String]()
private var excludesFilepaths: [URL]?

protocol Fileable: Dateable, PDFconvetible, UserDefaultable, Texteable {
    var filesManager: FileManager { get }
    var initialPath: URL? { get }
    var documentsURL: URL { get }
    var excludesFileExtensions: [String]? { get set }
    
    var scannerURL: URL { get }
    
    func getDate(_ attributes: [FileAttributeKey: Any]?) -> String
    func getOnlyDirectories(_ files: [File]) -> [File]
    func remove(fileAtPath path: URL)
}


extension Fileable {
    
    var filesManager: FileManager {
        return FileManager.default
    }
    
    var documentsURL: URL {
        return filesManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    var scannerURL: URL {
        let iFinderURL = documentsURL.appendingPathComponent("Scanner", isDirectory: true)
        /// Check if file not exist and create
        if !filesManager.fileExists(atPath: iFinderURL.path) {
            try? filesManager.createDirectory(at: iFinderURL, withIntermediateDirectories: true, attributes: nil)
        }
        
        return iFinderURL
    }
    
    var ocrTessDataURL: URL {
        return documentsURL.appendingPathComponent(".ocrLanguages/tessdata")
    }
    
    /// Mapped for case insensitivity
    var excludesFileExtensions: [String]? {
        get {
            return _excludesFileExtensions.map({$0.lowercased()})
        }
        set {
            if let newValue = newValue {
                _excludesFileExtensions = newValue
            }
        }
    }
}


// MARK: - Parse

extension Fileable {
    
    func getItemsAtPath(_ path: URL) -> [URL]? {
        return try? filesManager.contentsOfDirectory(at: path, includingPropertiesForKeys: [], options: [])
    }
    
    func filesForDirectory(_ directoryPath: URL) -> [File]  {
        var files = [File]()
        var filePaths = [URL]()
        // Get contents
        do  {
            filePaths = try self.filesManager.contentsOfDirectory(at: directoryPath, includingPropertiesForKeys: [], options: [.skipsHiddenFiles])
        } catch {
            return files
        }
        // Parse
        for filePath in filePaths {
            let file = File(filePath: filePath)
            if let excludesFileExtensions = excludesFileExtensions, let fileExtensions = file.fileExtension , excludesFileExtensions.contains(fileExtensions) {
                continue
            }
            if let excludesFilepaths = excludesFilepaths , excludesFilepaths.contains(file.filePath) {
                continue
            }
            if file.displayName.isEmpty == false {
                files.append(file)
            }
            
            let thumbnailURL = directoryPath.appendingPathComponent(Constants.HiddenFolderName).appendingPathComponent(filePath.lastPathComponent)
            self.createTHumbnailAndOriginalFolders(directoryPath)
            
            if filePath.isImage {
                
                file.thumbnailURL = thumbnailURL
                
                if !self.filesManager.fileExists(atPath: thumbnailURL.path) {
                    if let pictureImage = filePath.toUIImage,
                        let croppedImageData = pictureImage.cropImageWithCustomSize() {
                        self.writeData(croppedImageData, toPath: thumbnailURL)
                    }
                }
                
            } else if filePath.isPDF {
                let pdfThumbnailURL = directoryPath.appendingPathComponent(Constants.HiddenFolderName).appendingPathComponent(filePath.lastPathComponent.deletingPathExtension + ".jpg")
                
                if !self.filesManager.fileExists(atPath: pdfThumbnailURL.path) {
                    if let pdfThumbnail = self.getPDFThumbnail(filePath).toFullData?.resizeData() {
                        try? pdfThumbnail.write(to: pdfThumbnailURL)
                    }
                }
            }
        }
        
        return files.sorted(){ $0.timeStamp > $1.timeStamp }
    }
    
    fileprivate func createTumbnailFolder(atPath path: URL) {
        if !isThumbnailFolderExist(path) {
            self.create(folderAtPath: path, withName: Constants.HiddenFolderName)
        }
        
        if !isOriginalImagesFolderExist(path) {
            self.create(folderAtPath: path, withName: Constants.OriginalImageFolderName)
        }
    }
    
    func isThumbnailFolderExist(_ path: URL) -> Bool {
        let thumbnailPath = path.appendingPathComponent(Constants.OriginalImageFolderName)
        var isCreated: ObjCBool = false
        filesManager.fileExists(atPath: thumbnailPath.path, isDirectory: &isCreated)
        
        return isCreated.boolValue
    }
    
    func isOriginalImagesFolderExist(_ path: URL) -> Bool {
        let originalImagesPath = path.appendingPathComponent(Constants.OriginalImageFolderName)
        var isCreated: ObjCBool = false
        filesManager.fileExists(atPath: originalImagesPath.path, isDirectory: &isCreated)
        
        return isCreated.boolValue
    }
    
    func createTHumbnailAndOriginalFolders(_ dirURL: URL) {
        self.create(folderAtPath: dirURL, withName: Constants.HiddenFolderName)
        self.create(folderAtPath: dirURL, withName: Constants.OriginalImageFolderName)
    }
}


extension Fileable {
    
    func reloadContentImage(_ data: Data, initialPathURL: URL, filePath: URL, fileName: String) {
        let renamedFileURL = initialPathURL.appendingPathComponent(fileName + ".jpg")
        let originalImageURL = initialPathURL.appendingPathComponent(Constants.OriginalImageFolderName).appendingPathComponent(filePath.lastPathComponent)
        let renamedOriginalURL = initialPathURL.appendingPathComponent(Constants.OriginalImageFolderName).appendingPathComponent(fileName + ".jpg")
        let renamedOriginaTextURL = initialPathURL.appendingPathComponent(Constants.OriginalImageFolderName).appendingPathComponent(filePath.deletingPathExtension().lastPathComponent + ".txt")
        
        print("renamedOriginaTextURL = \(renamedOriginaTextURL)")
        
        initialPathURL.remove(fileAtPath: originalImageURL)
        initialPathURL.remove(fileAtPath: filePath)
        initialPathURL.remove(fileAtPath: renamedOriginaTextURL)
        
        try? data.write(to: renamedFileURL)
        try? data.write(to: renamedOriginalURL)
    }
}


extension Fileable {
    
    func createTextDocumentAtPath(_ initialPath: URL, documentName: String, content: String?) {
        let textFile = documentName + ".txt"
        let textURL = initialPath.appendingPathComponent(textFile)
        
        do {
            if textURL.fileExist {
                do {
                    try self.filesManager.removeItem(at: textURL)
                } catch {
                    print("textFile.removeItem error = \(error.localizedDescription)")
                }
            }
            
            if let contentDocument = content {
                try contentDocument.write(to: textURL, atomically: false, encoding: String.Encoding.utf8)
            }
            
        } catch {
            print("contentDocument.write error = \(error.localizedDescription)")
        }
    }
    
    func getTextDocumentAtPath(_ filePath: URL) -> String? {
        let textPath = filePath.deletingLastPathComponent().appendingPathComponent(filePath.deletingPathExtension().lastPathComponent + ".txt")
        print("textPath get text = \(textPath)")
        do {
            return try String(contentsOf: textPath, encoding: String.Encoding.utf8)
        } catch {
            print("Cannot retrieve text from file \(error.localizedDescription)")
        }
        
        return nil
    }
}


extension Fileable {
    
    func getDate(_ attributes: [FileAttributeKey: Any]?) -> String {
        var stringDate = String()
        if let attributes = attributes, let fileDate = attributes[FileAttributeKey.creationDate] as? Date {
            stringDate = getDateInCurrentLocaleWithHour(fileDate) ///date(fileDate)
        }
        
        return stringDate
    }
    
    func getTimestamp(_ attributes: [FileAttributeKey: Any]?) -> Double {
        if let attributes = attributes, let fileDate = attributes[FileAttributeKey.creationDate] as? Date {
            return fileDate.timeIntervalSince1970
        }
        
        return 0
    }
}


extension Fileable {
    
    func getOnlyDirectories(_ files: [File]) -> [File] {
        var onlyDirs = [File]()
        
        for file in files {
            if file.isDirectory {
                onlyDirs.append(file)
            }
        }
        
        return onlyDirs
    }
    
    func getFilesWithoutDirectories(_ files: [File]) -> [File] {
        var onlyDirs = [File]()
        
        for file in files {
            if !file.isDirectory {
                onlyDirs.append(file)
            }
        }
        
        return onlyDirs
    }
    
    func getImages(_ path: URL) -> [UIImage] {
        var images = [UIImage]()
        
        if let paths = try? filesManager.contentsOfDirectory(at: path, includingPropertiesForKeys: [], options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles) {
            for filePath in paths {
                if filePath.isImage {
                    if let image = filePath.toUIImage {
                        images.append(image)
                    }
                }
            }
        }
        
        return images
    }
    
    func isContain(_ files: [File], folderName name: String) -> Bool {
        var isContain = false
        
        for file in files {
            if file.filePath.lastPathComponent == name {
                isContain = true
                break
            }
        }
        
        return isContain
    }
    
    func create(folderAtPath path: URL, withName name: String) {
        let newDirectory = path.appendingPathComponent(name)
        
        do {
            try filesManager.createDirectory(at: newDirectory, withIntermediateDirectories: true, attributes: nil)
            
        } catch {
            print("Cannot create folder at path, error = \(error.localizedDescription)")
        }
    }
    
    func remove(fileAtPath path: URL) {
        do {
            try filesManager.removeItem(at: path)
        } catch {
            print("Cannot remove at path, error = \(error.localizedDescription)")
        }
    }
}


// MARK: - Move File at path

extension Fileable {
    
    func moveFile(_ srcURL: URL, toDestinationPath dstURL: URL) {
        do {
            try filesManager.moveItem(at: srcURL, to: dstURL)
        } catch {
            print("Cannot move file at path\(srcURL) to toDestinationPath \(dstURL), error = \(error.localizedDescription)")
        }
    }
    
    func copyFile(_ srcURL: URL, toDestinationPath dstURL: URL) {
        do {
            try filesManager.copyItem(at: srcURL, to: dstURL) ///moveItem(at: srcURL, to: dstURL)
        } catch {
            print("Cannot copy file at path\(srcURL) to toDestinationPath \(dstURL), error = \(error.localizedDescription)")
        }
    }
    
    func isFolderExistsAtPath(_ path: URL) -> Bool {
        var isCreated: ObjCBool = false
        filesManager.fileExists(atPath: path.path, isDirectory: &isCreated)
        
        return isCreated.boolValue
    }
    
    func writeData(_ imageData: Data?, toPath path: URL) {
        if let imgData = imageData {
            do {
                try imgData.write(to: path)
            } catch {
                print("Cannot write imageData to path \(path), error = \(error.localizedDescription)")
            }
        }
    }
}


// MARK: - createPDFDocumentWithName

import UIKit

extension Fileable {
    
    func createPDFDocumentWithName(_ name: String,
                                   message: String,
                                   actionButtonTitle: String,
                                   fileStatus: FileStatusType,
                                   inputTextField: UITextField?,
                                   forController viewController: UIViewController,
                                   appendPathCompletion: @escaping PathCompletion) {
        var inputTextField = inputTextField
        let text = "Doc " + getDateInCurrentLocaleWithHour(Date())
        
        let createFolderPromptAlertController = UIAlertController(title: name, message: message, preferredStyle: .alert)
        createFolderPromptAlertController.addAction(UIAlertAction(title: "Cancel".localized(), style: .default, handler: nil))
        
        createFolderPromptAlertController.addTextField(configurationHandler: { (textField: UITextField!) in
            textField.placeholder = text
            inputTextField = textField
        })
        
        createFolderPromptAlertController.addAction(UIAlertAction(title: actionButtonTitle, style: .default, handler: { action -> Void in
            
            if let isEmpty = inputTextField?.text?.isEmpty, isEmpty == true {
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
    }
}


extension Fileable {
    
    func getPDFThumbnailURL(_ initialPath: URL) -> URL {
        return initialPath.appendingPathComponent(Constants.HiddenFolderName)
    }
    
    func getPDFSmallImagesURL(_ initialPath: URL) -> URL {
        return initialPath.appendingPathComponent(Constants.OriginalImageFolderName)
    }
    
    func getPDFSmallImagesURLCount(_ filePath: URL) -> Int? {
        let initialPath = filePath.path.deletingLastPathComponent
        let initialPathURL = URL(fileURLWithPath: initialPath)
        let pdfSmallImagesURL = initialPathURL.appendingPathComponent(Constants.OriginalImageFolderName).appendingPathComponent(filePath.lastPathComponent.deletingPathExtension)
        
        return pdfSmallImagesURL.numberOfItemsAtPath
    }
}


// MARK: - Move english language for tesseract from bundle to languages folder from documents

extension Fileable {
    
    func moveTessDataFolder() {
        let bundleURL = Bundle.main.bundleURL
        let tessDataFolderName = "tessdata"
        let tessDataBundleURL = bundleURL.appendingPathComponent(tessDataFolderName)
        
        let documentsOCRLanguagesURL = documentsURL.appendingPathComponent(".ocrLanguages")
        let documentsTessdataURL = documentsOCRLanguagesURL.appendingPathComponent(tessDataFolderName)
        
        if !filesManager.fileExists(atPath: documentsOCRLanguagesURL.path) {
            do {
                try self.filesManager.createDirectory(atPath: documentsOCRLanguagesURL.path, withIntermediateDirectories: true, attributes: nil)
                
            } catch {
                print("error creation folder \(error.localizedDescription)")
            }
        }
        
        if !filesManager.fileExists(atPath: documentsTessdataURL.path) {
            do {
                try self.filesManager.copyItem(at: tessDataBundleURL, to: documentsTessdataURL)
                
            } catch {
                print("error move folder \(error.localizedDescription)")
            }
        }
        
        if let items = documentsTessdataURL.numberOfItemsAtPath {
            print(items)
            
            if let itemsURL = bundleURL.getItemsAtPath(documentsTessdataURL) {
                print(itemsURL)
            }
        }
        
        if UserDefaults.standard.isFirstLaunch {
            self.userDefaultsSaveValue(12, key: userDefaultsOCRIndexPath)
        }
    }
}




extension Fileable {
    /* Original, do not delete
    func validateFileName(_ fileName: String, atPath targetPath: String) -> String? {
        if !filesManager.fileExists(atPath: URL(fileURLWithPath: targetPath).appendingPathComponent(fileName).absoluteString) {
            return fileName
        }
        
        let fileExtension = fileName.pathExtension
        
        if fileExtension == "" {
            
            return fileName
        }
        
        var strippedFileName: String = fileName.deletingPathExtension
        var count = 1
        
        let startRange = (strippedFileName as NSString).range(of: "(", options: .backwards)
        let endRange = (strippedFileName as NSString).range(of: ")", options: .backwards)
        
        if startRange.location != NSNotFound && endRange.location != NSNotFound && endRange.location > startRange.location && endRange.location == (strippedFileName.characters.count ) - 1 {
            let betweenParenthesis: String = (strippedFileName as NSString).substring(with: NSRange(location: startRange.location + 1, length: endRange.location - (startRange.location + 1)))
            let numberBetweenParenthesis: Int = (betweenParenthesis as NSString).integerValue
            if numberBetweenParenthesis > 0 {
                count = numberBetweenParenthesis
                strippedFileName = (strippedFileName as NSString).substring(with: NSRange(location: 0, length: startRange.location))
            }
        }
        
        if var validatedFileName = "\(strippedFileName)(\(count))".appendingPathExtension(fileExtension) {
            while filesManager.fileExists(atPath: URL(fileURLWithPath: targetPath).appendingPathComponent(validatedFileName).absoluteString) {
                count += 1
                if let newPathExtension = "\(strippedFileName)(\(count))".appendingPathExtension(fileExtension) {
                    validatedFileName = newPathExtension
                }
            }
            
            return validatedFileName
        }
        
        return nil
    }*/
    
    func validateFileName(_ fileName: String, atURL targetURL: URL) -> String {
        let fileURL = targetURL.appendingPathComponent(fileName)
        
        if !filesManager.fileExists(atPath: fileURL.path) {
            return fileName
        }
        var strippedFileName = fileName.deletingPathExtension
        var count = 1
        
        let startRange = (strippedFileName as NSString).range(of: "(", options: .backwards)
        let endRange = (strippedFileName as NSString).range(of: ")", options: .backwards)
        
        if startRange.location != NSNotFound && endRange.location != NSNotFound && endRange.location > startRange.location && endRange.location == (strippedFileName.characters.count ) - 1 {
            let betweenParenthesis: String = (strippedFileName as NSString).substring(with: NSRange(location: startRange.location + 1, length: endRange.location - (startRange.location + 1)))
            let numberBetweenParenthesis: Int = (betweenParenthesis as NSString).integerValue
            if numberBetweenParenthesis > 0 {
                count = numberBetweenParenthesis
                strippedFileName = (strippedFileName as NSString).substring(with: NSRange(location: 0, length: startRange.location))
            }
        }
        
        var validatedFileName: String
        
        if fileURL.isDirectory {
            validatedFileName = "\(strippedFileName) (\(count))"
        } else {
            validatedFileName = "\(strippedFileName) (\(count))".appendingPathExtension(fileName.pathExtension)
        }
        
        while filesManager.fileExists(atPath: URL(fileURLWithPath: targetURL.path).appendingPathComponent(validatedFileName).path) {
            count += 1
            validatedFileName = "\(strippedFileName) (\(count))"
            
            if fileURL.isDirectory {
                validatedFileName = "\(strippedFileName) (\(count))"
            } else {
                validatedFileName = "\(strippedFileName) (\(count))".appendingPathExtension(fileName.pathExtension)
            }
        }
        
        return validatedFileName
    }
}


extension String {
    
    var pathExtension: String {
        return (self as NSString).pathExtension
    }
    
    func appendingPathExtension(_ pathExtension: String) -> String {
        return (self as NSString).appendingPathExtension(pathExtension) ?? ""
    }
}

