//
//  PreviewItem.swift
//  CameraQuality
//
//  Created  on 2/28/17.
//  Copyright © 2017 
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

//
//extension PreviewItem {
//    
//    func initPreviewURL(_ docURL: URL, withTitle title: String) -> Self {
//        super.init()
//        
//        self.previewItemURL = docURL
//        self.previewItemTitle = title
//        
//    }
//}

//
//class PreviewItem: NSObject, QLPreviewItem {
//    private(set) var previewItemURL: URL?
//    private(set) var previewItemTitle: String?
//    
//    
//    func initPreviewURL(_ docURL: URL, withTitle title: String) -> Self {
////        super.init()
//        
//        self.previewItemURL = docURL
//        self.previewItemTitle = title
//        
//        
//        
//    }
//}
