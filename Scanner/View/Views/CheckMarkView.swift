//
//  CheckMarkView.swift
//  Scanner
//
//   on 1/24/17.
//   
//

import UIKit

class CheckMarkView: UIView {
    
    // MARK: - Nested types
    
    enum CheckMarkStyle: Int {
        case Nothing
        case OpenCircle
        case GrayedOut
    }
    
    
    // MARK: - Properties
    
    var isChecked: Bool {
        get {
            return _isChecked
        }
        set {
            _isChecked = newValue
            setNeedsDisplay()
        }
    }
    
    var style: CheckMarkStyle {
        get {
            return _style
        }
        set {
            _style = newValue
            setNeedsDisplay()
        }
    }
    
    fileprivate var _isChecked: Bool = false
    fileprivate var _style: CheckMarkStyle = .Nothing
}


// MARK: - Draw rect

extension CheckMarkView {
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if _isChecked {
            drawRectChecked(rect: rect)
        }
        else {
            if _style == .OpenCircle {
                drawRectOpenCircle(rect: rect)
            }
            else if _style == .GrayedOut {
                drawRectGrayedOut(rect: rect)
            }
        }
    }
}


// MARK: - Helper Methods

extension CheckMarkView {
    
    func drawRectChecked(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        let frame = self.bounds
        
        let checkmarkBlue = UIColor(red: 0.078, green: 0.435, blue: 0.875, alpha: 1)
        let shadow = UIColor.black
        let shadowOffset = CGSize(width: 0.1, height: -0.1)
        let shadowBlurRadius: CGFloat = 2.5
        
        let group = CGRect(x: frame.minX + 3, y: frame.minY + 3, width: frame.width - 6, height: frame.height - 6)
        
        let checkedOvalPath = UIBezierPath(ovalIn: CGRect(x: group.minX + floor(group.width * 0.00000 + 0.5), y: group.minY + floor(group.height * 0.00000 + 0.5), width: floor(group.width * 1.00000 + 0.5) - floor(group.width * 0.00000 + 0.5), height: floor(group.height * 1.00000 + 0.5) - floor(group.height * 0.00000 + 0.5)))
        
        context.saveGState()
        context.setShadow(offset: shadowOffset, blur: shadowBlurRadius, color: shadow.cgColor)
        checkmarkBlue.setFill()
        checkedOvalPath.fill()
        context.restoreGState()
        
        UIColor.white.setStroke()
        checkedOvalPath.lineWidth = 1
        checkedOvalPath.stroke()
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: group.minX + 0.27083 * group.width, y: group.minY + 0.54167 * group.height))
        bezierPath.addLine(to: CGPoint(x: group.minX + 0.41667 * group.width, y: group.minY + 0.68750 * group.height))
        bezierPath.addLine(to: CGPoint(x: group.minX + 0.75000 * group.width, y: group.minY + 0.35417 * group.height))
        bezierPath.lineCapStyle = CGLineCap.square
        
        UIColor.white.setStroke()
        bezierPath.lineWidth = 1.3
        bezierPath.stroke()
    }
    
    func drawRectOpenCircle(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        let frame = self.bounds
        
        let shadow = UIColor.black
        let shadowOffset = CGSize(width: 0.1, height: -0.1)
        let shadowBlurRadius: CGFloat = 0.5
        let shadow2 = UIColor.black
        let shadow2Offset = CGSize(width: 0.1, height: -0.1)
        let shadow2BlurRadius: CGFloat = 2.5
        
        let group = CGRect(x: frame.minX + 3, y: frame.minY + 3, width: frame.width - 6, height: frame.height - 6)
        let emptyOvalPath = UIBezierPath(ovalIn: CGRect(x: group.minX + floor(group.width * 0.00000 + 0.5), y: group.minY + floor(group.height * 0.00000 + 0.5), width: floor(group.width * 1.00000 + 0.5) - floor(group.width * 0.00000 + 0.5), height: floor(group.height * 1.00000 + 0.5) - floor(group.height * 0.00000 + 0.5)))
        
        context.saveGState()
        context.setShadow(offset: shadow2Offset, blur: shadow2BlurRadius, color: shadow2.cgColor)
        context.restoreGState()
        
        context.saveGState()
        context.setShadow(offset: shadowOffset, blur: shadowBlurRadius, color: shadow.cgColor)
        UIColor.white.setStroke()
        emptyOvalPath.lineWidth = 1
        emptyOvalPath.stroke()
        context.restoreGState()
    }
    
    func drawRectGrayedOut(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        let frame = self.bounds
        
        let grayTranslucent = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        let shadow = UIColor.black
        let shadowOffset = CGSize(width: 0.1, height: -0.1)
        let shadowBlurRadius: CGFloat = 2.5
        
        let group = CGRect(x: frame.minX + 3, y: frame.minY + 3, width: frame.width - 6, height: frame.height - 6)
        
        let uncheckedOvalPath = UIBezierPath(ovalIn: CGRect(x: group.minX + floor(group.width * 0.00000 + 0.5), y: group.minY + floor(group.height * 0.00000 + 0.5), width: floor(group.width * 1.00000 + 0.5) - floor(group.width * 0.00000 + 0.5), height: floor(group.height * 1.00000 + 0.5) - floor(group.height * 0.00000 + 0.5)))
        
        context.saveGState()
        context.setShadow(offset: shadowOffset, blur: shadowBlurRadius, color: shadow.cgColor)
        grayTranslucent.setFill()
        uncheckedOvalPath.fill()
        context.restoreGState()
        
        UIColor.white.setStroke()
        uncheckedOvalPath.lineWidth = 1
        uncheckedOvalPath.stroke()
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: group.minX + 0.27083 * group.width, y: group.minY + 0.54167 * group.height))
        bezierPath.addLine(to: CGPoint(x: group.minX + 0.41667 * group.width, y: group.minY + 0.68750 * group.height))
        bezierPath.addLine(to: CGPoint(x: group.minX + 0.75000 * group.width, y: group.minY + 0.35417 * group.height))
        bezierPath.lineCapStyle = CGLineCap.square
        
        UIColor.white.setStroke()
        bezierPath.lineWidth = 1.3
        bezierPath.stroke()
    }
}
