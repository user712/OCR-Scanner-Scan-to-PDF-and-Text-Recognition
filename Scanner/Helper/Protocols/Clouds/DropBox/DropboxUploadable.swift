//
//  DropboxUploadable.swift
//  iScanner
//


import Foundation
import ObjectiveDropboxOfficial


protocol DropboxUploadable: DropboxAutorizable {

}


extension DropboxUploadable {
    
    var folderToUploadName: String {
        return "/iScanner"
    }
}


extension DropboxUploadable {
    func dropboxCancelUploads(){
        if let requests = requests{
            for request in requests{
                request.cancel()
            }
        }
    }
    
    func dropboxUpload(filePaths: [URL]) {
        requests = Array<DBUploadTask<DBFILESFileMetadata, DBFILESUploadError>>()
        
        uploadDidStart()
        let numOfUrl = filePaths.count
        var count = 0
        
        for filePath in filePaths{
            if let fileData = filePath.toData {
                let fileName = folderToUploadName + "/" + filePath.lastPathComponent
                let request = dropboxClient?.filesRoutes.uploadData(fileName, mode: nil, autorename: NSNumber(value: true), clientModified: nil, mute: NSNumber(value: true), propertyGroups: nil, strictConflict: NSNumber(value: true), inputData: fileData).setResponseBlock({ (result, routeError, error) in
                    
                    if let result = result {
                        count += 1
                        if numOfUrl == count{
                            self.uploadDidFinish()
                        }
                        print("result = \(result)\n")
                    } else {
                        print("routeError = \(String(describing: routeError))\n error = \(String(describing: error))\n")
                    }
                })
                
                requests?.append(request!)
            }
        }
    }
}

fileprivate var requests: Array<DBUploadTask<DBFILESFileMetadata, DBFILESUploadError>>?
