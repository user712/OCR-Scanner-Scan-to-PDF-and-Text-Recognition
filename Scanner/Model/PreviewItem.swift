//
//  PreviewItem.swift
//  Scanner
//
//  
//   
//

import Foundation
import QuickLook

class PreviewItem: NSObject, QLPreviewItem {
    
    /*!
     * @abstract The URL of the item to preview.
     * @discussion The URL must be a file URL.
     */
    
    // MARK: - Properties
    
    var filePath: URL?
    
    public var previewItemURL: URL? {
        if let filePath = filePath {
            return filePath
        }
        return nil
    }
}
