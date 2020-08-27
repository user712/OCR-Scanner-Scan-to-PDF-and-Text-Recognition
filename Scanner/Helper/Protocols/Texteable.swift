//
//  Texteable.swift
//  Scanner
//
//   on 2/10/17.
//   
//

import Foundation

struct TextURL {
    
    // MARK: - Properties
    
    let fileURL: URL
    
    var initialURL: URL
    var originalFolderURL: URL
    var pdfFolderURL: URL
    var textLastPathComponent = ".txt"
    let fileTextURL: URL
    
    
    // MARK: - Initializers
    
    init(fileURL: URL) {
        self.fileURL = fileURL
        self.initialURL = fileURL.deletingLastPathComponent()
        self.originalFolderURL = self.initialURL.appendingPathComponent(Constants.OriginalImageFolderName)
        self.pdfFolderURL = originalFolderURL.appendingPathComponent(fileURL.lastPathComponent.deletingPathExtension)
        self.fileTextURL = self.originalFolderURL.appendingPathComponent(fileURL.lastPathComponent.deletingPathExtension + self.textLastPathComponent)
    }
}



struct FileText {
    
    // MARK: - Properties
    
    let documentName: String
    var content: String?
    let fileTextURL: TextURL
    
    
    // MARK: - Initializers
    
    init(documentName: String, content: String?, fileTextURL: TextURL) {
        self.documentName = documentName
        self.content = content
        self.fileTextURL = fileTextURL
    }
}

protocol Texteable {
    func createTextDocument<T: Fileable>(_ fileableManager: T, fileTextContent: FileText)
}


// MARK: - Create text Document

extension Texteable {
    
    func createTextDocument<T: Fileable>(_ fileableManager: T, fileTextContent: FileText) {
        let textFile = fileTextContent.documentName + fileTextContent.fileTextURL.textLastPathComponent
        let textURL = fileTextContent.fileTextURL.originalFolderURL.appendingPathComponent(textFile)
        
        /// Check if textURL exist ant remove it to no create difficults
        do {
            if fileableManager.filesManager.fileExists(atPath: textURL.path) {
                try fileableManager.filesManager.removeItem(at: textURL)
            }
        } catch {
            print("textFile.removeItem error = \(error.localizedDescription)")
        }
        
        
        /// Write content
        if let contentDocument = fileTextContent.content {
            do {
                try contentDocument.write(to: textURL, atomically: false, encoding: String.Encoding.utf8)
            } catch {
                print("contentDocument.write error = \(error.localizedDescription)")
            }
        }
    }
}


// MARK: - Get Txt file Content

extension Texteable {
    
    func getContentFromTextDocumentURL(_ text: TextURL, indexPath: IndexPath) -> String? {
        let textURL = text.originalFolderURL.appendingPathComponent(text.fileURL.lastPathComponent.deletingPathExtension + text.textLastPathComponent)
        
        do {
            return try String(contentsOf: textURL, encoding: String.Encoding.utf8)
        } catch {
            print("Cannot retrieve text from file \(error.localizedDescription)")
        }
        
        return nil
    }
}
















































































