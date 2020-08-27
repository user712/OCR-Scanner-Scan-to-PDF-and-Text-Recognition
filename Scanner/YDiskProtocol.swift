//
//  YDiskProtocol.swift
//  Scanner
//
//  Created  on 6/12/17.
//   
//

import Foundation

private let yDiskWraper = YDiskWraper()


protocol YDiskProtocol: ServiceUploadProtocol {
    
}


extension YDiskProtocol{
    func YDiskIsAuthenticated() -> Bool{
        return yDiskWraper.isAuthenticated()
    }
    
    func YDiskAuthenticate(targetController: UIViewController){
        yDiskWraper.authenticate(targetController: targetController)
        yDiskWraper.authenticationCallback = {(succes) in
            self.serviceAuthenticated(appType: .yandexDisk, succes: succes)
        }
    }
    
    func YDiskLogOut(){
        yDiskWraper.logOut()
    }
    
    func YDiskUploadFile(filePaths: [URL]){
        yDiskWraper.uploadFiles(filePaths: filePaths)
        uploadDidStart()
        
        yDiskWraper.uploadFinishedCallback = {
            self.uploadDidFinish()
        }
    }
    
    func YDiskCancelUploads(){
        yDiskWraper.cancelUploads()
    }
}


private class YDiskWraper: NSObject, YDSessionDelegate, YOAuth2Delegate, UserDefaultable {
    
    var authenticationCallback: (_ succes: Bool)->Void = {_ in }
    var uploadFinishedCallback: ()->Void = {_ in }
    
    private lazy var session: YDSession = {
        let session: YDSession = YDSession(delegate: self)
        if let token = UserDefaults.standard.string(forKey: "yandextoken"){
            session.oAuthToken = token
        }
        return session
    }()
    
    private var navAuthVC: UINavigationController?
    
    func authenticate(targetController: UIViewController){
        let authVC = YOAuth2ViewController(delegate: self)
        navAuthVC = UINavigationController(rootViewController: authVC!)
        
        targetController.present(navAuthVC!, animated: true, completion: nil)
    }
    
    func isAuthenticated() -> Bool{
        if let token = userDefaultsGetValue("yandextoken") as? String {
            return token.length() > 0
        }
        return false
    }
    
    func logOut(){
        userDefaultsRemoveObject("yandextoken")
    }
    
    func uploadFiles(filePaths: [URL]){
        let numOfUrl = filePaths.count
        var count = 0

        for filePath in filePaths{
            session.uploadFile(filePath.path, toPath: filePath.lastPathComponent) { (error) in
                count += 1
                if numOfUrl == count{
                    self.uploadFinishedCallback()
                }
            }
        }
    }
    
    func cancelUploads(){
        session.cancelAllRequests()
    }
    
    //MARK: delegates
    func oAuthLoginSucceeded(withToken token: String!) {
        session.oAuthToken = token
        userDefaultsSaveValue(token, key: "yandextoken")
        authenticationCallback(true)
        navAuthVC?.dismiss(animated: true, completion: nil)
    }
    
    func oAuthLoginFailedWithError(_ error: Error!) {
        authenticationCallback(false)
        print(error)
    }
    
    func clientID() -> String! {
        return "83c80eab278945f391430606b700b4b9"
    }
    
    func redirectURL() -> String! {
        return "https://oauth.yandex.ru/verification_code"
    }
    
    func userAgent() -> String! {
        return "Mozilla/5.0 (iPhone; U; CPU iPhone OS 3_0 like Mac OS X; en-us) AppleWebKit/528.18 (KHTML, like Gecko) Version/4.0 Mobile/7A341 Safari/528.16"
    }
}
