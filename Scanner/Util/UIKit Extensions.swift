//
//  UIKit Extensions.swift
//  Scanner
//
//  
//   
//

import UIKit

///
typealias VoidCompletion = () -> ()


// MARK: - String

extension String {
    
    func replace(target: String, withString: String) -> String {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }

    // for serted an array like: let myArray = ["Step 6", "Step 12", "Step 10"]
    func extractIntFromEnd() -> Int? {
        return self.components(separatedBy: " ").last.flatMap { Int($0) }
    }
    
    var deletingPathExtension: String {
        return NSString(string: self).deletingPathExtension
    }
    
    var deletingLastPathComponent: String {
        return NSString(string: self).deletingLastPathComponent
    }
}


// MARK: - UINavigationBar

extension UINavigationBar {
    
    func titleTextAttributes(_ color: UIColor, font: UIFont) {
        let attributes: [String : Any] = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: color]
        
        self.titleTextAttributes = attributes
    }
}


// MARK: - UIViewController

extension UIViewController {
    
    func setCustomColoredNavigationBarTitle() {
        self.navigationController?.navigationBar.titleTextAttributes(.darkSkyBlue, font: .textStyleFontLight(22))
        self.navigationItem.title?.addTextSpacing(-0.7)
    }
    
    var contentViewController: UIViewController {
        if let navCon = self as? UINavigationController {
            return navCon.visibleViewController ?? self
        } else {
            return self
        }
    }
    
    func showAlertWithTitle(_ title: String, message: String, completion: VoidCompletion?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK".localized(), style: .default) { (action) in
            if let completion = completion {
                completion()
            }
            
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}


// MARK: - UIPopoverPresentationControllerDelegate

extension UIViewController: UIPopoverPresentationControllerDelegate {
    
    public func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        // This *forces* a popover to be displayed on the iPhone
        return .none
        
    }
    
    func showPopoverFromItem(_ item: UIBarButtonItem, withSourceView sourceView: UIView, preferredContentSize: CGSize, path: URL) {
        let popoverContent = ShareViewController()
//        popoverContent.checkedURLPaths.insert(path)
        popoverContent.preferredContentSize = preferredContentSize
        popoverContent.modalPresentationStyle = .popover
        
        let popoverController = popoverContent.popoverPresentationController
        popoverController?.delegate = self
        popoverController?.barButtonItem = item
        
        popoverController?.sourceView = sourceView
        popoverController?.sourceRect = sourceView.bounds
        
        popoverController?.permittedArrowDirections = .any
        popoverController?.backgroundColor = UIColor.paleGrey
        
        self.present(popoverContent, animated: true, completion: nil)
    }
    
    func showPopoverFrom(_ popoverContent: UIViewController, barButtonItem item: UIBarButtonItem, withSourceView sourceView: UIView, preferredContentSize: CGSize) {
        popoverContent.preferredContentSize = preferredContentSize
        popoverContent.modalPresentationStyle = .popover
        
        let popoverController = popoverContent.popoverPresentationController
        popoverController?.delegate = self
        popoverController?.barButtonItem = item
        
        popoverController?.sourceView = sourceView
        popoverController?.sourceRect = sourceView.bounds
        
        popoverController?.permittedArrowDirections = .any
        popoverController?.backgroundColor = UIColor.paleGrey
        
        self.present(popoverContent, animated: true, completion: nil)
    }
}


// MARK: - UIFont

extension UIFont {
    
    class func textStyleFontRegular(_ size: CGFloat) -> UIFont {
        
        if #available(iOS 8.2, *) {
            return UIFont.systemFont(ofSize: size, weight: UIFontWeightRegular)
        } else {
            // Fallback on earlier versions
            return UIFont.systemFont(ofSize: size)
        }
    }
    
    class func textStyleFontLight(_ size: CGFloat) -> UIFont {
        
        if #available(iOS 8.2, *) {
            return UIFont.systemFont(ofSize: size, weight: UIFontWeightLight)
        } else {
            // Fallback on earlier versions
            return UIFont.systemFont(ofSize: size)
        }
    }
}


// MARK: - UIColor

extension UIColor {
    
    class func colorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    class func rgb(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
    }
    
    class var darkSkyBlue: UIColor {
        return UIColor.rgb(red: 38.0, green: 128.0, blue: 228.0, alpha: 1.0)
    }
    
    class var paleGrey: UIColor {
        return UIColor.rgb(red: 245.0, green: 245.0, blue: 247.0, alpha: 1.0)
    }
    
    class var gri: UIColor {
        return UIColor.rgb(red: 66.0, green: 66.0, blue: 66.0, alpha: 108)
    }
    
