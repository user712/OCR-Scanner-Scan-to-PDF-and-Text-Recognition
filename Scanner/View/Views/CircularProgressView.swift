//
//  CircularProgressView.swift
//  Scanner
//
//   on 1/20/17.
//   
//

import UIKit

class CircularProgressView: UIView {
    
    // MARK: - Properties
    
    var padding:CGFloat = 20.0
    
    var progress: CGFloat {
        get {
            return mainArcLayer.strokeEnd
        }
        set {
            
            if (newValue > 1) {
                mainArcLayer.strokeEnd = 1
            } else if (newValue < 0) {
                mainArcLayer.strokeEnd = 0
            } else {
                mainArcLayer.strokeEnd = newValue
            }
        }
    }
    
    var textLabel: ProgressLabel?
    var placeholderProgress: CGFloat = 1.0
    
    var placeholderLineWidth: CGFloat = 2.0 {
        didSet {
            placeholderArcLayer.lineWidth = placeholderLineWidth
        }
    }
    
    var placeholderStrokeColor:UIColor = UIColor.paleGrey {
        didSet {
            placeholderArcLayer.strokeColor = placeholderStrokeColor.cgColor
        }
    }
    
    var lineWidth: CGFloat = 5.0 {
        didSet {
            mainArcLayer.lineWidth = lineWidth
        }
    }
    
    var lineCapStyle: String = kCALineCapRound {
        didSet {
            mainArcLayer.lineCap = lineCapStyle
        }
    }
    
    var strokeColor: UIColor = UIColor.darkSkyBlue {
        didSet {
            mainArcLayer.strokeColor = strokeColor.cgColor
        }
    }
    
    var fillColor: UIColor? = nil {
        didSet {
            if fillColor != nil {
                fillArcLayer.fillColor = fillColor!.cgColor
            }
        }
    }
    
    fileprivate var placeholderArcLayer = CAShapeLayer()
    fileprivate var mainArcLayer = CAShapeLayer()
    fileprivate var fillArcLayer = CAShapeLayer()
    
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        configure()
    }
    
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mainArcLayer.frame = bounds
        mainArcLayer.path = circlePath().cgPath
        
        placeholderArcLayer.frame = bounds
        placeholderArcLayer.path = circlePath().cgPath
        
        fillArcLayer.frame = bounds
        fillArcLayer.path = circlePath().cgPath
    }
}


// MARK: - Configuration

extension CircularProgressView {
    
    func configure() {
        progress = 0.00
        fillColor = self.backgroundColor
        
        fillArcLayer.frame = bounds
        fillArcLayer.fillColor = self.backgroundColor?.cgColor
        fillArcLayer.strokeEnd = 1
        layer.addSublayer(fillArcLayer)
        
        placeholderArcLayer.frame = bounds
        placeholderArcLayer.lineWidth = placeholderLineWidth
        placeholderArcLayer.fillColor = UIColor.clear.cgColor
        placeholderArcLayer.strokeColor = placeholderStrokeColor.cgColor
        placeholderArcLayer.strokeEnd = 1
        layer.addSublayer(placeholderArcLayer)
        
        mainArcLayer.frame = bounds
        mainArcLayer.lineWidth = lineWidth
        mainArcLayer.fillColor = UIColor.clear.cgColor
        mainArcLayer.strokeColor = strokeColor.cgColor
        mainArcLayer.lineCap = lineCapStyle
        layer.addSublayer(mainArcLayer)
        
        /// label
        self.textLabel = ProgressLabel(frame: CGRect(x: 0, y: 0, width: (bounds.size.width - padding), height: (bounds.size.height - padding)))
        self.textLabel?.center = CGPoint(x:bounds.midX, y:bounds.midY)
        self.textLabel?.backgroundColor = .clear
        self.textLabel?.textAlignment = .center
        self.textLabel?.font = UIFont.textStyleFontRegular(24.0)
        self.textLabel?.textColor = .paleGrey
        self.textLabel?.adjustsFontSizeToFitWidth = true
        self.textLabel?.minimumScaleFactor = 0.1
        self.textLabel?.numberOfLines = 1
        self.textLabel?.style = .percent
        self.textLabel?.text = "\(progress) %"
        addSubview(self.textLabel!)
        self.textLabel?.isHidden = true
    }
    
    func circleFrame() -> CGRect {
        var circleFrame = CGRect(x: 0, y: 0, width: (bounds.size.width - padding), height: (bounds.size.height - padding))
        circleFrame.origin.x = mainArcLayer.bounds.midX - circleFrame.midX
        circleFrame.origin.y = mainArcLayer.bounds.midY - circleFrame.midY
        return circleFrame
    }
    
    func circlePath() -> UIBezierPath {
        return UIBezierPath(roundedRect: circleFrame(), cornerRadius: bounds.size.width/2)
    }
    
    fileprivate func gradientMask() -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.locations = [0.2, 0.5, 1.0]
        
        let red: AnyObject = UIColor.red.cgColor
        let yellow: AnyObject = UIColor.yellow.cgColor
        let green: AnyObject = UIColor.green.cgColor
        let arrayOfColors: [AnyObject] = [green, yellow, red]
        gradientLayer.colors = arrayOfColors
        
        return gradientLayer
    }
}
