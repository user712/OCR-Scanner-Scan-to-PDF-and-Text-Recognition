//
//  CameraViewController.swift
//  GimiCam
//
//  Created  on 3/4/17.
//  Copyright © 2017 A. 
//

import UIKit

protocol CaptureViewControllerDelegate: class {
    /**
     Called when the `controller` captures an image.
     */
    func captureViewController(_ controller: CameraViewController, didCaptureStillImage image: UIImage?)
}


class CameraViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var cameraButton: UIButton!
    
    internal var lastFocusRectangle: CAShapeLayer?
    
    weak var captureDelegate: CaptureViewControllerDelegate?
    
    fileprivate var camera: VideoCamera!
    fileprivate var counter = 0
    fileprivate let rectangleDetector = RectangleDetector()
    
    static fileprivate let captureButtonRestingRadius: CGFloat = 3
    static fileprivate let captureButtonElevatedRadius: CGFloat = 7
    
    fileprivate lazy var captureButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)
        button.backgroundColor = .white
        
        button.layer.cornerRadius = 30
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.5
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = CameraViewController.captureButtonRestingRadius
        
        button.addTarget(self, action: #selector(handleCaptureButtonTouchDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(handleCaptureButtonTouchUpOutside(_:)), for: .touchUpOutside)
        button.addTarget(self, action: #selector(handleCaptureButtonTouchUpInside(_:)), for: .touchUpInside)
        
        return button
    }()
    
    fileprivate lazy var toolBarView: UIView = {
        let toolBar = UIView()
        toolBar.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        return toolBar
    }()
    
    
    // MARK: - LyfeCicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        camera = VideoCamera(superView: cameraView)
        camera.delegate = self
        camera.rectangleDelegate = rectangleDetector
        camera.usingJPEGOutput = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        camera.startCaptureSession()
        self.setUpCaptureButton()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        camera.stopCaptureSession()
    }
}


// MARK: - Setup UI

extension CameraViewController {
    
    fileprivate func setUpCaptureButton() {
        cameraButton.backgroundColor = .white
        
        cameraButton.layer.cornerRadius = 30
        cameraButton.layer.shadowColor = UIColor.black.cgColor
        cameraButton.layer.shadowOpacity = 0.5
        cameraButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        cameraButton.layer.shadowRadius = CameraViewController.captureButtonRestingRadius
        
        cameraButton.addTarget(self, action: #selector(handleCaptureButtonTouchDown(_:)), for: .touchDown)
        cameraButton.addTarget(self, action: #selector(handleCaptureButtonTouchUpOutside(_:)), for: .touchUpOutside)
        cameraButton.addTarget(self, action: #selector(handleCaptureButtonTouchUpInside(_:)), for: .touchUpInside)
    }
}


// MARK: - CameraDelegate

extension CameraViewController: CameraDelegate {
    
    func camera(_ camera: VideoCamera, didFocusAtPoint focusPoint: CGPoint, inLayer layer: CALayer) {
        print(focusPoint)
        
        if let lastFocusRectangle = self.lastFocusRectangle {
            lastFocusRectangle.removeFromSuperlayer()
            self.lastFocusRectangle = nil
        }
        
        let size = CGSize(width: 75, height: 75)
        let rect = CGRect(origin: CGPoint(x: focusPoint.x - size.width / 2.0, y: focusPoint.y - size.height / 2.0), size: size)
        
        let endPath = UIBezierPath(rect: rect)
        endPath.move(to: CGPoint(x: rect.minX + size.width / 2.0, y: rect.minY))
        endPath.addLine(to: CGPoint(x: rect.minX + size.width / 2.0, y: rect.minY + 5.0))
        endPath.move(to: CGPoint(x: rect.maxX, y: rect.minY + size.height / 2.0))
        endPath.addLine(to: CGPoint(x: rect.maxX - 5.0, y: rect.minY + size.height / 2.0))
        endPath.move(to: CGPoint(x: rect.minX + size.width / 2.0, y: rect.maxY))
        endPath.addLine(to: CGPoint(x: rect.minX + size.width / 2.0, y: rect.maxY - 5.0))
        endPath.move(to: CGPoint(x: rect.minX, y: rect.minY + size.height / 2.0))
        endPath.addLine(to: CGPoint(x: rect.minX + 5.0, y: rect.minY + size.height / 2.0))
        
        let startPath = UIBezierPath(cgPath: endPath.cgPath)
        let scaleAroundCenterTransform = CGAffineTransform(translationX: -focusPoint.x, y: -focusPoint.y).concatenating(CGAffineTransform(scaleX: 2.0, y: 2.0).concatenating(CGAffineTransform(translationX: focusPoint.x, y: focusPoint.y)))
        startPath.apply(scaleAroundCenterTransform)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = endPath.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor(red:1, green:0.83, blue:0, alpha:0.95).cgColor
        shapeLayer.lineWidth = 1.0
        
        layer.addSublayer(shapeLayer)
        lastFocusRectangle = shapeLayer
        
        CATransaction.begin()
        
        CATransaction.setAnimationDuration(0.2)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut))
        
        CATransaction.setCompletionBlock() { [unowned self] in
            if shapeLayer.superlayer != nil {
                shapeLayer.removeFromSuperlayer()
                self.lastFocusRectangle = nil
            }
        }
        
        let appearPathAnimation = CABasicAnimation(keyPath: "path")
        appearPathAnimation.fromValue = startPath.cgPath
        appearPathAnimation.toValue = endPath.cgPath
        shapeLayer.add(appearPathAnimation, forKey: "path")
        
        let appearOpacityAnimation = CABasicAnimation(keyPath: "opacity")
        appearOpacityAnimation.fromValue = 0.0
        appearOpacityAnimation.toValue = 1.0
        shapeLayer.add(appearOpacityAnimation, forKey: "opacity")
        
        let disappearOpacityAnimation = CABasicAnimation(keyPath: "opacity")
        disappearOpacityAnimation.fromValue = 1.0
        disappearOpacityAnimation.toValue = 0.0
        disappearOpacityAnimation.beginTime = CACurrentMediaTime() + 0.8
        disappearOpacityAnimation.fillMode = kCAFillModeForwards
        disappearOpacityAnimation.isRemovedOnCompletion = false
        shapeLayer.add(disappearOpacityAnimation, forKey: "opacity")
        
        CATransaction.commit()
    }
}


// MARK: - Action's

extension CameraViewController {
    
    @objc fileprivate func handleCaptureButtonTouchDown(_: UIButton) {
        captureButton.layer.animateShadowRadius(to: CameraViewController.captureButtonElevatedRadius)
        captureButton.backgroundColor = captureButton.backgroundColor?.withAlphaComponent(0.7)
    }
    
    @objc fileprivate func handleCaptureButtonTouchUpOutside(_: UIButton) {
        captureButton.layer.animateShadowRadius(to: CameraViewController.captureButtonRestingRadius)
        captureButton.backgroundColor = captureButton.backgroundColor?.withAlphaComponent(1)
    }
    
    @objc fileprivate func handleCaptureButtonTouchUpInside(_: UIButton) {
        captureButton.layer.animateShadowRadius(to: CameraViewController.captureButtonRestingRadius)
        captureButton.backgroundColor = captureButton.backgroundColor?.withAlphaComponent(1)
        
//        DispatchQueue.main.async { [unowned self] in
            self.camera.captureStillImage2() { [unowned self] (image, error) in
                self.captureDelegate?.captureViewController(self, didCaptureStillImage: image)
//            }
        }
    }
}
