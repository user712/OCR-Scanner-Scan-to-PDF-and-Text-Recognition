//
//  App.swift
//  Scanner
//
//   
//   
//

import Foundation

class App: NSObject {
    
    // MARK: - Properties
    
    var id: NSNumber?
    var name: String?
    var category: String?
    var imageName: String?
    var type: ShareAppType = .none
}



class ShareAppCategory: NSObject {
    
    // MARK: - Properties
    
    var apps: [App]?
}


extension ShareAppCategory {
    
    static func sampleAppCategory() -> [ShareAppCategory] {
        /// 1
        let emailCategory = ShareAppCategory()
        var emailApps = [App]()
        
        let cleanEmailApp = App()
        cleanEmailApp.name = "Email".localized()
        cleanEmailApp.imageName = "shareMail"
        cleanEmailApp.type = .eMail
        
        let sendAsJPGApp = App()
        sendAsJPGApp.name = "Send as jpg".localized()
        sendAsJPGApp.imageName = "sendJPG"
        sendAsJPGApp.type = .eMailJPG
        
        emailApps.append(cleanEmailApp)
        emailApps.append(sendAsJPGApp)
        
        emailCategory.apps = emailApps
        
        /// 2
        let devicesCategory = ShareAppCategory()
        var devicesApps = [App]()
        
        let openAsApp = App()
        openAsApp.name = "Open as...".localized()
        openAsApp.imageName = "icOpenIn"
        openAsApp.type = .openAs
        
        let printApp = App()
        printApp.name = "Print".localized()
        printApp.imageName = "icPrint"
        printApp.type = .print
        
        devicesApps.append(openAsApp)
        devicesApps.append(printApp)
        
        devicesCategory.apps = devicesApps
        
        /// 3
        let socialCloudsCategory = ShareAppCategory()
        var socialApps = [App]()
        
        let dropboxApp = App()
        dropboxApp.name = "Dropbox"
        dropboxApp.imageName = "icDropBox"
        dropboxApp.type = .dropBox
        
        let googleDriveApp = App()
        googleDriveApp.name = "GoogleDrive"
        googleDriveApp.imageName = "icGoogleDrive"
        googleDriveApp.type = .googleDrive
        
        let evernoteApp = App()
        evernoteApp.name = "Evernote"
        evernoteApp.imageName = "icEvernote"
        evernoteApp.type = .evernote
        
        let iCloudApp = App()
        iCloudApp.name = "iCloud"
        iCloudApp.imageName = "iCloud"
        iCloudApp.type = .iCloud
        
        let yandexApp = App()
        yandexApp.name = "Yandex Disk"
        yandexApp.imageName = "icYadi"
        yandexApp.type = .yandexDisk
        
        let boxApp = App()
        boxApp.name = "Box"
        boxApp.imageName = "icBox"
        boxApp.type = .box
        
        socialApps.append(iCloudApp)
        socialApps.append(dropboxApp)
        socialApps.append(googleDriveApp)
        socialApps.append(evernoteApp)
        socialApps.append(yandexApp)
        socialApps.append(boxApp)
        
        socialCloudsCategory.apps = socialApps
        
        return [emailCategory, devicesCategory, socialCloudsCategory]
    }
}