    class var separator: UIColor {
        return UIColor.rgb(red: 228.0, green: 228.0, blue: 234.0, alpha: 108)
    }
    
    class var download: UIColor {
        return UIColor.rgb(red: 161.0, green: 161.0, blue: 175.0, alpha: 108)
    }
    
    class var navLayer: UIColor {
        return UIColor.rgb(red: 229, green: 231, blue: 235, alpha: 1.0)
    }
    
    class var tableViewLayer: UIColor {
        return UIColor.rgb(red: 203, green: 203, blue: 212, alpha: 1.0)
    }
    
    class var isDownloaded: UIColor {
        return UIColor.rgb(red: 161, green: 161, blue: 175, alpha: 1.0)
    }
}



// MARK: - UIImage

extension UIImage: Imageable {
    
    var getJPEGData: Data? {
        return UIImageJPEGRepresentation(self, 0.5)
    }
    
    var toFullData: Data? {
        return UIImageJPEGRepresentation(self, 1)
    }
    
    var toCIImage: CIImage {
        guard let ciImage = CIImage(image: self) else { return CIImage() }
        
        return ciImage
    }
    
    /// Crop Image and return image data
    func cropImageWithCustomSize(_ size: CGSize = CGSize(width: 200, height: 200)) -> Data? {
        if let imageData = self.getJPEGData, let cropedImage = resizeData(imageData) {
            return UIImageJPEGRepresentation(cropedImage, 0.5)
        }
        
        return nil
    }
    
    func rotatedImageWithDegree(_ degree: CGFloat) -> UIImage? {
        // calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox = UIView(frame: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let cgAffineTrfm = CGAffineTransform(rotationAngle: degree * .pi / 180.0)
        
        rotatedViewBox.transform = cgAffineTrfm
        let rotatedSize = rotatedViewBox.frame.size
        
        // Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        if let bitmap = UIGraphicsGetCurrentContext() {
            
            // Move the origin to the middle of the image so we will rotate and scale around the center.
            bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
            
            // Rotate the image context
            bitmap.rotate(by: (degree * .pi / 180.0))
            
            // Now, draw the rotated/scaled image into the context
            bitmap.scaleBy(x: 1.0, y: -1.0)
            
            if let cgImageFromImage = self.cgImage {
                
                bitmap.draw(cgImageFromImage, in: CGRect(x: -self.size.width / 2, y: -self.size.height / 2, width: self.size.width, height: self.size.height))
                
                if let newImage = UIGraphicsGetImageFromCurrentImageContext() {
                    UIGraphicsEndImageContext()
                    
                    return newImage
                }
            }
        }
        
        return nil
    }
}


// MARK: - UIView

extension UIView {
    
    func addConstraintsWithFormat(_ format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
    
    func drawGrid() -> UIImage? {
        
        func  makePointArrayFromFrame(_ frame: CGRect) -> [[CGPoint]] {
            let thirdOfWidth = frame.width/3
            let thirdOfHeght = frame.height/3
            
            return [[CGPoint(x: thirdOfWidth, y: 0), CGPoint(x: thirdOfWidth, y: frame.height)],
                    [CGPoint(x: thirdOfWidth*2, y: 0), CGPoint(x: thirdOfWidth*2, y: frame.height)],
                    [CGPoint(x: 0, y: thirdOfHeght), CGPoint(x: frame.width, y: thirdOfHeght)],
                    [CGPoint(x: 0, y: thirdOfHeght*2), CGPoint(x: frame.width, y: thirdOfHeght*2)]]
        }
        
        ///
        UIGraphicsBeginImageContext(self.frame.size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setLineWidth(2.0)
        context?.setStrokeColor(UIColor.darkSkyBlue.withAlphaComponent(0.7).cgColor)
        
        for arr in makePointArrayFromFrame(self.frame) {
            context?.move(to: CGPoint(x: arr[0].x, y: arr[0].y))
            context?.addLine(to: CGPoint(x: arr[1].x, y: arr[1].y))
        }
        
        context?.strokePath()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func addTopBorder() {
        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0, y: 0, width: 1000, height: 0.5)
        topBorder.backgroundColor = UIColor.rgb(red: 229, green: 231, blue: 235, alpha: 1).cgColor
        self.layer.addSublayer(topBorder)
    }
    
    func addBottomBorder() {
        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0, y: self.frame.height - 0.5, width: 1000, height: 0.5)
        topBorder.backgroundColor = UIColor.rgb(red: 229, green: 231, blue: 235, alpha: 1).cgColor
        self.layer.addSublayer(topBorder)
    }
}


// MARK: - Data

extension Data: Imageable {
    
