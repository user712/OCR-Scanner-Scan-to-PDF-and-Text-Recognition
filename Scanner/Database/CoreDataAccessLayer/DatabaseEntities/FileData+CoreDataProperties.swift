//
//  FileData+CoreDataProperties.swift
//  
//
//  Created  on 6/30/17.
//
//

import Foundation
import CoreData


extension FileData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FileData> {
        return NSFetchRequest<FileData>(entityName: "FileData")
    }

    @NSManaged public var identifier: String
    @NSManaged public var contrast: Float
    @NSManaged public var brightness: Float
    @NSManaged public var rotateAngle: Int16
    @NSManaged public var colorType: Int16
}
