//
//  UtilitiesManager.swift
//  Scanner
//
//   on 2/3/17.
//   
//

import Foundation

class Utilities {
    
    class func applicationName() -> String {
        var info = Bundle.main.infoDictionary!
        
        return "\(info["CFBundleDisplayName"] as! String)"
    }
    
    class func systemVersion() -> String {
        return "iOS \(UIDevice.current.systemVersion)"
    }
    
    class func isSystemVersionLessThan(_ version: String) -> Bool {
        return UIDevice.current.systemVersion.compare(version as String, options: String.CompareOptions.numeric) == ComparisonResult.orderedAscending
    }
    
    class func applicationNameAndVersion() -> String {
        var info = Bundle.main.infoDictionary!
        let appNameString = (info["CFBundleDisplayName"] as! String)
        let appVersionString = (info["CFBundleShortVersionString"] as! String)
        
        return "\(appNameString) \(appVersionString)"
    }
}