    var toCFData: CFData {
        return self as CFData
    }
    
    func resizeData(_ size: CGSize = CGSize(width: 100, height: 100)) -> Data? {
        return self.resizeData(self, withSize: size)?.toFullData
    }
}


// MARK: - URL

extension URL: Fileable, PDFconvetible {
    
    var toData: Data? {
        return try? Data(contentsOf: self)
    }
    
    var initialPath: URL? {
        return self.initialPath /// Recursive, be carefull
    }
    
    var toCFURL: CFURL {
        return self as CFURL
    }
    
    var isPDF: Bool {
        if self.pathExtension == "pdf" {
            return true
        } else {
            return false
        }
    }
    
    var isJPG: Bool {
        if self.pathExtension == "jpg" {
            return true
        } else {
            return false
        }
    }
    
    var isJPEG: Bool {
        if self.pathExtension == "jpeg" {
            return true
        } else {
            return false
        }
    }
    
    var isPNG: Bool {
        if self.pathExtension == "png" {
            return true
        }
        
        return false
    }
    
    var isImage: Bool {
        if self.isPNG || self.isJPG || self.isJPEG {
            return true
        }
        
        return false
    }
    
    var toUIImage: UIImage? {
        return UIImage(contentsOfFile: self.path)
    }
    
    var isDirectory: Bool {
        var isDirectory: ObjCBool = false
        filesManager.fileExists(atPath: self.path, isDirectory: &isDirectory)
        
        return isDirectory.boolValue ? true : false
    }
    
    var getFileAttributes: NSDictionary? {
        let path = self.path
        
        do {
            let attributes = try filesManager.attributesOfItem(atPath: path) as NSDictionary
            
            return attributes
        } catch {}
        
        return nil
    }
    
    var getFileAttributesOfURL: [FileAttributeKey: Any]? {
        let path = self.path
        
        do {
            let attributes = try filesManager.attributesOfItem(atPath: path)
            
            return attributes
        } catch {}
        
        return nil
    }
    
    var numberOfItemsAtPath : Int? {
        return try? filesManager.contentsOfDirectory(at: self, includingPropertiesForKeys: [], options: [.skipsHiddenFiles]).count
    }
    
    var getDate: String {
        return self.getDate(self.getFileAttributesOfURL)
    }
    
    var getTimestamp: Double {
        return self.getTimestamp(self.getFileAttributesOfURL)
    }
    
    var fileExist: Bool {
        return filesManager.fileExists(atPath: self.path)
    }
    
    var numberOfPDFitemsAtPath: Int? {
        return self.getPDFSmallImagesURLCount(self)
    }
    
    var getPDFNumberFiles: Int? {
        if self.isPDF {
            if let pdf = CGPDFDocument((self as CFURL)) {
                return pdf.numberOfPages
            }
        }
        
        return nil
    }
}


extension String {
    
    func addTextSpacing(_ spacing: CGFloat) {
        let attributedString = NSMutableAttributedString(string: self)
        attributedString.addAttribute(NSKernAttributeName, value: spacing, range: NSMakeRange(0, attributedString.length))
    }
    
//    func setCharacterSpacig(_ spacing: CGFloat) -> NSMutableAttributedString {
//        let attributedStr = NSMutableAttributedString(string: self)
//        attributedStr.addAttribute(NSKernAttributeName, value: spacing, range: NSMakeRange(0, attributedStr.length))
//        
//        return attributedStr
//    }
}


// MARK: - UITableView

extension UITableView {
    
    func hideEmptyCells(_ color: UIColor) {
        let customFooterView = UIView(frame: CGRect.zero)
        customFooterView.backgroundColor = color
        
        self.tableFooterView = customFooterView
    }
}


// MARK: - CGSize

extension CGFloat {
    
    var toDouble: Double {
        return Double(self)
    }
    
    var toFloat: Float {
        return Float(self)
    }
    
    var toInt: Int {
        return Int(self)
    }
    
    var toString: String {
        return String(describing: self)
    }
}


// MARK: - Float

extension Float {
    
    var toDouble: Double {
        return Double(self)
    }
    
    var toInt: Int {
        return Int(self)
    }
    
    var toString: String {
        return String(describing: self)
    }
    
    var toCGFloat: CGFloat {
        return CGFloat(self)
    }
}


// MARK: - Double

extension Double {
    
    var toFloat: Float {
        return Float(self)
    }
    
    var toInt: Int {
        return Int(self)
    }
    
    var toString: String {
        return String(describing: self)
    }
    
    var toCGFloat: CGFloat {
        return CGFloat(self)
    }
}


// MARK: - Int

extension Int {
    
    var toDouble: Double {
        return Double(self)
    }
    
