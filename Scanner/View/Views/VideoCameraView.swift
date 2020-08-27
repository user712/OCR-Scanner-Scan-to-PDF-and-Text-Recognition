//
//  VideoCameraView.swift
//  Scanner
//
//   on 1/23/17.
//   
//

import UIKit
import AVFoundation

class VideoCameraView: UIView {
    
    // MARK: - Properties
    
    weak var flashableDelegate: ViewFlashable?
    weak var cameraLifeCicleDelegate: CameraLifeCiclable?
    
    fileprivate var focusLayer: CALayer!
    fileprivate var shutterLayer: CALayer!
    fileprivate var inFocusProcess = false
    fileprivate var player: AVAudioPlayer?
    
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupFocusLayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupFocusLayer()
    }
    
    
    // MARK: - Deinitializers
    
    deinit {
        NotificationCenter.default.removeObserver(VideoCamera.self)
    }
}


// MARK: - LyfeCicle

extension VideoCameraView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cameraLifeCicleDelegate?.cameraDidEnterForeground()
        cameraLifeCicleDelegate?.cameraDidEnterBackground()
    }
}


// MARK: - Camera Focus

extension VideoCameraView {
    
    func setupFocusLayer() {
        focusLayer = CALayer()
        let focusImage = UIImage(named: "focusCamera")
        focusLayer.contents = focusImage?.cgImage
        self.layer.addSublayer(focusLayer)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapPreview))
        self.addGestureRecognizer(tapGesture)
    }
    
    func focusWithCaptureDevice(_ device: AVCaptureDevice) -> CGPoint {
        if device.isFocusPointOfInterestSupported {
            return device.focusPointOfInterest
        }
        
        return CGPoint.zero
    }
    
    func setFocus(_ pointOfInterest: CGPoint, withCaptureDevice device: AVCaptureDevice) {
        if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(.autoFocus) {
            do {
                try device.lockForConfiguration()
                device.focusPointOfInterest = pointOfInterest
                device.focusMode = .autoFocus
                device.unlockForConfiguration()
            } catch {}
        }
    }
    
    @objc private func finishFocusProcess() {
        inFocusProcess = false
    }
    
    func tapPreview(_ sender: UITapGestureRecognizer) {
        if sender.state != .ended || inFocusProcess {
            return
        }
        
        inFocusProcess = true
        
        let p = sender.location(in: self)
        let viewSize = self.frame.size
        let focusPoint = CGPoint.init(x: 1 - p.x / viewSize.width, y: p.y / viewSize.height)
        
        flashableDelegate?.setFocus(focusPoint, onRenderView: self)
        
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        focusLayer.frame = CGRect.init(x: p.x - 50, y: p.y - 50, width: 100, height: 100)
        focusLayer.opacity = 0
        
        CATransaction.commit()
        
        let opacityValues = [0, 0.2, 0.4, 0.6, 0.8, 1, 0.6, 1, 0.6]
        
        CATransaction.begin()
        
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimation.duration = 0.8
        opacityAnimation.values = opacityValues
        opacityAnimation.calculationMode = kCAAnimationCubic
        opacityAnimation.repeatCount = 0
        focusLayer.add(opacityAnimation, forKey: "opacity")
        
        let scaleXAnimation = CABasicAnimation(keyPath: "transform.scale.x")
        scaleXAnimation.duration = 0.4
        scaleXAnimation.repeatCount = 0
        scaleXAnimation.fromValue = 3
        scaleXAnimation.toValue = 1
        focusLayer.add(scaleXAnimation, forKey: "transform.scale.x")
        
        let scaleYAnimation = CABasicAnimation(keyPath: "transform.scale.y")
        scaleYAnimation.duration = 0.4
        scaleYAnimation.repeatCount = 0
        scaleYAnimation.fromValue = 3
        scaleYAnimation.toValue = 1
        focusLayer.add(scaleYAnimation, forKey: "transform.scale.y")
        
        CATransaction.commit()
        
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(finishFocusProcess),
                             userInfo: nil, repeats: false)
    }
}


// MARK: - PlaySound

extension VideoCameraView {
    
    func playSound() {
        if let url = Bundle.main.url(forResource: "focus", withExtension: "mp3") {
            do {
                player = try AVAudioPlayer(contentsOf: url)
                guard let player = player else { return }
                
                player.prepareToPlay()
                player.play()
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
}
