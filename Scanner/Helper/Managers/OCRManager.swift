//
//  OCRManager.swift
//  Scanner
//
//   on 1/20/17.
//   
//

import UIKit
import TesseractOCR
import GPUImage


protocol OCRDatable {}

extension OCRDatable {
    
//    var items: [[String]] {
//        let items = [[
//            "Afrikaans".localized(),
//            "Albanian".localized(),
//            "Arabic".localized(),
//            "Armenian".localized(),
//            "Basque".localized(),
//            "Bengali".localized(),
//            "Bulgarian".localized(),
//            "Catalan".localized(),
//            "Cambodian".localized(),
//            "Chinese (Mandarin)".localized(), /// 10
//            "Croatian".localized(),
//            "Czech".localized(),
//            "Danish".localized(),
//            "Dutch".localized(),
//            "English".localized(),
//            "Estonian".localized(),
//            "Fiji".localized(),
//            "Finnish".localized(),
//            "French".localized(),
//            "Georgian".localized(), /// 20
//            "German".localized(),
//            "Greek".localized(),
//            "Gujarati".localized(),
//            "Hebrew".localized(),
//            "Hindi".localized(),
//            "Hungarian".localized(),
//            "Icelandic".localized(),
//            "Indonesian".localized(),
//            "Irish".localized(),
//            "Italian".localized(), /// 30
//            "Japanese".localized(),
//            "Javanese".localized(),
//            "Korean".localized(),
//            "Latin".localized(),
//            "Latvian".localized(),
//            "Lithuanian".localized(),
//            "Macedonian".localized(),
//            "Malay".localized(),
//            "Malayalam".localized(),
//            "Maltese".localized(), /// 40
//            "Maori".localized(),
//            "Marathi".localized(),
//            "Mongolian".localized(),
//            "Nepali".localized(),
//            "Norwegian".localized(),
//            "Persian".localized(),
//            "Polish".localized(),
//            "Portuguese".localized(),
//            "Punjabi".localized(),
//            "Quechua".localized(), /// 50
//            "Romanian".localized(),
//            "Russian".localized(),
//            "Samoan".localized(),
//            "Serbian".localized(),
//            "Slovak".localized(),
//            "Slovenian".localized(),
//            "Spanish".localized(),
//            "Swahili".localized(),
//            "Swedish".localized(),
//            "Tamil".localized(), /// 60
//            "Tatar".localized(),
//            "Telugu".localized(),
//            "Thai".localized(),
//            "Tibetan".localized(),
//            "Tonga".localized(),
//            "Turkish".localized(),
//            "Ukrainian".localized(),
//            "Urdu".localized(),
//            "Uzbek".localized(),
//            "Vietnamese".localized(), /// 70
//            "Welsh".localized(),
//            "Xhosa".localized(), /// 72
//            ]]
//        
//        
//        return items
//    }
//    
//    var section: [String] {
//        let sections = ["Languages".localized()]
//     
//        return sections
//    }
//    
//    /// http://www.sk-spell.sk.cx/update-of-language-files-for-tesseract-ocr-304
//    /// https://github.com/tesseract-ocr/tessdata/tree/4592b8d453889181e01982d22328b5846765eaad
//    var ocrLanguages: [String] {
//        let flags = [
//            "afr",
//            "sqi",
//            "ara",
//            "asm",  // armenian
//            "eus",
//            "ben",
//            "bul",
//            "cat",
//            "cym", /// Cambodian
//            "chi_tra",
//            "hrv",
//            "ces",
//            "dan",
//            "nld",
//            "eng",
//            "est",
//            "", /// Fiji
//            "fin", /// Finnish
//            "fra",
//            "glg",
//            "deu",
//            "grc",
//            "guj",
//            "heb",
//            "hin",
//            "hun",
//            "isl",
//            "ind",
//            "gle",
//            "ita",
//            "jpn",
//            "jav",
//            "kor",
//            "lat",
//            "lav",
//            "lit",
//            "mkd",
//            "msa",
//            "mal",
//            "mlt",
//            "", /// Maori
//            "mar",
//            "", /// Mongolian
//            "nep",
//            "nor",
//            "pol",
//            "fas",
//            "por",
//            "pan",
//            "", /// Quechua
//            "ron",
//            "rus",
//            "san",
//            "srp",
//            "slv",
//            "spa",
//            "swa",
//            "swe",
//            "tam",
//            "", /// Tatar
//            "tlg",
//            "tha",
//            "bod",
//            "", /// Tonga
//            "tur",
//            "ukr",
//            "urd",
//            "uzb",
//            "vie",
//            "cym",
//            "", /// Xhosa
//        ]
//        
//        return flags
//    }
    
