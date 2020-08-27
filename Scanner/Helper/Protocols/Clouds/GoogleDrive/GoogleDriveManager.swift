//
//  GoogleDriveManager.swift
//  iScanner
//


import UIKit
import Google.SignIn
import GoogleAPIClientForREST

private let gDriveObj = GoogleDriveManager()


protocol GoogleDriveProtocol: ServiceUploadProtocol {
    
}

extension GoogleDriveProtocol{
    func gDriveAuthorize(targetController: UINavigationController){
        gDriveObj.authorizeGoogleAccount(targetViewController: targetController)
        gDriveObj.authenticationCallback = {(succes) in
            self.serviceAuthenticated(appType: .googleDrive, succes: succes)
        }
    }
    
    func gDriveLogout(){
        gDriveObj.deAuthorizeUser()
        gDriveObj.authenticationCallback = {(succes) in
            self.serviceAuthenticated(appType: .googleDrive, succes: succes)
        }
    }
    
    func gDriveIsAuthorized() -> Bool {
        gDriveObj.authenticationCallback = {(succes) in
            self.serviceAuthenticated(appType: .googleDrive, succes: succes)
        }
        return gDriveObj.isAuthorized()
    }
    
    func gDriveUploadFiles(filePath: [URL]){
        uploadDidStart()
        
        gDriveObj.uploadImage(filePaths: filePath)
        gDriveObj.didFinishUploadCallback = {
            self.uploadDidFinish()
        }
    }
    
    func gDriveCancelUploads(){
        gDriveObj.cancelUploads()
    }
    
    func configureGoogleSignIn() {
        gDriveObj.configureGoogleSignIn()
    }
}


typealias statusMessageHandler = (_ success: Bool, _ errorMessage: String?) -> Void


private class GoogleDriveManager: NSObject, GIDSignInDelegate, GIDSignInUIDelegate {
    var authenticationCallback: (_ succes: Bool)->Void = {_ in }
    var didFinishUploadCallback: ()->Void = {_ in }
    var cancelUploadCallback: ()->Void = {_ in }
    
    fileprivate var tiketsArray: Array<GTLRServiceTicket>?
    
    // MARK: - Properties
    
    fileprivate let serviceDrive = GTLRDriveService()
    
    fileprivate let kKeyChainItemName = "iScanner Google Drive"
    fileprivate let kClientId = "999381134725-c82bglljdrp5h4n3ae7u10khifh658n3.apps.googleusercontent.com"
    fileprivate let scopes = [kGTLRAuthScopeDriveMetadata, kGTLRAuthScopeDriveFile]
    fileprivate let folderName = "iScanner"
    fileprivate var BLEFolder: GTLRDrive_File!
    fileprivate var targetViewController: UINavigationController?
    
    // MARK: - Initializers
    
    override init() {
        super.init()
        
        serviceDrive.isRetryEnabled = true
        var error: NSError?
        GGLContext.sharedInstance().configureWithError(&error)
        if (error != nil) {
            print(error!)
        }
        
        GIDSignIn.sharedInstance().scopes = (GIDSignIn.sharedInstance().scopes! as NSArray).addingObjects(from: scopes)
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            GIDSignIn.sharedInstance().signInSilently()
        }
    }
    
    func configureGoogleSignIn() {
        serviceDrive.isRetryEnabled = true
        var error: NSError?
        GGLContext.sharedInstance().configureWithError(&error)
        if (error != nil) {
            print(error!)
        }
    }
    
    // MARK: - Deinitializers
    
    deinit {
        // TODO: - Clean trash and references
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error) != nil {
            
            serviceDrive.authorizer = nil
            authenticationCallback(false)
        } else {
            serviceDrive.authorizer = user.authentication.fetcherAuthorizer()
            authenticationCallback(true)
        }
    }
    
    func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.default,
            handler: nil
        )
        alert.addAction(ok)
        
        let rootController = UIApplication.shared.keyWindow?.rootViewController
        rootController?.present(alert, animated: true, completion: nil)
    }
    
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        
    }
    
    // Present a view that prompts the user to sign in with Google
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        targetViewController?.present(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        viewController.dismiss(animated: true, completion: nil)
    }
}


