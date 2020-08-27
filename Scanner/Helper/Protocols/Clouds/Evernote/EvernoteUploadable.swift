//
//  EvernoteUploadable.swift
//  iScanner
//


import UIKit
import EvernoteSDK


protocol EvernoteUploadable: EvernoteAutorizable {
    
}


extension EvernoteUploadable {
    
    func evernoteUpload(filePaths: [URL]) {
        uploadDidStart()
        
        let numOfUrl = filePaths.count
        var notes = Array<ENNote>()
        
        for filePath in filePaths{
            let note = ENNote()
            note.title = filePath.lastPathComponent
            
            let resource = ENResource(data: filePath.toData!, mimeType: "application/\(filePath.pathExtension)", filename: filePath.lastPathComponent)
            note.add(resource!)
            notes.append(note)
        }
        
        upload(notes: notes, index: 0, numOfUrl: numOfUrl)
    }
    
    private func upload(notes: Array<ENNote>, index: Int, numOfUrl: Int) {
        if isCanceled == true {
            return
        }
        
        if numOfUrl == index {
            self.uploadDidFinish()
            return
        }
        
        let note = notes[index]
        
        self.evernoteSharedSession.upload(note, policy: .create, to: nil, orReplace: nil, progress: nil, completion: { (noteRef, error) in
            if isCanceled == true {
                if let noteRef = noteRef {
                    self.evernoteSharedSession.delete(noteRef, completion: nil)
                }
                return
            }
            
            let _index = index + 1
            self.upload(notes: notes, index: _index, numOfUrl: numOfUrl)
        })
    }
    
    func evernoteCancelUploads(){
        isCanceled = true
    }
}

private var isCanceled = false
