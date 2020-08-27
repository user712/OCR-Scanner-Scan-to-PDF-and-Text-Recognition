//
//  CustomCropViewController.swift
//  AVCamera
//
//  Created by Developer on 3/9/17.
//  Copyright © 2017 A. 
//

import UIKit

class CustomCropViewController: UIViewController {

    // MARK: - Properties
    
    var cameraResolution: CameraResolution!
    var image: UIImage!
    var croppedImage: CIImage!
    var detectedImage: PixelGridView!
    var headerView: UIView!
    var footerView: UIView!
    var overlayView: OverlayView!
    var magnetEnabled: Bool!
    let rectangleWrapper = RectangleWrapper()
    
    
    // MARK: - LyfeCicle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.croppedImage = CIImage(image: image)
        rectangleWrapper.initAllFeatures()
        
        let viewHeigth: CGFloat = 64
        self.detectedImage = PixelGridView(frame: CGRect(x: 0, y: 64, width: self.view.frame.width, height: self.view.frame.height - (viewHeigth * 2)))
        self.headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: viewHeigth))
        self.footerView = UIView(frame: CGRect(x: 0, y: self.view.frame.height - viewHeigth, width: self.view.frame.width, height: viewHeigth))
        
        self.view.addSubview(headerView)
        self.view.addSubview(detectedImage)
        self.view.addSubview(footerView)
        
//        detectedImage.contentMode = .scaleAspectFill
//        detectedImage.clipsToBounds = true
        detectedImage.image = self.image
        detectedImage.isUserInteractionEnabled = true
//        detectedImage.layer.shouldRasterize = true
//        detectedImage.layer.rasterizationScale = UIScreen.main.scale
//        detectedImage.autoresizesSubviews = false
//        detectedImage.setNeedsDisplay()
//        detectedImage.transform = CGAffineTransform.identity
//        detectedImage.center = view.center
        
        detectedImage.gridVariant = .tightSpacing
        detectedImage.renderingMode = .nativePixels
        
        
        
        self.headerView.backgroundColor = UIColor.darkGray
        self.footerView.backgroundColor = UIColor.darkGray
        
        
        
        let button = UIButton(frame: CGRect(x: 0, y: 20, width: 100, height: 40))
        button.setTitle("Done", for: .normal)
        button.addTarget(self, action: #selector(confirmButtonClicked), for: .touchUpInside)
        self.headerView.addSubview(button)
        
//        self.magnetDeactivated()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


extension CustomCropViewController {
    
    func magnetDeactivated() {
        let margin: CGFloat = 60.0

        let topLeftPath = self.detectedImage.frame.origin.x - margin
        let topRightPath = self.detectedImage.frame.origin.y - margin
        let bottomLeftPath = self.detectedImage.frame.width - margin
        let bottomRightPath = self.detectedImage.frame.height - margin
        
        self.overlayView = OverlayView(frame: detectedImage.bounds)
        self.detectedImage.addSubview(self.overlayView)
        
        self.overlayView.topLeftPath = CGPoint(x: margin, y: margin)
        self.overlayView.topRightPath = CGPoint(x: bottomLeftPath, y: margin)
        self.overlayView.bottomLeftPath = CGPoint(x: margin, y: bottomRightPath)
        self.overlayView.bottomRightPath = CGPoint(x: bottomLeftPath, y: bottomRightPath)
        self.overlayView.initializeSubView()
    }
    
    func confirmButtonClicked() {
        self.dismiss(animated: false, completion: { _ in })
    }
}







extension CustomCropViewController {
    
    fileprivate func magnetActivated() {
        let absoluteHeight = self.image.size.height / self.detectedImage.frame.size.height
        let absoluteWidth = self.image.size.width / self.detectedImage.frame.size.width
        
        self.overlayView = OverlayView(frame: CGRect.zero)
        self.overlayView.translatesAutoresizingMaskIntoConstraints = false
        self.detectedImage.addSubview(self.overlayView)
        
        if let overlayView = self.overlayView {
            let imgTop = NSLayoutConstraint(item: overlayView, attribute: .top, relatedBy: .equal, toItem: self.detectedImage, attribute: .top, multiplier: 1.0, constant: 0.0)
            let imgLeft = NSLayoutConstraint(item: overlayView, attribute: .left, relatedBy: .equal, toItem: self.detectedImage, attribute: .left, multiplier: 1.0, constant: 0.0)
            let imgRight = NSLayoutConstraint(item: overlayView, attribute: .right, relatedBy: .equal, toItem: self.detectedImage, attribute: .right, multiplier: 1.0, constant: 0.0)
            let imgBtm = NSLayoutConstraint(item: self.detectedImage, attribute: .bottom, relatedBy: .equal, toItem: self.footerView, attribute: .top, multiplier: 1.0, constant: 0.0)
            
            let imgConstraints = [imgTop, imgBtm, imgLeft, imgRight]
            self.view.addConstraints(imgConstraints)
        }
        
        self.overlayView.absoluteHeight = absoluteHeight
        self.overlayView.absoluteWidth = absoluteWidth
        
        
        if let rect = self.rectangleWrapper.detectRectangles(in: croppedImage, withOverlay: overlayView) {
            self.overlayView.topLeftPath = rect.topleft
            self.overlayView.topRightPath = rect.topRight
            self.overlayView.bottomLeftPath = rect.bottomLeft
            self.overlayView.bottomRightPath = rect.bottomRight
        }
        
        self.overlayView.initializeSubView()
    }
}





















