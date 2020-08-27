//
//  BoxAutorizable.swift
//  iScanner
//

import BoxContentSDK
import Foundation

protocol BoxAutorizable: ServiceUploadProtocol {
    
}

extension BoxAutorizable {
    
    private var clientID: String {
        return "im2yt8wqqih5qxcypcimq1jc5zb3zaq4"
    }
    
    private var clientSecretKey: String {
        return "YKD97pRqpuwQlMG8Jno9bZXFguYqXl0Q"
    }
    
    private var boxContentClient: BOXContentClient {
        return BOXContentClient.default()
    }
    
    func boxDidFinishLaunchingWithOptions() {
        BOXContentClient.setClientID(clientID, clientSecret: clientSecretKey)
    }
    
    func boxAuthenticate() {
        let contentClient = BOXContentClient.default()
        contentClient?.authenticate(completionBlock: {( user, error) -> Void in
            if error == nil {
                if let _ = user {
                    self.serviceAuthenticated(appType: .box, succes: true)
                }else{
                    self.serviceAuthenticated(appType: .box, succes: false)
                }
            }else{
                self.serviceAuthenticated(appType: .box, succes: false)
            }
        })
    }
    
    func boxIsAuthenticated() -> Bool{
        return boxContentClient.session.isAuthorized()
    }

    func boxLogOutBox() {
        boxContentClient.logOut()
        serviceAuthenticated(appType: .box, succes: false)
    }
}
