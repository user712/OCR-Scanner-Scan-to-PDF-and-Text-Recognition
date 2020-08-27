//
//  Downloadable.swift
//  Scanner
//
//   on 1/30/17.
//   
//

import Foundation
import Alamofire

protocol Downloadable {
    func downloadLanguage(_ ocrTessDataURL: URL, languageName: String, progressCompletion: @escaping (_ completedUnitCount: Int64, _ totalUnitCount: Int64) -> (), downloadCompletion: @escaping (_ succes: Bool, _ error: Error?) -> ())
}


extension Downloadable {
    
    func downloadLanguage(_ ocrTessDataURL: URL, languageName: String, progressCompletion: @escaping (_ completedUnitCount: Int64, _ totalUnitCount: Int64) -> (), downloadCompletion: @escaping (_ succes: Bool, _ error: Error?) -> ()) {
//        let url = URL(string: "http://api.nordicnations.net/ocr/1.0/\(languageName)")!
        let tesseractURL = URL(string: "https://github.com/tesseract-ocr/tessdata/blob/bf82613055ebc6e63d9e3b438a5c234bfd638c93/\(languageName).traineddata?raw=true")!
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        
        Alamofire.download(tesseractURL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil, to: destination).downloadProgress(closure: { (progress) in
            //progress closure
            progressCompletion(progress.completedUnitCount, progress.totalUnitCount)
        }).response(completionHandler: { (DefaultDownloadResponse) in
            //here you able to access the DefaultDownloadResponse
            //result closure
            
            if let destinationURL = DefaultDownloadResponse.destinationURL {
                
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                    print("exist, need to move")
                print(destinationURL)
                    do {
                        try FileManager.default.moveItem(at: destinationURL, to: ocrTessDataURL.appendingPathComponent(destinationURL.lastPathComponent))
                        print(ocrTessDataURL)
                        downloadCompletion(true, nil)
                    } catch {
                        print("error = \(error.localizedDescription)")
                        downloadCompletion(false, error)
                    }
                } else {
                    print(000)
                }
                
            }
        })
        
    }
}
