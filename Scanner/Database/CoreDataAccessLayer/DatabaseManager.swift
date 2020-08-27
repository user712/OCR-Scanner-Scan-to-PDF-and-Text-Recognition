//
//  DatabaseManager.swift
//  Scanner
//
//  Created  on 6/30/17.
//   
//

import Foundation
import CoreData


class DatabaseManager {
    
    private init() {
        
    }
    
    class func insert(file: File) {
        let context = DataAccesLayer.shared.managedObjectContext
        
        let fileData = NSEntityDescription.insertNewObject(forEntityName: "FileData", into: context) as! FileData
        
        fileData.identifier = file.identifier
        
        do {
            try context.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    class func update(file: File) {
        let context = DataAccesLayer.shared.managedObjectContext
        
        let fileData = getFile(file: file)
        
        if let contrast = file.contrast {
            fileData?.contrast = contrast
        }
        
        if let brightness = file.brightness {
            fileData?.brightness = brightness
        }
        
        fileData?.rotateAngle = file.rotateAngle
        fileData?.colorType = file.colorType
        fileData?.identifier = file.identifier
        
        do {
            try context.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    class func delete(fileData: FileData) {
        let context = DataAccesLayer.shared.managedObjectContext
        
        context.delete(fileData)
        
        do {
            try context.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    class func getFile(file: File) -> FileData? {
        let context = DataAccesLayer.shared.managedObjectContext
        
        let request = NSFetchRequest<NSFetchRequestResult>()
        let description = NSEntityDescription.entity(forEntityName: "FileData", in: context)
        request.entity = description
        
        let predicate = NSPredicate(format: "identifier==%@", file.identifier)
        request.predicate = predicate
        
        request.returnsObjectsAsFaults = false
        
        let resultArray = try? context.fetch(request)
        
        if let result = resultArray?.first as? FileData {
            return result
        }
        return nil
    }
}