    var toString: String {
        return String(describing: self)
    }
    
    var toFloat: Float {
        return Float(self)
    }
    
    var toCGFloat: CGFloat {
        return CGFloat(self)
    }
    
    var seconds: TimeInterval {
        return TimeInterval(self)
    }
    
    var minutes: TimeInterval {
        return TimeInterval(self * 60)
    }
    
    var hours: TimeInterval {
        return TimeInterval(self * 3600)
    }
    
    var days: TimeInterval {
        return TimeInterval(self * 3600 * 24)
    }
}


// MARK: - UserDefaults

extension UserDefaults {
    
    var isFirstLaunch: Bool {
        if !UserDefaults.standard.bool(forKey: "HasAtLeastLaunchedOnce") {
            UserDefaults.standard.set(true, forKey: "HasAtLeastLaunchedOnce")
            UserDefaults.standard.synchronize()
            
            return true
        }
        
        return false
    }
}


// MARK: - UIButton

extension UIButton {
    
    class func createSendButton(_ name: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(name, for: .normal)
        button.setTitleColor(UIColor.darkSkyBlue, for: .normal)
        button.titleLabel?.font = UIFont.textStyleFontRegular(18)
        button.backgroundColor = UIColor.rgb(red: 253.0, green: 253.0, blue: 253.0, alpha: 1.0)
        button.layer.cornerRadius = 4.0
        button.layer.borderWidth = 1.2
        button.layer.borderColor = UIColor.rgb(red: 203.0, green: 203.0, blue: 212.0, alpha: 1.0).cgColor
        
        return button
    }
}


extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else {
                return identifier
            }
            
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8":return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
}


// MARK: - UILabel

extension UILabel {
    
    func setTitle(_ title: String) {
        self.text = title
        self.textAlignment = .center
        self.textColor = UIColor.darkSkyBlue
        self.font = UIFont.textStyleFontLight(22)
        self.isUserInteractionEnabled = true
    }
    
    func drawBottomDashedLine(_ color: UIColor) {
        let shapeLayer = CAShapeLayer()
        let frameSize = self.frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineJoin = kCALineJoinRound
        
        shapeLayer.lineDashPattern = [5,5] // adjust to your liking
        shapeLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: shapeRect.height, width: shapeRect.width, height: 0), cornerRadius: self.layer.cornerRadius).cgPath
        
        self.layer.addSublayer(shapeLayer)
    }
    
    func drawAroundDashedLine(_ color: UIColor) {
        let shapeLayer = CAShapeLayer()
        let frameSize = self.frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineJoin = kCALineJoinRound
        
        shapeLayer.lineDashPattern = [5,5] // adjust to your liking
        shapeLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: shapeRect.width, height: shapeRect.height), cornerRadius: self.layer.cornerRadius).cgPath
        
        self.layer.addSublayer(shapeLayer)
    }
}


extension UITextField {
    
//    fileprivate lazy var changeNameTextField: UITextField = {
//        let textField = UITextField(frame: CGRect(x: 10, y: 0, width: self.view.frame.width / 2, height: 30))
//        
//        textField.placeholder = self.filePath.lastPathComponent.deletingPathExtension
//        textField.text = self.filePath.lastPathComponent.deletingPathExtension
//        textField.font = UIFont.textStyleFontLight(18)
//        textField.textColor = .gri
//        textField.borderStyle = .roundedRect
//        textField.autocorrectionType = .no
//        textField.keyboardType = .default
//        textField.returnKeyType = .done
//        textField.clearButtonMode = .whileEditing
//        textField.contentVerticalAlignment = .center
//        textField.backgroundColor = .white
//        textField.textAlignment = .center
//        
//        return textField
//    }()
}


// MARK: - Bundle

extension Bundle {
    
    static func podBundle(forClass: AnyClass) -> Bundle? {
        let bundleURL = Bundle.main.bundleURL
        
        if let bundle = Bundle(url: bundleURL) {
            
            return bundle
        } else {
            assertionFailure("Could not load the bundle")
        }
        
        return nil
    }
}


// MARK: - CIImage
/*
extension CIImage {
    
    var rotateImage: CIImage {
        if let transform = CIFilter(name: "CIAffineTransform") {
            transform.setValue(self, forKey: kCIInputImageKey)
            let rotation = NSValue(cgAffineTransform: CGAffineTransform(rotationAngle: CGFloat(-90.0 * (M_PI / 180.0))))
            transform.setValue(rotation, forKey: "inputTransform")
            if let rotated = transform.outputImage {
                
                return rotated
            } else {
                
                return image
            }
            
        } else {
            
            return image
        }
    }
}*/
