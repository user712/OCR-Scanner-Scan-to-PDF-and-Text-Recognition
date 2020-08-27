//
//  ToastManager.swift
//  Scanner
//
//   on 1/20/17.
//   
//

import Toast

typealias ToastCompletion = (Bool) -> ()

// MARK: - ToastWrapper

class ToastManager {
    
    // MARK: - Nested Types
    
    enum ToastPositionType {
        case top
        case center
        case bottom
        
        
        /// Will return position of toast on view
        var viewPosition: Any {
            switch self {
            case .top: return CSToastPositionTop
            case .center: return CSToastPositionCenter
            case .bottom: return CSToastPositionBottom
            }
        }
    }
    
    
    // MARK: - Properties
    
    static let main = ToastManager()
    private init() {}
}


// MARK: - ToastManager Helper methods

extension ToastManager {
    
    func makeToast(_ view: UIView, message: String) {
        view.makeToast(message)
    }
    
    func makeToast(_ view: UIView, position: ToastPositionType) {
        view.makeToastActivity(position.viewPosition)
    }
    
    func makeToast(_ view: UIView, message: String, duration: TimeInterval, position: ToastPositionType) {
        view.makeToast(message, duration: duration, position: position.viewPosition)
    }
    
    func makeToast(_ view: UIView, message: String, duration: TimeInterval, position: ToastPositionType, style: CSToastStyle) {
        view.makeToast(message, duration: duration, position: position.viewPosition, style: style)
    }
    
    func makeToast(_ view: UIView, message: String, duration: TimeInterval, position: ToastPositionType, title: String, image: UIImage, style: CSToastStyle, completion: @escaping ToastCompletion) {
        view.makeToast(message, duration: duration, position: position.viewPosition, title: title, image: image, style: style, completion: completion)
    }
}
