//
//  PreviewDatasource.swift
//  CameraQuality
//
//  Created  on 2/28/17.
//  Copyright © 2017 
//

import UIKit
import QuickLook

class PreviewDatasource: NSObject {

    // MARK: - Properties
    
    let previewItem: PreviewItem
    
    
    // MARK: - Initializers
    
    init(previewItem: PreviewItem) {
        self.previewItem = previewItem
        super.init()
    }
}


// MARK: - QLPreviewControllerDataSource

extension PreviewDatasource: QLPreviewControllerDataSource {
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return self.previewItem
    }
}
