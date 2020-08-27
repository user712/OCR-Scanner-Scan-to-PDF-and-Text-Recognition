//
//  ViewFlashable.swift
//  Scanner
//
//   on 1/23/17.
//   
//

import UIKit
import Photos
import CoreImage
import AVFoundation

protocol ViewFlashable: class {
    var focus: CGPoint { get set }
    func setFocus(_ focus: CGPoint, onRenderView renderView: VideoCameraView)
}


extension ViewFlashable {
    func setFocus(_ focus: CGPoint, onRenderView renderView: VideoCameraView) {
        self.focus = focus
        renderView.playSound()
        renderView.setupFocusLayer()
    }
}
