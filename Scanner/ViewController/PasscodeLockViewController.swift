//
//  PasscodeLockViewController.swift
//  Scanner
//
//   on 1/25/17.
//   
//

import UIKit

class PasscodeLockViewController: UIViewController {
    
    // MARK: - Nested Types
    
    enum LockState {
        case enterPasscode
        case setPasscode
        case changePasscode
        case removePasscode
        
        func getState() -> PasscodeLockStateType {
            
            switch self {
            case .enterPasscode: return EnterPasscodeState()
            case .setPasscode: return SetPasscodeState()
            case .changePasscode: return ChangePasscodeState()
            case .removePasscode: return EnterPasscodeState(allowCancellation: true)
            }
        }
    }
    
    
    // MARK: - Properties
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var descriptionLabel: UILabel?
    @IBOutlet var placeholders = [PasscodeSignPlaceholderView]()
    @IBOutlet weak var cancelButton: UIButton?
    @IBOutlet weak var deleteSignButton: UIButton?
    @IBOutlet weak var touchIDButton: UIButton?
    @IBOutlet weak var placeholdersX: NSLayoutConstraint?
    
    var successCallback: ((_ lock: PasscodeLockType) -> ())?
    var dismissCompletionCallback: (()->Void)?
    var animateOnDismiss: Bool
    var notificationCenter: NotificationCenter?
    
    internal let passcodeConfiguration: PasscodeLockConfigurationType
    internal var passcodeLock: PasscodeLockType
    internal var isPlaceholdersAnimationCompleted = true
    
    fileprivate var shouldTryToAuthenticateWithBiometrics = true
    
    
    // MARK: - Initializers
    
    init(state: PasscodeLockStateType, configuration: PasscodeLockConfigurationType, animateOnDismiss: Bool = true) {
        
        self.animateOnDismiss = animateOnDismiss
        
        passcodeConfiguration = configuration
        passcodeLock = PasscodeLock(state: state, configuration: configuration)
        
        let nibName = "PasscodeLockView"
        let bundle: Bundle = bundleForResource(nibName, ofType: "nib")
        
        super.init(nibName: nibName, bundle: bundle)
        
        passcodeLock.delegate = self
        notificationCenter = NotificationCenter.default
    }
    
    convenience init(state: LockState, configuration: PasscodeLockConfigurationType, animateOnDismiss: Bool = true) {
        
        self.init(state: state.getState(), configuration: configuration, animateOnDismiss: animateOnDismiss)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Deinitializers
    
    deinit {
        clearEvents()
    }
    
    
    // MARK: - LyfeCicle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        updatePasscodeView()
        deleteSignButton?.isEnabled = false
        setupEvents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if shouldTryToAuthenticateWithBiometrics {
            authenticateWithBiometrics()
        }
    }
}


// MARK: - Setup Views & Authentification

extension PasscodeLockViewController {
    
    internal func updatePasscodeView() {
        titleLabel?.text = passcodeLock.state.title
        descriptionLabel?.text = passcodeLock.state.description
        cancelButton?.isHidden = !passcodeLock.state.isCancellableAction
        touchIDButton?.isHidden = !passcodeLock.isTouchIDAllowed
    }
    
    fileprivate func authenticateWithBiometrics() {
        if passcodeConfiguration.shouldRequestTouchIDImmediately && passcodeLock.isTouchIDAllowed {
            passcodeLock.authenticateWithBiometrics()
        }
    }
    
    internal func dismissPasscodeLock(_ lock: PasscodeLockType, completionHandler: (() -> ())? = nil) {
        /// if presented as modal
        if presentingViewController?.presentedViewController == self {
            dismiss(animated: animateOnDismiss, completion: { [unowned self] _ in
//                self.dismissCompletionCallback?()
                print(self)
                completionHandler?()
            })
            
            return
            
            // if pushed in a navigation controller
        } else if navigationController != nil {
            _ = navigationController?.popViewController(animated: animateOnDismiss)
        }
        
        dismissCompletionCallback?()
        completionHandler?()
    }

}


