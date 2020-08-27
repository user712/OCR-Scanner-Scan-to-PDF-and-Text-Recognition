//
//  Functional Programming.swift
//  Scanner
//
//  
//   
//

import UIKit

// MARK: - Device Type

let deviceType = UIDevice.current.userInterfaceIdiom

func instantiateViewController(withIdetifier identifier: String) -> UIViewController {
    let mainStoryboard = UIStoryboard(name: StoryboardType.main.rawValue.capitalized, bundle: Bundle.main)
    
    return mainStoryboard.instantiateViewController(withIdentifier: identifier)
}


func createLabel(_ color: UIColor, font: UIFont, spacing: CGFloat) -> UILabel {
    let label = UILabel()
    label.textColor = color
    label.font = font
    label.text?.addTextSpacing(spacing)
    label.textAlignment = .center
    label.numberOfLines = 1
    
    return label
}

let screenWidth: CGFloat = UIScreen.main.bounds.size.width
let screenHeight: CGFloat = UIScreen.main.bounds.size.height

func calculateScreenSizeForCollectionViewCell(numberOfColomns colomns: Int = 3, spaceBetweenCells space: CGFloat = 7.0) -> CGSize {
    let cellWidth = (screenWidth / CGFloat(colomns)) - space
    
    return CGSize(width: cellWidth, height: cellWidth)
}


// MARK: - Alert

func showAlert(_ title: String, message: String, delegate: Any?, cancelButtonTitle: String) {
    let alert = UIAlertView(title: title, message: message, delegate: delegate, cancelButtonTitle: cancelButtonTitle)
    
    alert.show()
}



// MARK: - Calculate progress Bar for Dropbox

func getProgressFrom(_ totalBytesUploaded: Int64, andTotalBytesExpectedToUploaded totalBytesExpectedToUploaded: Int64) -> Int64 {
    return (totalBytesUploaded * 100) / totalBytesExpectedToUploaded
}


// MARK: - Tuple Join String

func tupleJoinStr(_ dataArray: [(String, String)]) -> String {
    var result = ""
    for tuple in dataArray {
        result.append(tuple.0 + "\n" + tuple.1 + "\n\n")
    }
    return result
}


private let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.default)
private let group = DispatchGroup()
func MainThreadRun(_ action : @escaping ((Void) -> Void)){
    DispatchQueue.main.async(execute: {
        action()
    })
}

func AsyncThreadRun(_ action : @escaping ((Void) -> Void)){
    queue.async(group: group, execute: { () -> Void in
        action()
    })
}
