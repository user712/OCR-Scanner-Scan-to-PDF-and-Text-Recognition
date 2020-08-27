//
//  AppDelegate.swift
//  Scanner
//
//  
//   
//

import UIKit
import Fabric
import Crashlytics
import ObjectiveDropboxOfficial

@UIApplicationMain
class AppDelegate: UIResponder, ApplicationStarteable {

    // MARK: - Properties
    
    var window: UIWindow?
    
    var initialPath: URL? {
        return URL(string: "Scanner")
    }
    
    fileprivate lazy var passcodeLockPresenter: PasscodeLockPresenter = {
        let configuration = PasscodeLockConfiguration()
        let presenter = PasscodeLockPresenter(mainWindow: self.window, configuration: configuration)
        
        return presenter
    }()
}


// MARK: - UIApplicationDelegate, DropboxAutorizable, BoxAutorizable, EvernoteAutorizable

extension AppDelegate: UIApplicationDelegate, DropboxAutorizable, BoxAutorizable, EvernoteAutorizable, GoogleDriveProtocol {
    func serviceAuthenticated(appType: ShareAppType, succes: Bool) {}
    func uploadDidFinish() {}
    func uploadDidStart() {}
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        /// Fabric&Crashlytics
        Fabric.with([Crashlytics.self])
        
        /// Override point for customization after application launch.
        loadMainViewControllerWithInitialPath(andUIWindow: &window)
//        downloadOCREnglishLanguage()
        
        ///
        dropBoxDidFinishLaunchingWithOptions()
        
        ///
        boxDidFinishLaunchingWithOptions()
        
        ///
        evernoteDidFinishLaunchingWithOptions()
        
        ///
        configureGoogleSignIn()
        
        /// Passcode
        passcodeLockPresenter.presentPasscodeLock()
        
        ///
        AppInfo.sharedManager().update(completion: nil)
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return handleUrl(app: application, url: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        return handleUrl(app: app, url: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
    
    
    //MARK: handle urls
    private func handleUrl(app: UIApplication, url: URL, sourceApplication: String?, annotation: Any?) -> Bool{
        if let scheme = url.scheme {
            switch scheme {
            case "com.googleusercontent.apps.476943659107-fum4slcqj80lo7j1sn6jipncob0i1mou":
                return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
            case "en-mike11016":
                return evernoteApplicationHandleOpen(url)
            case "db-tjd71369p448ltx":
                return dropBoxApplication(app, handleOpenURL: url)
            default:
                return false
            }
        }
        
        return false
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        passcodeLockPresenter.presentPasscodeLock()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        

    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        let isDropboxOpen = dropBoxApplication(application, handleOpenURL: url)
        let isEvernoteOpen = evernoteApplicationHandleOpen(url)
        
        if isDropboxOpen && isEvernoteOpen {
            return true
        } else {
            return false
        }
    }
}
