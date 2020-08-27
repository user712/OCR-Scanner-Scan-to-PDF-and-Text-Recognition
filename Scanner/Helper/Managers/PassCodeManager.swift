//
//  PassCodeManager.swift
//  Scanner
//
//   on 1/25/17.
//   
//

import Foundation
import LocalAuthentication

func localizedStringFor(_ key: String, comment: String) -> String {
    
    let name = "Localizable"
    let bundle = bundleForResource(name, ofType: "strings")
    
    return NSLocalizedString(key, tableName: name, bundle: bundle, comment: comment)
}

func bundleForResource(_ name: String, ofType type: String) -> Bundle {
    
    if(Bundle.main.path(forResource: name, ofType: type) != nil) {
        return Bundle.main
    }
    
    return Bundle(for: PasscodeLock.self)
}


protocol PasscodeRepositoryType {
    
    var hasPasscode: Bool { get }
    var passcode: [String]? { get }
    
    func savePasscode(_ passcode: [String])
    func deletePasscode()
}

protocol PasscodeLockStateType {
    var title: String { get }
    var description: String { get }
    var isCancellableAction: Bool { get }
    var isTouchIDAllowed: Bool { get }
    
    mutating func acceptPasscode(_ passcode: [String], fromLock lock: PasscodeLockType)
}

protocol PasscodeLockConfigurationType {
    var repository: PasscodeRepositoryType { get }
    var passcodeLength: Int { get }
    var isTouchIDAllowed: Bool {get set}
    var shouldRequestTouchIDImmediately: Bool { get }
    var maximumInccorectPasscodeAttempts: Int { get }
}

protocol PasscodeLockType {
    weak var delegate: PasscodeLockTypeDelegate? { get set }
    var configuration: PasscodeLockConfigurationType { get }
    var repository: PasscodeRepositoryType { get }
    var state: PasscodeLockStateType { get }
    var isTouchIDAllowed: Bool { get }
    
    func addSign(_ sign: String)
    func removeSign()
    func changeStateTo(_ state: PasscodeLockStateType)
    func authenticateWithBiometrics()
}

protocol PasscodeLockTypeDelegate: class {
    func passcodeLockDidSucceed(_ lock: PasscodeLockType)
    func passcodeLockDidFail(_ lock: PasscodeLockType)
    func passcodeLockDidChangeState(_ lock: PasscodeLockType)
    func passcodeLock(_ lock: PasscodeLockType, addedSignAtIndex index: Int)
    func passcodeLock(_ lock: PasscodeLockType, removedSignAtIndex index: Int)
}


// MARK: - PasscodeLock

class PasscodeLock: PasscodeLockType {
    
    // MARK: - Properties
    
    weak var delegate: PasscodeLockTypeDelegate?
    let configuration: PasscodeLockConfigurationType
    
    var repository: PasscodeRepositoryType {
        return configuration.repository
    }
    
    var state: PasscodeLockStateType {
        return lockState
    }
    
    var isTouchIDAllowed: Bool {
        return isTouchIDEnabled() && configuration.isTouchIDAllowed && lockState.isTouchIDAllowed
    }
    
    fileprivate var lockState: PasscodeLockStateType
    fileprivate lazy var passcode = [String]()
    
    
    // MARK: - Initializers
    
    init(state: PasscodeLockStateType, configuration: PasscodeLockConfigurationType) {
        precondition(configuration.passcodeLength > 0, "Passcode length sould be greather than zero.")
        
        self.lockState = state
        self.configuration = configuration
    }
    
    
    // MARK: - Helper Methods
    
    func addSign(_ sign: String) {
        passcode.append(sign)
        delegate?.passcodeLock(self, addedSignAtIndex: passcode.count - 1)
        
        if passcode.count >= configuration.passcodeLength {
            lockState.acceptPasscode(passcode, fromLock: self)
            passcode.removeAll(keepingCapacity: true)
        }
    }
    
    func removeSign() {
        guard passcode.count > 0 else { return }
        passcode.removeLast()
        delegate?.passcodeLock(self, removedSignAtIndex: passcode.count)
    }
    
    func changeStateTo(_ state: PasscodeLockStateType) {
        lockState = state
        delegate?.passcodeLockDidChangeState(self)
    }
    
    func authenticateWithBiometrics() {
        guard isTouchIDAllowed else { return }
        let context = LAContext()
        let reason = localizedStringFor("PasscodeLockTouchIDReason", comment: "TouchID authentication reason")
        
        context.localizedFallbackTitle = localizedStringFor("PasscodeLockTouchIDButton", comment: "TouchID authentication fallback button")
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [unowned self] success, error in
            self.handleTouchIDResult(success)
        }
    }
    
    fileprivate func handleTouchIDResult(_ success: Bool) {
        DispatchQueue.main.async { [unowned self] in
            if success {
                self.delegate?.passcodeLockDidSucceed(self)
            }
        }
    }
    
    fileprivate func isTouchIDEnabled() -> Bool {
        let context = LAContext()
        
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
}


// MARK: - #2

private let PasscodeLockIncorrectPasscodeNotification = "passcode.lock.incorrect.passcode.notification"


