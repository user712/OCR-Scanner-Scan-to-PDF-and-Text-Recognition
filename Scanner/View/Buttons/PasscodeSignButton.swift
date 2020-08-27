//
//  PasscodeSignButton.swift
//  Scanner
//
//   on 1/25/17.
//   
//

import UIKit

class PasscodeSignButton: UIButton {
    
    // MARK: - Initializers
    
    var passcodeSign: String = "1"
    
    override var intrinsicContentSize : CGSize {
        return CGSize(width: 60, height: 60)
    }
    
    fileprivate var defaultBackgroundColor = UIColor.clear
    
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupActions()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupActions()
    }
}


// MARK: - Setup Views

extension PasscodeSignButton {
    
    fileprivate func setupActions() {
        addTarget(self, action: #selector(PasscodeSignButton.handleTouchDown), for: .touchDown)
        addTarget(self, action: #selector(PasscodeSignButton.handleTouchUp), for: [.touchUpInside, .touchDragOutside, .touchCancel])
    }
    
    func handleTouchDown() {
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0.0,
                       options: [.allowUserInteraction, .beginFromCurrentState], animations: { [unowned self] in
                        self.setTitleColor(UIColor.darkSkyBlue, for: .highlighted)
            },
                       completion: nil
        )
    }
    
    func handleTouchUp() {
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0.0,
                       options: [.allowUserInteraction, .beginFromCurrentState], animations: { [unowned self] in
                        self.setTitleColor(UIColor.gri, for: .normal)
            },
                       completion: nil
        )
    }
}