// MARK: - Animations

extension PasscodeLockViewController {
    
    internal func animateWrongPassword() {
        deleteSignButton?.isEnabled = false
        isPlaceholdersAnimationCompleted = false
        animatePlaceholders(placeholders, toState: .error)
        placeholdersX?.constant = -40
        view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0, options: [], animations: { [unowned self] in
            self.placeholdersX?.constant = 0
            self.view.layoutIfNeeded()
            }, completion: { [unowned self] completed in
                self.isPlaceholdersAnimationCompleted = true
                self.animatePlaceholders(self.placeholders, toState: .inactive)
        })
    }
    
    internal func animatePlaceholders(_ placeholders: [PasscodeSignPlaceholderView], toState state: PasscodeSignPlaceholderView.State) {
        for placeholder in placeholders {
            placeholder.animateState(state)
        }
    }
    
    fileprivate func animatePlacehodlerAtIndex(_ index: Int, toState state: PasscodeSignPlaceholderView.State) {
        guard index < placeholders.count && index >= 0 else { return }
        placeholders[index].animateState(state)
    }
}


// MARK: - Events

extension PasscodeLockViewController {
    
    fileprivate func setupEvents() {
        notificationCenter?.addObserver(self, selector: #selector(PasscodeLockViewController.appWillEnterForegroundHandler(_:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        notificationCenter?.addObserver(self, selector: #selector(PasscodeLockViewController.appDidEnterBackgroundHandler(_:)), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    fileprivate func clearEvents() {
        notificationCenter?.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        notificationCenter?.removeObserver(self, name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    func appWillEnterForegroundHandler(_ notification: Notification) {
        authenticateWithBiometrics()
    }
    
    func appDidEnterBackgroundHandler(_ notification: Notification) {
        shouldTryToAuthenticateWithBiometrics = false
    }

}


// MARK: - Actions

extension PasscodeLockViewController {
    
    @IBAction func passcodeSignButtonTap(_ sender: PasscodeSignButton) {
        guard isPlaceholdersAnimationCompleted else { return }
        passcodeLock.addSign(sender.passcodeSign)
    }
    
    @IBAction func cancelButtonTap(_ sender: UIButton) {
        dismissPasscodeLock(passcodeLock)
        self.dismissCompletionCallback?()
    }
    
    @IBAction func deleteSignButtonTap(_ sender: UIButton) {
        passcodeLock.removeSign()
    }
    
    @IBAction func touchIDButtonTap(_ sender: UIButton) {
        passcodeLock.authenticateWithBiometrics()
    }
}


// MARK: - PasscodeLockTypeDelegate

extension PasscodeLockViewController: PasscodeLockTypeDelegate {
    
    func passcodeLockDidSucceed(_ lock: PasscodeLockType) {
        deleteSignButton?.isEnabled = true
        animatePlaceholders(placeholders, toState: .inactive)
        dismissPasscodeLock(lock, completionHandler: { [unowned self] _ in
            self.successCallback?(lock)
        })
    }
    
    func passcodeLockDidFail(_ lock: PasscodeLockType) {
        animateWrongPassword()
    }
    
    func passcodeLockDidChangeState(_ lock: PasscodeLockType) {
        updatePasscodeView()
        animatePlaceholders(placeholders, toState: .inactive)
        deleteSignButton?.isEnabled = false
    }
    
    func passcodeLock(_ lock: PasscodeLockType, addedSignAtIndex index: Int) {
        animatePlacehodlerAtIndex(index, toState: .active)
        deleteSignButton?.isEnabled = true
    }
    
    func passcodeLock(_ lock: PasscodeLockType, removedSignAtIndex index: Int) {
        animatePlacehodlerAtIndex(index, toState: .inactive)
        if index == 0 {
            deleteSignButton?.isEnabled = false
        }
    }
}
