//
//  OneDriveAutorizable.swift
//  iScanner
//


import OneDriveSDK
import ADAL
import Foundation

enum OneDriveManagerResult {
    case success
    case failure(OneDriveAPIError)
}

enum OneDriveAPIError: Error {
    case resourceNotFound
    case jsonParseError
    case unspecifiedError(URLResponse?)
    case generalError(Error?)
}



protocol OneDriveAutorizable {
    var authorityURL: String { get }
    var clientID: String { get }
    var redirectURL: String { get }
    
    func signIn()
    func upload()
}


extension OneDriveAutorizable {
    
    var authorityURL: String {
        return "https://login.microsoftonline.com/common"
    }
    
    var clientID: String {
        return "990055b0-57dc-4d88-8035-3f2399e4c9ba"
    }
    
    var redirectURL: String {
        return "http://localhost"
    }
}



extension OneDriveAutorizable {
    
    func acquireToken(completion: @escaping (_ userInfo: ADUserInformation?, _ accessToken: String?, _ error: NSError?) -> Void) {
        if let authContext = ADAuthenticationContext(authority: authorityURL, error: nil) {
            authContext.acquireToken(
                withResource: self.clientID,
                clientId: clientID,
                redirectUri: NSURL(string: self.redirectURL) as URL!,
                promptBehavior: AD_PROMPT_AUTO,
                userId: nil,
                extraQueryParameters: "",
                completionBlock: { (result) in
                    if (result?.status != AD_SUCCEEDED) {
                        completion(nil,
                                   nil,
                                   result?.error)
                    } else {
                        completion(result?.tokenCacheStoreItem.userInformation,
                                   result?.accessToken,
                                   nil)
                    }
            })
        }
    }
    
    func signIn() {
        self.acquireToken { (userInfo, accessToken, error) in
            
            if let _userInfo = userInfo {
                DispatchQueue.main.sync(execute: {
                    print("Welcome \(_userInfo.givenName) \(_userInfo.familyName)")
                    print("Access Token: \(String(describing: accessToken))")
                })
            }
            
            if let _error = error {
                print("Error : \(_error.localizedDescription)")
            }
        }
    }
    
    func upload() {
//        let client = ODClient(url: <#T##String!#>, httpProvider: <#T##ODHttpProvider!#>, authProvider: <#T##ODAuthProvider!#>)
        ODClient.client { (client, error) in
            if let client = client {
                print(client.baseURL)
            }
        }
    }
}