    var items: [[String]] {
        let items = [[
            "Afrikaans".localized(),
            "Albanian".localized(),
            "Arabic".localized(),
            "Basque".localized(),
            "Bengali".localized(), /// 5
            "Bulgarian".localized(),
            "Catalan".localized(),
            "Chinese (Traditional)".localized(),
            "Croatian".localized(),
            "Czech".localized(), /// 10
            "Danish".localized(),
            "Dutch".localized(),
            "English".localized(),
            "Estonian".localized(),
            "French".localized(),
            "Georgian".localized(),
            "German".localized(),
            "Greek".localized(),
            "Gujarati".localized(),
            "Hebrew".localized(), /// 10
            "Hindi".localized(),
            "Hungarian".localized(),
            "Icelandic".localized(),
            "Indonesian".localized(),
            "Irish".localized(),
            "Italian".localized(),
            "Japanese".localized(),
            "Javanese".localized(),
            "Korean".localized(),
            "Latin".localized(), /// 10
            "Latvian".localized(),
            "Lithuanian".localized(),
            "Macedonian".localized(),
            "Malay".localized(),
            "Malayalam".localized(),
            "Maltese".localized(),
            "Marathi".localized(),
            "Nepali".localized(),
            "Norwegian".localized(),
            "Persian".localized(), /// 10
            "Polish".localized(),
            "Portuguese".localized(),
            "Punjabi".localized(),
            "Romanian".localized(),
            "Russian".localized(),
            "Serbian".localized(),
            "Slovak".localized(),
            "Slovenian".localized(),
            "Spanish".localized(),
            "Swahili".localized(),
            "Swedish".localized(),
            "Tamil".localized(),
            "Telugu".localized(),
            "Thai".localized(),
            "Tibetan".localized(),
            "Turkish".localized(),
            "Ukrainian".localized(),
            "Urdu".localized(),
            "Uzbek".localized(),
            "Vietnamese".localized(),
            "Welsh".localized(),
            ]]
        
        
        return items
    }
    
    var section: [String] {
        let sections = ["Languages".localized()]
        
        return sections
    }
    
    /// http://www.sk-spell.sk.cx/update-of-language-files-for-tesseract-ocr-304
    /// https://github.com/tesseract-ocr/tessdata/tree/4592b8d453889181e01982d22328b5846765eaad
    var ocrLanguages: [String] {
        let flags = [
            "afr",
            "sqi",
            "ara",
            "eus",
            "ben", /// 5
            "bul",
            "cat",
            "chi_tra",
            "hrv",
            "ces", /// 10
            "dan",
            "nld",
            "eng",
            "est",
            "fra",
            "glg",
            "deu",
            "grc",
            "guj",
            "heb", /// 10
            "hin",
            "hun",
            "isl",
            "ind",
            "gle",
            "ita",
            "jpn",
            "jav",
            "kor",
            "lat", /// 10
            "lav",
            "lit",
            "mkd",
            "msa",
            "mal",
            "mlt",
            "mar",
            "nep",
            "nor",
            "pol", /// 10
            "fas",
            "por",
            "pan",
            "ron",
            "rus",
            "san",
            "srp",
            "slv",
            "spa",
            "swa",
            "swe",
            "tam",
            "tlg",
            "tha",
            "bod",
            "tur",
            "ukr",
            "urd",
            "uzb",
            "vie",
            "cym"]
        
        return flags
    }
    
    
    
    
    var searchedFlags: [String] {
        let items = [
            "Africaan",
            "Albanian",
            "Arabic",
            "Basque",
            "Bengali", /// 5
            "Bulgarian",
            "Catalan",
            "Chinese",
            "Croatian",
            "Czech", /// 10
            "Danish",
            "Dutch",
            "English",
            "Estonian",
            "French",
            "Georgian",
            "German",
            "Greek",
            "Gujarati",
            "Hebrew", /// 10
            "Hindi",
            "Hungarian",
            "Icelandic",
            "Indonesian",
            "Irish",
            "Italian",
            "Japanese",
            "Javanese",
            "Korean",
            "Latin", /// 10
            "Latvian",
            "Lithuanian",
            "Macedonian",
            "Malay",
            "Malayalam",
            "Maltese",
            "Marathi",
            "Nepali",
            "Norwegian",
            "Persian", /// 10
            "Polish",
            "Portuguese",
            "Punjabi",
            "Romanian",
            "Russian",
            "Serbian",
            "Slovak",
            "Slovenian",
            "Spanish",
            "Swahili",
            "Swedish",
            "Tamil",
            "Telugu",
            "Thai",
            "Tibetan",
            "Turkish",
            "Ukrainian",
            "Urdu",
            "Uzbek",
            "Vietnamese",
            "Welsh",
            ]
        
        return items
    }
}

