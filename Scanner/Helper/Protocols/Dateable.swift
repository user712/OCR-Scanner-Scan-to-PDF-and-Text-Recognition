//
//  Datable.swift
//  Scanner
//
//  
//   
//

import Foundation

protocol Dateable {
    func date(_ date: Date) -> String
    func getDateInCurrentLocale(_ date: Date) -> String
    func getDateInCurrentLocaleWithHour(_ date: Date) -> String
    func dateForSaveImage(_ date: Date) -> String
}

extension Dateable {
    
    func date(_ date: Date = Date()) -> String {
        let dateForm = DateFormatter()
        dateForm.dateFormat = "dd:MM:yyyy HH:mm:ss"
        let stringDate = dateForm.string(from: date)
        
        return stringDate
    }
    
    func dateForSaveImage(_ date: Date = Date()) -> String {
        let dateForm = DateFormatter()
        dateForm.dateFormat = "dd:MM:yyyy HH:mm:ss"
        let stringDate = dateForm.string(from: date)
        
        return stringDate
    }
    
    /// This function will return a current date in format "Sep 20, 2016"
    func getDateInCurrentLocale(_ date: Date) -> String {
        let currentLocale = Locale.current
        let dateFormatter = DateFormatter()
        let dateComponents = "yMMMd"
        let dateFormat = DateFormatter.dateFormat(fromTemplate: dateComponents, options: 0, locale: currentLocale)
        dateFormatter.dateFormat = dateFormat
        
        return dateFormatter.string(from: date)
    }
    
    /// This function will return a current date in format ""Jan 23, 2017, 14:59:09""
    func getDateInCurrentLocaleWithHour(_ date: Date = Date()) -> String {
//        let currentLocale = Locale.current
        let dateFormatter = DateFormatter()
//        let dateComponents = "y-MMM-d - H'-'ms"
//        let dateFormat = DateFormatter.dateFormat(fromTemplate: dateComponents, options: 0, locale: currentLocale)
//        dateFormatter.dateFormat = dateFormat
        
        dateFormatter.dateStyle = .short
        
        return dateFormatter.string(from: date)
    }
}
