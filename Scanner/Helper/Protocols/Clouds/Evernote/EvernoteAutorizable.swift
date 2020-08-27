//
//  EvernoteAutorizable.swift
//  iScanner
//

import Foundation
import EvernoteSDK


protocol EvernoteAutorizable: ServiceUploadProtocol {
//    var evernoteSharedSession: ENSession { get }
}


extension EvernoteAutorizable {
    
    var evernoteSharedSession: ENSession {
        return ENSession.shared
    }
    
    private var clientID: String {
        return "mike11016"
    }
    
    private var clientSecretKey: String {
        return "b454e2ae142e3b51"
    }
    
    private var host: String {
//        return ENSessionHostSandbox
        return "www.evernote.com"
    }
    
    func evernoteDidFinishLaunchingWithOptions() {
        ENSession.setSharedSessionConsumerKey(clientID, consumerSecret: clientSecretKey, optionalHost: host)
    }
    
    func evernoteApplicationHandleOpen(_ url: URL) -> Bool {
        return evernoteSharedSession.handleOpenURL(url)
        
    }
    
    func evernoteAuthenticate(targetController: UIViewController){
        evernoteSharedSession.authenticate(with: targetController, preferRegistration: false, completion: { (_error: Error?) in
            if let _ = _error {
                self.serviceAuthenticated(appType: .evernote, succes: false)
            }else{
                self.serviceAuthenticated(appType: .evernote, succes: true)
            }
        })
    }
    
    func evernoteLogout(){
        evernoteSharedSession.unauthenticate()
        serviceAuthenticated(appType: .evernote, succes: false)
    }
    
    func evernoteIsAuthenticated() -> Bool{
        return evernoteSharedSession.isAuthenticated
    }
}
