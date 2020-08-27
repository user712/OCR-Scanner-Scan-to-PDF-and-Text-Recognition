//
//  ProgressLabel.swift
//  Scanner
//
//   on 1/20/17.
//   
//

import UIKit

class ProgressLabel: UILabel {
    
    // MARK: - Properties
    
    var style: TextStyleType = .percent
    
    var value: AnyObject? {
        didSet {
            
            switch style {
            case .percent:
                if let progress = value as? Float {
                    self.text = "\(Int(progress * 100))%"
                }
            }
        }
    }
    
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.masksToBounds = true
        self.layer.cornerRadius = bounds.size.width/2
    }
}

extension ProgressLabel {
    
    func percents(_ number: NSNumber) -> String {
        return NSString(format: "%.0f %", number.floatValue) as String
    }
    
    fileprivate func bytesText(_ number:NSNumber) -> String? {
        
        let formatter = NumberFormatter()
        
        if number.floatValue > 1000 {
            let bytes = (number.floatValue / 1024.0)
            formatter.positiveFormat = "0.#GB"
            formatter.decimalSeparator = "."
            return formatter.string(from: NSNumber(value: bytes as Float))
        } else if number.floatValue == 0 {
            return NSString(format: "%.0f", number.floatValue) as String
        }
        return NSString(format: "%.0fMB", number.floatValue) as String
    }
    
    fileprivate func animationLabelBaseValue(_ baseValue: CGFloat, executeBlock:((_ value: CGFloat) -> ())?) {
        
        var startTime:TimeInterval = Date().timeIntervalSince1970
        var seconds:TimeInterval = 0.0
        var value:CGFloat = 0.0
        var invalidate = false
        
        print("startTime: \(startTime)")
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(execute: { () -> Void in
            repeat {
                seconds = (Date().timeIntervalSince1970 - startTime)
                
                if seconds >= 0.001 {
                    startTime = Date().timeIntervalSince1970
                    value += ( baseValue / 100.0 )
                    invalidate = (value >= baseValue)
                    
                    DispatchQueue.main.async {
                        if executeBlock != nil {
                            executeBlock!(value)
                        }
                    }
                    
                    if invalidate {
                        break
                    }
                }
                
            } while true
        })
    }
}
