//
//  PreviewItem.swift
//  SwiftCam
//
//  Created by Developer on 3/3/17.
//  Copyright © . 
//

import UIKit
import QuickLook

class PreviewItem: NSObject, QLPreviewItem {
    
    // MARK: - Properties
    
    let itemURL: URL
    let itemTitle: String
    private(set) var previewItemURL: URL?
    private(set) var previewItemTitle: String?
    
    
    // MARK: - Initializers
    
    init(itemURL: URL, itemTitle: String) {
        self.itemURL = itemURL
        self.itemTitle = itemTitle
        
        super.init()
        
        self.previewItemURL = itemURL
        self.previewItemTitle = itemTitle
    }
}
