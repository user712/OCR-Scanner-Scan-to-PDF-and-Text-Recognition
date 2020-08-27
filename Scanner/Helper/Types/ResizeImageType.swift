//
//  ResizeImageType.swift
//  Scanner
//
//  
//   
//

import UIKit

enum ResizeImageType: Int {
    case letter = 0, a4, legal, a3, a5, businessCard
    
    
    var size: CGSize {
        switch self {
        case .letter:
            return CGSize(width: 816, height: 1056) /// 8,5in x 11in
        case .a3:
            return CGSize(width: 1122.519685, height: 1587.401575) /// 297mm x 420mm
        case .a4:
            return CGSize(width: 793.700787, height: 1122.519685) /// 105mm x 148mm
        case .a5:
            return CGSize(width: 559.370079, height: 793.700787) /// 148mm x 210mm
        case .legal:
            return CGSize(width: 816, height: 1344) /// 8.5in x 14in
        case .businessCard:
            return CGSize(width: 336, height: 192) /// US size 3,5in x 2in
        }
    }
}