protocol OCRDelegate: class {
    func progressImageRecognition(_ progress: Float, counter: UInt)
}

class OCRManager: NSObject, Fileable {
    
    // MARK: - Properties
    
    let language: String
    
    weak var delegate: OCRDelegate?
    
    internal var initialPath: URL?
    
    fileprivate var isSessionAborted = false
    fileprivate var tesseract: G8Tesseract?
    fileprivate var operationQueue = OperationQueue()
    
    /// config dictionary and its proving block
//    fileprivate let initOnlyConfigDictionary: [AnyHashable: Any] = [kG8ParamTessdataManagerDebugLevel: "1",
//                                                                    kG8ParamLoadSystemDawg: "F",
//                                                                    kG8ParamLoadFreqDawg: "F"]
    
    
    // MARK: - Initializers
    
    init(language: String) {
        self.language = language
        self.isSessionAborted = false
        
        print("G8Tesseract.version() \(G8Tesseract.version())")
        super.init()
        
        tesseract = G8Tesseract(language: language, configDictionary: nil, configFileNames: nil, absoluteDataPath: ocrTessDataURL.path, engineMode: .tesseractOnly)
        //(language: language, configDictionary: nil, configFileNames: nil, absoluteDataPath: ocrTessDataURL.path, engineMode: .tesseractOnly, copyFilesFromResources: false)
        print(language)
        
        if !isFolderExistsAtPath(ocrTessDataURL) {
            self.create(folderAtPath: documentsURL, withName: ".ocrLanguages/tessdata") /// ".ocrLanguages/tessdata"
            print(ocrTessDataURL)
        } else {
            print(ocrTessDataURL)
        }
    }
}


// MAKR: - Recognize

extension OCRManager {
    private func convertToGrayScale(image: UIImage) -> UIImage {
//        let imageRect:CGRect = CGRect.init(x: 0, y: 0, width: image.size.width, height: image.size.height)
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let width = image.size.width
        let height = image.size.height
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        context?.draw(image.cgImage!, in: CGRect(x: 0.0,y: 0.0,width: image.size.width,height: image.size.height))
        let imageRef = context!.makeImage()
        let newImage = UIImage.init(cgImage: imageRef!)
        
        return newImage
    }
    
    private func convertToBlackAndWhite(image: UIImage) -> UIImage {
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let width = image.size.width
        let height = image.size.height
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        context?.draw(image.cgImage!, in: CGRect(x: 0.0,y: 0.0,width: image.size.width,height: image.size.height))
        let imageRef = context!.makeImage()
        let newImage = UIImage.init(cgImage: imageRef!)
        return newImage
    }
    
    func recognizeFromImage(_ image: UIImage) -> String? {
        if let tesseract = tesseract {
            
            tesseract.delegate = self
            tesseract.image = image
            tesseract.recognize()
            
            return tesseract.recognizedText.replace(target: "\n", withString: " ")
        }
        
        return nil
    }
    
