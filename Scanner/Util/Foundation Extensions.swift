//
//  Foundation Extensions.swift
//  Scanner
//
//    
//   
//

import Foundation

// MAKR: - NSMutableData

extension NSMutableData {
    
    class var cfMutableData: CFMutableData {
        return NSMutableData() as CFMutableData /// to expect initializer
    }
}