// MARK: - EnterPasscodeState

struct EnterPasscodeState: PasscodeLockStateType {
    
    // MARK: - Properties
    
    let title: String
    let description: String
    let isCancellableAction: Bool
    var isTouchIDAllowed = true
    
    fileprivate var inccorectPasscodeAttempts = 0
    fileprivate var isNotificationSent = false
    
    
    // MARK: - Initializers
    
    init(allowCancellation: Bool = false) {
        
        isCancellableAction = allowCancellation
        title = localizedStringFor("Confirm the passcode", comment: "Enter passcode title")
        description = localizedStringFor("", comment: "Enter passcode description") /// PasscodeLockEnterDescription
    }
    
    
    // MARK: - Helper Methods
    
    mutating func acceptPasscode(_ passcode: [String], fromLock lock: PasscodeLockType) {
        guard let currentPasscode = lock.repository.passcode else { return }
        
        if passcode == currentPasscode {
            lock.delegate?.passcodeLockDidSucceed(lock)
        } else {
            inccorectPasscodeAttempts += 1
            if inccorectPasscodeAttempts >= lock.configuration.maximumInccorectPasscodeAttempts {
                postNotification()
            }
            
            lock.delegate?.passcodeLockDidFail(lock)
        }
    }
    
    fileprivate mutating func postNotification() {
        guard !isNotificationSent else { return }
        let center = NotificationCenter.default
        center.post(name: Notification.Name(rawValue: PasscodeLockIncorrectPasscodeNotification), object: nil)
        isNotificationSent = true
    }
}



// MARK: - SetPasscodeState

struct SetPasscodeState: PasscodeLockStateType {
    
    // MARK: - Properties
    
    let title: String
    let description: String
    let isCancellableAction = true
    var isTouchIDAllowed = false
    
    
    // MARK: - Initializers
    
    init(title: String, description: String) {
        self.title = title
        self.description = description
    }
    
    init() {
        title = localizedStringFor("Enter passcode", comment: "Set passcode title")
        description = localizedStringFor("", comment: "Set passcode description") /// PasscodeLockSetDescription
    }
    
    
    // MARK: - Helper Methods
    
    func acceptPasscode(_ passcode: [String], fromLock lock: PasscodeLockType) {
        let nextState = ConfirmPasscodeState(passcode: passcode)
        lock.changeStateTo(nextState)
    }
}



// MARK: - ConfirmPasscodeState

struct ConfirmPasscodeState: PasscodeLockStateType {
    
    // MARK: - Properties
    
    let title: String
    let description: String
    let isCancellableAction = true
    var isTouchIDAllowed = false
    
    fileprivate var passcodeToConfirm: [String]
    
    
    // MARK: - Initializers
    
    init(passcode: [String]) {
        passcodeToConfirm = passcode
        title = localizedStringFor("Confirm the passcode", comment: "Confirm passcode title")
        description = localizedStringFor("", comment: "Confirm passcode description") /// PasscodeLockConfirmDescription
    }
    
    
    // MARK: - Helper Methods
    
    func acceptPasscode(_ passcode: [String], fromLock lock: PasscodeLockType) {
        if passcode == passcodeToConfirm {
            lock.repository.savePasscode(passcode)
            lock.delegate?.passcodeLockDidSucceed(lock)
        } else {
            let mismatchTitle = localizedStringFor("Incorrect passcode", comment: "Passcode mismatch title")
            let mismatchDescription = localizedStringFor("", comment: "Passcode mismatch description") /// PasscodeLockMismatchDescription
            let nextState = SetPasscodeState(title: mismatchTitle, description: mismatchDescription)
            lock.changeStateTo(nextState)
            lock.delegate?.passcodeLockDidFail(lock)
        }
    }
}


// MARK: - ChangePasscodeState

struct ChangePasscodeState: PasscodeLockStateType {
    
    // MARK: - Properties
    
    let title: String
    let description: String
    let isCancellableAction = true
    var isTouchIDAllowed = false
    
    // MARK: - Initializers
    
    init() {
        title = localizedStringFor("PasscodeLockChangeTitle", comment: "Change passcode title")
        description = localizedStringFor("PasscodeLockChangeDescription", comment: "Change passcode description")
    }
    
    
    // MARK: - Helper Methods
    
    func acceptPasscode(_ passcode: [String], fromLock lock: PasscodeLockType) {
        guard let currentPasscode = lock.repository.passcode else {  return }
        
        if passcode == currentPasscode {
            let nextState = SetPasscodeState()
            lock.changeStateTo(nextState)
        } else {
            lock.delegate?.passcodeLockDidFail(lock)
        }
    }
}


// MARK: - PasscodeLockPresenter

import UIKit

class PasscodeLockPresenter {
    
    // MARK: - Properties
    
    fileprivate var mainWindow: UIWindow?
    
    fileprivate lazy var passcodeLockWindow: UIWindow = {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.windowLevel = 0
        window.makeKeyAndVisible()
        
        return window
    }()
    
    fileprivate let passcodeConfiguration: PasscodeLockConfigurationType
    var isPasscodePresented = false
    let passcodeLockVC: PasscodeLockViewController
    
    
    // MARK: - Initializers
    
