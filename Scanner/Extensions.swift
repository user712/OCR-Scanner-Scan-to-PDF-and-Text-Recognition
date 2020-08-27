//
//  Extensions.swift
//  Six Pack Abs
//
//  Created  on 4/20/17.
//  Copyright © 2017   
//

import Foundation

fileprivate var dictWithLanguages = Dictionary<String, Dictionary<String, Dictionary<String, String>>>()
fileprivate var currentTable = ""
fileprivate var allLanguages = Array<String>()

extension String{
    func localized() -> String{
        currentTable = "Localizable"
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            initLocalizationsUtils()
        #endif
        
        let tableDict = dictWithLanguages[currentTable]
        
        for lang in allLanguages {
            if tableDict?[lang]?[self] == nil {
                saveKey(lang: lang)
            }else{
                removeKeyFromDict(lang: lang)
            }
        }
        
        return NSLocalizedString(self, comment: "")
    }
    
    func localized(table: String) -> String{
        currentTable = table
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            initLocalizationsUtils()
        #endif
        
        let tableDict = dictWithLanguages[table]
        
        for lang in allLanguages {
            if tableDict?[lang]?[self] == nil {
                saveKey(lang: lang)
            }else{
                removeKeyFromDict(lang: lang)
            }
        }
        
        return NSLocalizedString(self, tableName: table, comment: "")
    }
    
    func length() -> Int {
        return self.characters.count
    }
    
    // private methods
    
    private func removeKeyFromDict(lang: String){
        var stringsDict = self.stringsDict()
        
        guard var dictValue = stringsDict[self] else {
            return;
        }
        
        var allLanguages = dictValue.components(separatedBy: ", ")
        if !allLanguages.contains(lang) {return}
        
        for language in allLanguages {
            if language.contains(lang) {
                let indexOfObject = allLanguages.index(of: language)!
                allLanguages.remove(at: indexOfObject)
                break
            }
        }
        
        if allLanguages.count > 0 {
            dictValue = allLanguages.joined(separator: ", ")
        }else{
            stringsDict.removeValue(forKey: self)
        }
        
        writeDictToStringsFile(stringsDict: stringsDict, dictValue: dictValue)
    }
    
    private func saveKey(lang: String){
        
        var stringsDict = self.stringsDict()
        
        var dictValue = stringsDict[self] ?? lang
        
        if !dictValue.contains(lang) {
            dictValue = dictValue.appending(", \(lang)")
        }
        
        stringsDict[self] = dictValue
        writeDictToStringsFile(stringsDict: stringsDict, dictValue: dictValue)
    }
    
    private func desktopPath() -> String{
        let theDesktopPath = NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true)[0];
        let array = theDesktopPath.components(separatedBy: "/")
        let realDesktopPath = "/" + array[1] + "/" + array[2] + "/" + array.last!
        return realDesktopPath
    }
    
    private func appFolderPath() -> String{
        var appName = Bundle.main.infoDictionary!["CFBundleName"] as! String
        appName = appName.appending(" localizations")
        let appFolderPath = (desktopPath() as NSString).appendingPathComponent(appName)
        
        try? FileManager.default.createDirectory(atPath: appFolderPath, withIntermediateDirectories: false, attributes: nil)
        
        return appFolderPath
    }
    
    private func stringsPath() -> String{
        return (appFolderPath() as NSString).appendingPathComponent("\(currentTable).strings")
    }
    
    private func stringsDict() -> Dictionary<String, String>{
        return NSDictionary(contentsOfFile: stringsPath()) as? [String: String] ?? Dictionary<String, String>()
    }
    
    private func writeDictToStringsFile(stringsDict: Dictionary<String, String>, dictValue: String){
        var finalString = ""
        
        for item in stringsDict {
            if item.key == self{
                finalString = finalString.appending("\"\(self)\" = \"\(dictValue)\";\n\n")
            }else{
                finalString = finalString.appending("\"\(item.key)\" = \"\(item.value)\";\n\n")
            }
        }
        
        try? finalString.write(toFile: stringsPath(), atomically: true, encoding: .utf8)
    }
    
    private func initLocalizationsUtils(){
        DispatchQueue.once(token: "localization.token") { () in
            let bundlePath = Bundle.main.resourcePath
            let dirs = try? FileManager.default.contentsOfDirectory(atPath: bundlePath!)
            
            for element in dirs! {
                if(element.contains("lproj")){
                    let languageName = element.replacingOccurrences(of: ".lproj", with: "")
                    allLanguages.append(languageName)
                    let languageFolder = (bundlePath! as NSString).appendingPathComponent(element)
                    let langDir = try? FileManager.default.contentsOfDirectory(atPath: languageFolder)
                    
                    for file in langDir! {
                        if file.contains("strings") {
                            let tableName = file.replacingOccurrences(of: ".strings", with: "")
                            let tablePath = (languageFolder as NSString).appendingPathComponent(file)
                            if let languageDict = NSDictionary(contentsOfFile: tablePath){
                                var tableDict = dictWithLanguages[tableName] ?? Dictionary<String, Dictionary<String, String>>()
                                tableDict[languageName] = languageDict as? [String : String]
                                dictWithLanguages[tableName] = tableDict
                            }
                        }
                    }
                }
            }
        }
    }
}


public extension DispatchQueue {
    
    private static var _onceTracker = [String]()
    
    /**
     Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.
     
     - parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
     - parameter block: Block to execute once
     */
    public class func once(token: String, block:(Void)->Void) {
        objc_sync_enter(self); defer { objc_sync_exit(self) }
        
        if _onceTracker.contains(token) {
            return
        }
        
        _onceTracker.append(token)
        block()
    }
}