extension GoogleDriveManager {
    func authorizeGoogleAccount(targetViewController: UINavigationController) {
        serviceDrive.isRetryEnabled = true
        
        self.targetViewController = targetViewController
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            GIDSignIn.sharedInstance().signInSilently()
        }else{
            GIDSignIn.sharedInstance().signIn()
        }
    }
    
    
    func isAuthorized() -> Bool {
        return serviceDrive.authorizer != nil
    }
    
    func deAuthorizeUser() {
        GIDSignIn.sharedInstance().signOut()
        serviceDrive.authorizer = nil
        authenticationCallback(false)
    }
}


// MARK: - Create folder

extension GoogleDriveManager {
    
    fileprivate func createFolder(_ completionHandler: @escaping statusMessageHandler) {
        let query = GTLRDriveQuery_FilesList.query()
        query.q = "mimeType = 'application/vnd.google-apps.folder' and trashed = false"
        serviceDrive.executeQuery(query) { [unowned self] (checkTicket, files, checkError) in
            if checkError != nil {
                completionHandler(false, "Folder can not be found".localized())
            } else {
                if let tempFileList = files as? GTLRDrive_FileList {
                    if let fileList = tempFileList.files {
                        var folderExisted = false
                        for folderFile in fileList {
                            if folderFile.name == self.folderName {
                                self.BLEFolder = folderFile
                                folderExisted = true
                                completionHandler(true, "Folder found".localized())
                                return
                            }
                        }
                        
                        if folderExisted == false {
                            let folder = GTLRDrive_File()
                            folder.name = self.folderName
                            folder.mimeType = "application/vnd.google-apps.folder"
                            let newFolderQuery = GTLRDriveQuery_FilesCreate.query(withObject: folder, uploadParameters: nil)
                            self.serviceDrive.executeQuery(newFolderQuery) {[unowned self] (ticket, updatedFile, error) in
                                if error == nil {
                                    if let properFile = updatedFile as? GTLRDrive_File {
                                        self.BLEFolder = properFile
                                        completionHandler(true, "Folder created successfully".localized())
                                    } else {
                                        completionHandler(false, "Failure".localized())
                                    }
                                } else {
                                    completionHandler(false, "Failure".localized())
                                }
                            }
                        }
                    } else {
                        completionHandler(false, "Incorrect type".localized())
                    }
                } else {
                    completionHandler(false, "Incorrect type".localized())
                }
            }
        }
    }
}


// MARK: - Upload image

extension GoogleDriveManager {
    
    func uploadImage(filePaths: [URL]) {
        tiketsArray = Array<GTLRServiceTicket>()
        
        createFolder { [unowned self] (success, errorMessage) in
            if success {
                let numOfUrl = filePaths.count
                var count = 0
                
                for filePath in filePaths{
                    let parameter = GTLRUploadParameters(data: filePath.toData!, mimeType: "image/jpg")
                    let driveFile = GTLRDrive_File()
                    driveFile.name = filePath.lastPathComponent
                    driveFile.parents = [self.BLEFolder.identifier!]
                    
                    let query = GTLRDriveQuery_FilesCreate.query(withObject: driveFile, uploadParameters: parameter)
                    let tiket = self.serviceDrive.executeQuery(query, completionHandler: { (tiket, data, error) in
                        count += 1
                        if numOfUrl == count{
                            self.didFinishUploadCallback()
                        }
                        if let error = error{
                            print(error)
                        }
                    })
                    self.tiketsArray?.append(tiket)
                }
            }
        }
    }
    
    func cancelUploads(){
        if let tiketsArray = tiketsArray {
            for tiket in tiketsArray {
                tiket.cancel()
            }
        }
    }
}
