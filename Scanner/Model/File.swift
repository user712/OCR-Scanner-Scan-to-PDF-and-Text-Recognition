//
//  File.swift
//  Scanner
//
//  
//   
//

import UIKit

/// File is a class representing a file in iFinder
class File: NSObject {
    /// Display name. String.
    let displayName: String
    // is Directory. Bool.
    let isDirectory: Bool
    /// File extension.
    let fileExtension: String?
    /// File attributes (including size, creation date etc).
    let fileAttributes: NSDictionary?
    /// URL file path.
    let filePath: URL
    // FileType
    let type: FileType
    /// File count and size
    var countAndSize: String!
    /// Creation Date
    let date: String
    ///
    var thumbnailURL: URL!
    /// Creation Date timestamp for sort
    let timeStamp: Double
    
    var contrast: Float?
    
    var brightness: Float?
    
    var identifier: String

    var rotateAngle: Int16 = 0
    
    var colorType: Int16 = 0
    
    /**
     Initialize an File object with a filePath
     - parameter filePath: URL filePath
     - returns: File object.
     */
    init(filePath: URL) {
        self.filePath = filePath
        self.isDirectory = filePath.isDirectory
        self.date = filePath.getDate
        self.timeStamp = filePath.getTimestamp
        print(self.timeStamp)
        thumbnailURL = filePath.appendingPathComponent("\(Constants.HiddenFolderName)/\(filePath.lastPathComponent)")
        if self.isDirectory {
            self.fileAttributes = nil
            self.fileExtension = nil
            self.type = .directory
            let filesName = "files".localized()
            self.countAndSize = "\(filePath.numberOfItemsAtPath ?? 0) \(filesName)"
        } else {
            self.fileAttributes = self.filePath.getFileAttributes
            self.fileExtension = filePath.pathExtension
            
            if let fileExtension = fileExtension {
                self.type = FileType(rawValue: fileExtension) ?? .none
            } else {
                self.type = .none
            }
            
            if filePath.isPDF {
                self.countAndSize = "\(filePath.getPDFNumberFiles ?? 0) " + "pages".localized()
            } else {
                self.countAndSize = ""
            }
        }
        
        self.displayName = filePath.lastPathComponent
        
        func fileIdeintifier(url: URL) -> String {
            var pathElements = url.pathComponents
            pathElements.removeSubrange(0..<pathElements.index(of: "Scanner")!)
            let name = pathElements.joined(separator: "/")
            return name
        }
        
        self.identifier = fileIdeintifier(url: filePath)
    }
}
