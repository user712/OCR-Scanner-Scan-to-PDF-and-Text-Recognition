//
//  PaperSizeable.swift
//  Scanner
//
//   on 1/26/17.
//   
//

import Foundation

protocol PaperSizeable {
    var paperSizes: [String] { get }
}


extension PaperSizeable {
    
    var paperSizes: [String] {
        return ["Letter (8¹/₂'') x 11''", "A4 (210mm x 297mm)", "Legal (8¹/₂'') x 14''", "A3 (297mm x 420mm)", "A5 (149mm x 210mm)", "Business Card (85mm x 55mm)"]
    }
    
    var paperSizesShort: [String] {
        return ["Letter".localized(), "A4", "Legal".localized(), "A3", "A5", "BC"]
    }
    
    var paperSizesMedium: [String] {
        return ["Letter".localized(),
                "A4",
                "Legal".localized(),
                "A3",
                "A5",
                "Business Card".localized()]
    }
    
    var paperSizesPixels: [String] {
        let legal = "Legal".localized()
        let letter = "Letter".localized()
        let bc = "Business Card".localized()
        
        return ["\(letter) (816px x 1056px)",
                "A4 (793px x 1122px)",
                "\(legal) (816px x 1344px)",
                "A3 (1122px x 1587px)",
                "A5 (559px x 793px)",
                "\(bc) (336px x 192px)"]
    }
}
