//
//  UserDefaultable.swift
//  Scanner
//
//   on 1/20/17.
//   
//

import Foundation

protocol UserDefaultable {
    func userDefaultsSaveValue(_ value: Any, key: String)
    func userDefaultsGetValue(_ key: String) -> Any?
    func userDefaultsRemoveObject(_ key: String)
    
    func userDefaultsSetBoolValueForKey(_ booleanValue: Bool, key: String)
    func userDefaultsBoolForKey(_ key: String) -> Bool
}


extension UserDefaultable {
    
    private var defaults: UserDefaults {
        return UserDefaults.standard
    }
    
    func userDefaultsSaveValue(_ value: Any, key: String) {
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }
    
    func userDefaultsGetValue(_ key: String) -> Any? {
        return defaults.value(forKey: key)
    }
    
    func userDefaultsRemoveObject(_ key: String) {
        defaults.removeObject(forKey: key)
        defaults.synchronize()
    }
    
    func userDefaultsSetBoolValueForKey(_ booleanValue: Bool, key: String) {
        defaults.set(booleanValue, forKey: key)
        defaults.synchronize()
    }
    
    func userDefaultsBoolForKey(_ key: String) -> Bool {
        return defaults.bool(forKey: key)
    }
}


// MARK: - Keys

extension UserDefaultable {
    
    var userDefaultsPaperSizeKey: String {
        return "indexPath.pageSize"
    }
    
    var userDefaultsOCRIndexPath: String {
        return "ocr.downloaded.languages"
    }
}
