//
//  BoxUploadable.swift
//  iScanner
//


import Foundation
import BoxContentSDK


protocol BoxUploadable: BoxAutorizable {
    
}


extension BoxUploadable {
    func boxUploadFile(filePaths: [URL]) {
        requests = Array<BOXFileUploadRequest>()
        
        uploadDidStart()
        
        let numOfUrl = filePaths.count
        var count = 0

        for filePath in filePaths{
            let uploadRequest = BOXContentClient.default().fileUploadRequestToFolder(withID: BOXAPIFolderIDRoot, fromLocalFilePath: filePath.path)
            uploadRequest?.fileName = filePath.lastPathComponent
            
            uploadRequest?.perform(progress: { (totalBytesTransferred, totalBytesExpectedToTransfer) in

            }, completion: { (file, error) in
                count += 1
                if numOfUrl == count{
                    self.uploadDidFinish()
                }
            })
            
            requests?.append(uploadRequest!)
        }
    }
    
    func boxCancelUploads(){
        if let requests = requests {
            for request in requests{
                request.cancel()
            }
        }
    }
}

fileprivate var requests: Array<BOXFileUploadRequest>?
