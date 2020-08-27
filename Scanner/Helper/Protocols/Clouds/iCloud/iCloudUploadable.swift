//
//  iCloudUploadable.swift
//  iScanner
//


import Foundation

protocol iCloudUploadable: iCloudAutorizeable {
    func saveDocumentToiCloud(_ documentURL: URL)
}

extension iCloudUploadable {
    
    func saveDocumentToiCloud(_ documentURL: URL) {
        if let destinationURL = self.iCloudDocumentsURL?.appendingPathComponent(documentURL.lastPathComponent) {
            do {
                let dataImage = try Data(contentsOf: documentURL)
                try dataImage.write(to: destinationURL)
            } catch {
                print("Error moving \(documentURL) to storage \(destinationURL)")
            }
        }
    }
}
