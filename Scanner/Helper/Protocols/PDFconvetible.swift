//
//  PDFconvetible.swift
//  Scanner
//
//    
//   
//

import UIKit
import PDFGenerator

protocol PDFconvetible {
    func getPDFThumbnail(_ url: URL) -> UIImage
    func getPDFThumbnail(_ url: URL, pageNumber: Int) -> UIImage
    
    func convertMultipleImagesToOnePDF(_ images: [UIImage], horizontalResolution horisontal: Double, verticalResolution vertical: Double) -> Data?
    func convertMultipleImagesToPDFs(_ files: Set<File>) -> Data?
    func getImagesFromPDFAtPath(_ url: URL) -> [UIImage]
    
    func convertPDFsFromPaths(_ urls: [String]) -> Data?
}


extension PDFconvetible {
    
    func getPDFThumbnail(_ url: URL, pageNumber: Int) -> UIImage {
        return self.getPDFThumbnail(url, pageNumber: pageNumber, width: 240.0)
    }
    
    func getPDFThumbnail(_ url: URL) -> UIImage {
        return self.getPDFThumbnail(url, pageNumber: 1, width: 240.0)
    }
    
    private func getPDFThumbnail(_ url: URL, pageNumber: Int, width: CGFloat) -> UIImage {
        guard let defaultPDFThumbnail = UIImage(named: "pdf") else { return UIImage() }
        
        if let pdf = CGPDFDocument(url as CFURL) {
            if let firstPage = pdf.page(at: pageNumber) {
                var pageRect = firstPage.getBoxRect(CGPDFBox.mediaBox)
                let pdfScale = width/pageRect.size.width
                pageRect.size = CGSize(width: pageRect.size.width*pdfScale, height: pageRect.size.height*pdfScale)
                pageRect.origin = CGPoint.zero
                
                UIGraphicsBeginImageContext(pageRect.size)
                
                if let context = UIGraphicsGetCurrentContext() {
                    
                    /// White BG
                    context.setFillColor(red: 1.0,green: 1.0,blue: 1.0,alpha: 1.0)
                    context.fill(pageRect)
                    
                    context.saveGState()
                    
                    /// Next 3 lines makes the rotations so that the page look in the right direction
                    context.translateBy(x: 0.0, y: pageRect.size.height)
                    context.scaleBy(x: 1.0, y: -1.0)
                    context.concatenate((firstPage.getDrawingTransform(CGPDFBox.mediaBox, rect: pageRect, rotate: 0, preserveAspectRatio: true)))
                    
                    context.drawPDFPage(firstPage)
                    context.restoreGState()
                    
                    if let thumbnailImageFromPDF = UIGraphicsGetImageFromCurrentImageContext() {
                        UIGraphicsEndImageContext()
                        
                        return thumbnailImageFromPDF
                    }
                }
            }
        }
        
        return defaultPDFThumbnail
    }
}


let DefaultResolution = 72

extension PDFconvetible {
    
    func convertMultipleImagesToOnePDF(_ images: [UIImage], horizontalResolution horisontal: Double, verticalResolution vertical: Double) -> Data? {
        return convertMultipleImagesToPDF(images, horizontalResolution: horisontal, verticalResolution: vertical)
    }
    
    private func convertMultipleImagesToPDF(_ images: [UIImage], horizontalResolution: Double, verticalResolution: Double) -> Data? {
        
        guard images.count <= 0 else {
            if horizontalResolution <= 0 || verticalResolution <= 0 {
                return nil
            }
            
            let pageWidth: Double = Double(images[0].size.width) * Double(images[0].scale) * Double(DefaultResolution) / horizontalResolution
            let pageHeight: Double = Double(images[0].size.height) * Double(images[0].scale) * Double(DefaultResolution) / verticalResolution
            
            let pdfFile = NSMutableData.cfMutableData
            
            if let pdfConsumer = CGDataConsumer(data: pdfFile) {
                
                var mediaBox = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
                
                let pdfContext = CGContext(consumer: pdfConsumer, mediaBox: &mediaBox, nil)!
                
                for index in 0..<images.count {
                    if let cgImage = images[index].cgImage {
                        pdfContext.beginPage(mediaBox: &mediaBox)
                        pdfContext.draw(cgImage, in: mediaBox)
                        pdfContext.endPage()
                    }
                }
            }
            
            return pdfFile as Data
        }
        
        return nil
    }
}



extension PDFconvetible {
    
    func convertMultipleImagesToPDFs(_ files: Set<File>) -> Data? {
        var images = [UIImage]()
        
        for file in files {
            if let image = file.filePath.toUIImage {
                images.insert(image, at: 0)
            }
        }
        
//        let imagesArray = Array(files)
        
        return try? PDFGenerator.generated(by: images)
    }
    
    func convertPDFsFromPaths(_ urls: [String]) -> Data? {
        return try? PDFGenerator.generated(by: urls)
    }
}


extension PDFconvetible {
    
    
    func getImagesFromPDFAtPath(_ url: URL) -> [UIImage] {
        var images = [UIImage]()
        
        if let pdf = CGPDFDocument(url as CFURL) {
            for page in 0...pdf.numberOfPages {
                if let firstPage = pdf.page(at: page) {
                    let pageRect = firstPage.getBoxRect(CGPDFBox.mediaBox)
                    print(pageRect.width)
                    
                    UIGraphicsBeginImageContext(pageRect.size)
                    if let context = UIGraphicsGetCurrentContext() {
                        context.setFillColor(red: 1.0,green: 1.0,blue: 1.0,alpha: 1.0)
                        context.fill(pageRect)
                        context.translateBy(x: 0.0, y: pageRect.size.height)
                        context.scaleBy(x: 1.0, y: -1.0)
                        context.concatenate((firstPage.getDrawingTransform(CGPDFBox.mediaBox, rect: pageRect, rotate: 0, preserveAspectRatio: true)))
                        context.drawPDFPage(firstPage)
                        
                        if let thumbnailImageFromPDF = UIGraphicsGetImageFromCurrentImageContext() {
                            UIGraphicsEndImageContext()
                            
                            images.append(thumbnailImageFromPDF)
                        }
                    }
                }
            }
        }
        
        return images
    }
}


extension PDFconvetible {
    
    func test() {
        
    }
}





