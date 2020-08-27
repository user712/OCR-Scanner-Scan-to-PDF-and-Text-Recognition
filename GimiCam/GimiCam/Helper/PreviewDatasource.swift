//
//  PreviewDatasource.swift
//  GimiCam
//
//  Created  on 3/6/17.
//  Copyright © 2017 A. 
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
