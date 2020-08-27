//
//  ServiceUploadProtocol.swift
//  Scanner
//
//  Created  on 6/14/17.
//   
//

import Foundation


protocol ServiceUploadProtocol {
    func uploadDidStart()
    func uploadDidFinish()
    func serviceAuthenticated(appType: ShareAppType, succes: Bool)
}
