//
//  DropboxAutorizable.swift
//  iScanner
//

import Foundation
import ObjectiveDropboxOfficial

protocol DropboxAutorizable: ServiceUploadProtocol {
    
}

extension DropboxAutorizable {
    
    var dropboxClient: DBUserClient? {
        return DBClientsManager.authorizedClient()
    }
    
    func dropBoxDidFinishLaunchingWithOptions() {
        DBClientsManager.setup(withAppKey: "tjd71369p448ltx")
    }
    
    func dropBoxApplication(_ application: UIApplication, handleOpenURL url: URL) -> Bool {
        let authResult = DBClientsManager.handleRedirectURL(url)
        
        if let authResultUnwrapped = authResult {
            if authResultUnwrapped.isSuccess() {
                print("Success! User is logged into Dropbox.")
                serviceAuthenticated(appType: .dropBox, succes: true)
                return true
            } else if authResultUnwrapped.isCancel() {
                print("Authorization flow was manually canceled by user!");
                serviceAuthenticated(appType: .dropBox, succes: false)
            } else if authResultUnwrapped.isError() {
                print("Error = \(authResultUnwrapped.errorDescription)")
                serviceAuthenticated(appType: .dropBox, succes: false)
            }
        }
        
        return false
    }
    
    func dropboxAutorize(targetController: UIViewController) {
        DBClientsManager.authorize(fromController: UIApplication.shared, controller: targetController) { (url) in
            UIApplication.shared.openURL(url)
        }
    }
    
    func dropboxLogOut() {
        DBClientsManager.unlinkAndResetClients()
        serviceAuthenticated(appType: .dropBox, succes: false)
    }
}
