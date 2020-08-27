//
//  PasscodeSignPlaceholderView.swift
//  Scanner
//
//   on 1/25/17.
//   
//

import UIKit

class PasscodeSignPlaceholderView: UIView {
    
    // MARK: - Nested Types
    
    public enum State {
        case inactive
        case active
        case error
    }
    
    
    // MARK: - Properties
    
    var inactiveColor: UIColor = UIColor.white {
        didSet {
            setupView()
        }
    }
    
    var activeColor: UIColor = UIColor.gray {
        didSet {
            setupView()
        }
    }
    
    var errorColor: UIColor = UIColor.red {
        didSet {
            setupView()
        }
    }
    
    override var intrinsicContentSize : CGSize {
        return CGSize(width: 16, height: 16)
    }
    
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


// MARK: - Setup Views

extension PasscodeSignPlaceholderView {
    
    fileprivate func setupView() {
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = activeColor.cgColor
        backgroundColor = inactiveColor
    }
    
    fileprivate func colorsForState(_ state: State) -> (backgroundColor: UIColor, borderColor: UIColor) {
        switch state {
        case .inactive: return (inactiveColor, activeColor)
        case .active: return (activeColor, activeColor)
        case .error: return (errorColor, errorColor)
        }
    }
    
    func animateState(_ state: State) {
        let colors = colorsForState(state)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations: { [unowned self] in
            self.backgroundColor = colors.backgroundColor
            self.layer.borderColor = colors.borderColor.cgColor
            },
                       completion: nil
        )
    }
}