    func recognizeAndCreatePDFFromImages(_ images: [UIImage], fileName: String) -> (fullText: String, fileURL: URL)? {
        var arrayOfStrings = [NSAttributedString]()
        let wrapper = PDFCreatorManager()
        var fullText = ""
        
        if let tesseract = tesseract {
//            tesseract.pageSegmentationMode = .auto
            tesseract.delegate = self
//            tesseract.engineMode = .tesseractOnly
            
            for image in images {
                tesseract.image = image
                
                if tesseract.recognize() {
                    if let recognizedText = tesseract.recognizedText {
                        fullText += recognizedText.replace(target: "\n", withString: " ")
                        let attributedString = NSAttributedString(string: recognizedText)
                        arrayOfStrings.append(attributedString)
                    }
                }
            }
            
            if let pdfPath = wrapper.createPDF(fileName, withText: arrayOfStrings) {
                print("pdfPath = \(pdfPath)")
                let fileURL = URL(fileURLWithPath: pdfPath)
                return (fullText, fileURL)
            }
        }
        
        return nil
    }
    
    func recognizeAndCreatePDFFromImages(_ images: [UIImage], fileName: String, fileURL: URL) {
        var arrayOfStrings = [NSAttributedString]()
        let wrapper = PDFCreatorManager()
        var fullText = ""
        let pdfFileToWriteURL = fileURL.deletingLastPathComponent().appendingPathComponent(Constants.OriginalImageFolderName).appendingPathComponent(fileURL.lastPathComponent)
        
        
        if let tesseract = tesseract {
//            tesseract.pageSegmentationMode = .auto
            tesseract.delegate = self
//            tesseract.engineMode = .tesseractOnly
            
            for image in images {
                tesseract.image = image
                
                if tesseract.recognize() {
                    if let recognizedText = tesseract.recognizedText {
                        fullText += recognizedText.replace(target: "\n", withString: " ")
                        let attributedString = NSAttributedString(string: recognizedText)
                        arrayOfStrings.append(attributedString)
                    }
                }
            }
            
            wrapper.createPDF(withName: fileName, withText: arrayOfStrings, withWritePath: pdfFileToWriteURL.path)
            
            let fileTextURL = TextURL(fileURL: fileURL)
            let newFileText = FileText(documentName: fileURL.lastPathComponent.deletingPathExtension, content: fullText, fileTextURL: fileTextURL)
            self.createTextDocument(self, fileTextContent: newFileText)
        }
    }
    
    func stopOCR() {
        isSessionAborted = true
        G8Tesseract.clearCache()
    }
}


// MARK: - G8TesseractDelegate

extension OCRManager: G8TesseractDelegate {
    
    func progressImageRecognition(for tesseract: G8Tesseract!) {
        print(tesseract.progress)
        let progress = Float(tesseract.progress)
        let counter = tesseract.progress
        
        self.delegate?.progressImageRecognition(progress, counter: counter)
    }
    
    func shouldCancelImageRecognition(for tesseract: G8Tesseract!) -> Bool {
        return isSessionAborted
    }
    
    func preprocessedImage(for tesseract: G8Tesseract!, sourceImage: UIImage!) -> UIImage! {
        let stillImageFilter = GPUImageAdaptiveThresholdFilter()
        stillImageFilter.blurRadiusInPixels = 10.0
        let filteredImage = stillImageFilter.image(byFilteringImage: sourceImage)!
        
        return filteredImage
    }
}


// MARK: - OCRLAnguageDownloadable

protocol OCRLAnguageDownloadable: Downloadable, Fileable, NetworkAvieable {
    func downloadFileSync(_ fileName: String, progressCompletion: @escaping (_ completedUnitCount: Int64, _ totalUnitCount: Int64) -> () ,downloadCompletion: @escaping (_ succes: Bool, _ error: Error?) -> ())
}


extension OCRLAnguageDownloadable {
    
    func downloadFileSync(_ fileName: String, progressCompletion: @escaping (_ completedUnitCount: Int64, _ totalUnitCount: Int64) -> () ,downloadCompletion: @escaping (_ succes: Bool, _ error: Error?) -> ()) {
        downloadLanguage(ocrTessDataURL, languageName: fileName, progressCompletion: progressCompletion, downloadCompletion: downloadCompletion)
    }
}