    init(mainWindow window: UIWindow?, configuration: PasscodeLockConfigurationType, viewController: PasscodeLockViewController) {
        mainWindow = window
        mainWindow?.windowLevel = 1
        passcodeConfiguration = configuration
        passcodeLockVC = viewController
    }
    
    convenience init(mainWindow window: UIWindow?, configuration: PasscodeLockConfigurationType) {
        let passcodeLockVC = PasscodeLockViewController(state: .enterPasscode, configuration: configuration)
        self.init(mainWindow: window, configuration: configuration, viewController: passcodeLockVC)
    }
    
    
    // MARK: - Helper Methods
    
    func presentPasscodeLock() {
        guard passcodeConfiguration.repository.hasPasscode else { return }
        guard !isPasscodePresented else { return }
        isPasscodePresented = true
        
        passcodeLockWindow.windowLevel = 2
        passcodeLockWindow.isHidden = false
        
        mainWindow?.windowLevel = 1
        mainWindow?.endEditing(true)
        
        let passcodeLockVC = PasscodeLockViewController(state: .enterPasscode, configuration: passcodeConfiguration)
        let userDismissCompletionCallback = passcodeLockVC.dismissCompletionCallback
        
        passcodeLockVC.dismissCompletionCallback = { [unowned self] in
            userDismissCompletionCallback?()
            self.dismissPasscodeLock()
        }
        
        passcodeLockWindow.rootViewController = passcodeLockVC
    }
    
    func dismissPasscodeLock(animated: Bool = true) {
        isPasscodePresented = false
        mainWindow?.windowLevel = 1
        mainWindow?.makeKeyAndVisible()
        
        if animated {
            animatePasscodeLockDismissal()
        } else {
            passcodeLockWindow.windowLevel = 0
            passcodeLockWindow.rootViewController = nil
        }
    }
    
    internal func animatePasscodeLockDismissal() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, animations: { [unowned self] in
            self.passcodeLockWindow.alpha = 0
            }, completion: { [unowned self] _ in
                self.passcodeLockWindow.windowLevel = 0
                self.passcodeLockWindow.rootViewController = nil
                self.passcodeLockWindow.alpha = 1
        })
    }
}


// MARK: - PasscodeLockConfiguration

struct PasscodeLockConfiguration: PasscodeLockConfigurationType {
    
    // MARK: - Properties
    
    let repository: PasscodeRepositoryType
    let passcodeLength = 4
    var isTouchIDAllowed = true
    let shouldRequestTouchIDImmediately = true
    let maximumInccorectPasscodeAttempts = -1
    
    
    // MARK: - Initializers
    
    init(repository: PasscodeRepositoryType) {
        self.repository = repository
    }
    
    init() {
        self.repository = KeychainPasscodeRepository()
    }
}


//// MARK: - UserDefaultsPasscodeRepository
//
//class UserDefaultsPasscodeRepository: PasscodeRepositoryType {
//    
//    // MARK: - Properties
//    
//    fileprivate let passcodeKey = "passcode.lock.passcode"
//    
//    fileprivate lazy var defaults: UserDefaults = {
//        return UserDefaults.standard
//    }()
//    
//    var hasPasscode: Bool {
//        if passcode != nil {
//            return true
//        }
//        
//        return false
//    }
//    
//    var passcode: [String]? {
//        return defaults.value(forKey: passcodeKey) as? [String] ?? nil
//    }
//    
//    
//    // MARK: - Helper Methods
//    
//    func savePasscode(_ passcode: [String]) {
//        defaults.set(passcode, forKey: passcodeKey)
//        defaults.synchronize()
//    }
//    
//    func deletePasscode() {
//        defaults.removeObject(forKey: passcodeKey)
//        defaults.synchronize()
//    }
//}


// MARK: - KeychainPasscodeRepository

class KeychainPasscodeRepository: PasscodeRepositoryType {
    
    // MARK: - Properties
    
    fileprivate let passcodeKey = "passcode.lock.passcode"
    
    fileprivate lazy var defaults: Keychain = {
        return Keychain.default
    }()
}


// MARK: - Helper Methods

extension KeychainPasscodeRepository {
    
    var hasPasscode: Bool {
        if passcode != nil {
            return true
        }
        
        return false
    }
    
    var passcode: [String]? {
        do {
            return try defaults.getValue(forKey: passcodeKey) as? [String]
        } catch {
            print(error)
        }
        
        return nil
    }
    
    
    // MARK: - Helper Methods
    
    func savePasscode(_ passcode: [String]) {
        do {
           try defaults.setValue(passcode, forKey: passcodeKey)
        } catch {
            print(error)
        }
    }
    
    func deletePasscode() {
        defaults.remove(passcodeKey)
    }
}


protocol Passcodeable {
    var configuration: PasscodeLockConfigurationType { get }
}

extension Passcodeable {
    
    var configuration: PasscodeLockConfigurationType {
        let repository = KeychainPasscodeRepository()
        let configuration = PasscodeLockConfiguration(repository: repository)
        
        return configuration
    }
}
