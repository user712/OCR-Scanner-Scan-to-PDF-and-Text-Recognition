//
//  iCloudAutorizeable.swift
//  iScanner
//


import UIKit

protocol iCloudAutorizeable: Fileable {
//    var cloudURL: URL? { get }
//    var iCloudDocumentsURL: URL? { get }
//    
//    func checkiCloudAviability(_ completion: @escaping (Bool) -> ())
}


extension iCloudAutorizeable {
    
    var cloudURL: URL? {
        return filesManager.url(forUbiquityContainerIdentifier: nil)
    }
    
    var iCloudDocumentsURL: URL? {
        return cloudURL?.appendingPathComponent("Documents")
    }
}

extension iCloudAutorizeable {
    
    func checkiCloudAviability(_ completion: @escaping (Bool) -> ()) {
        
        /// Take in background
        OperationQueue().addOperation { _ in
            
            if self.cloudURL != nil {
                OperationQueue.main.addOperation {
                    completion(true)
                }
            } else {
                OperationQueue.main.addOperation {
                    completion(false)
                }
            }
        }
    }
}
