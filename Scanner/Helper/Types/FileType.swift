//
//  FileType.swift
//  Scanner
//
//  
//   
//

import UIKit


enum FileType: String, Imageable {
    /// Directory
    case directory = "directory"
    /// GIF file
    case gif = "gif"
    /// JPG file
    case jpg = "jpg"
    ///JPEG file
    case jpeg = "jpeg"
    /// PLIST file
    case json = "json"
    /// PDF file
    case pdf = "pdf"
    /// PLIST file
    case plist = "plist"
    /// PNG file
    case png = "png"
    /// ZIP file
    case zip = "zip"
    /// Any file
    case none = "file"
    
    /**
     Get representative image for file type
     - returns: UIImage for file type
     */
    func image(_ path: URL) -> UIImage? {
        switch self {
        case .directory:
            return UIImage(named: "documents")
        case .jpg, .jpeg, .png, .gif:
            
            return UIImage(named: "file")
        case .pdf:
            return UIImage(named: "documents")
        case .zip:
            return UIImage(named: "zip")
        default:
            return UIImage(named: "file")
        }
    }
    
    func getImage(_ path: URL, imageView: UIImageView) {
        switch self {
        case .directory:
            imageView.image = UIImage(named: "documents")
        case .jpg, .jpeg, .png, .gif:
           print(222)
            
        case .pdf:
            imageView.image = UIImage(named: "documents")
        case .zip:
            imageView.image = UIImage(named: "zip")
        default:
            imageView.image = UIImage(named: "file")
        }
    }
    
    func getImage(_ file: File, imageView: UIImageView) {
        switch self {
        case .directory:
            imageView.image = UIImage(named: "documents")
        case .jpg, .jpeg, .png, .gif:
            imageView.image = file.thumbnailURL.toUIImage
        case .pdf:
            imageView.image = UIImage(named: "pdfFile")
        case .zip:
            imageView.image = UIImage(named: "zip")
        default:
            imageView.image = UIImage(named: "file")
        }

    }
}
