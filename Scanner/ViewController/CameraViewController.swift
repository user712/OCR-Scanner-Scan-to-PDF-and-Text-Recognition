//
//  CameraViewController.swift
//  Scanner
//
//   on 1/23/17.
//   
//

import UIKit

class CameraViewController: UIViewController {

    // MARK: - Properties
    
    weak var processDelegate: Processable?
    
    fileprivate var videoCamera: VideoCamera?
    
    fileprivate var gridImageView = UIImageView()
    fileprivate var isGridEnabled = true
    fileprivate var originalImage: UIImage?
    fileprivate var croppedPictures = [UIImage]()
    fileprivate var transition: CircularTransition!
    
    fileprivate lazy var cameraSuperView: VideoCameraView = {
        let cameraView = VideoCameraView(frame: self.view.bounds)
        cameraView.contentMode = .scaleAspectFill
        cameraView.backgroundColor = UIColor.paleGrey
        cameraView.clipsToBounds = true
        
        return cameraView
    }()
    
    /// NavigationBar
    fileprivate lazy var cameraHeaderView: UIView = {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 64))
        headerView.backgroundColor = UIColor.paleGrey
        
        return headerView
    }()
    
    fileprivate lazy var torchButton: UIButton =  {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "flashOff"), for: .normal)
        button.setTitle("Off".localized(), for: .normal)
        button.setTitleColor(UIColor.darkSkyBlue, for: .normal) /// fix font
        button.addTarget(self, action: #selector(torchTapped(_:)), for: .touchUpInside)
        button.contentHorizontalAlignment = .left
        
        return button
    }()
    
    fileprivate lazy var featureContainerView: UIView = {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        headerView.backgroundColor = UIColor.paleGrey
        
        return headerView
    }()
    
    fileprivate lazy var featureButton: UIButton =  {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "autoDetectEdgesOn"), for: .normal)
        button.addTarget(self, action: #selector(featureTapped(_:)), for: .touchUpInside)
        
        return button
    }()
    
    fileprivate lazy var gridButton: UIButton =  {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "grid"), for: .normal)
        button.setTitleColor(UIColor.darkSkyBlue, for: .normal) /// fix font
        button.addTarget(self, action: #selector(gridTapped(_:)), for: .touchUpInside)
        
        return button
    }()
    
    /// Toolbar
    fileprivate lazy var cameraToolbarView: UIView = {
        let headerView = UIView(frame: CGRect(x: 0, y: self.view.frame.height - 64, width: self.view.frame.width, height: 64))
        headerView.backgroundColor = UIColor.paleGrey
        
        return headerView
    }()
   
    fileprivate lazy var cancelButton: UIButton =  {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "shape"), for: .normal)
        button.addTarget(self, action: #selector(cancelTapped(_:)), for: .touchUpInside)
        
        return button
    }()
    
    fileprivate lazy var captureButton: UIButton =  {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "shot"), for: .normal)
        button.addTarget(self, action: #selector(captureTapped(_:)), for: .touchUpInside)
        
        return button
    }()
    
    
    // MARK: - LyfeCicle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.addSubview(cameraSuperView)
        videoCamera = VideoCamera(cameraView: cameraSuperView)
        
        view.backgroundColor = UIColor.paleGrey
        gridImageView.frame = cameraSuperView.bounds
        gridImageView.image = self.view.drawGrid()
        cameraSuperView.addSubview(gridImageView)
        videoCamera?.cameraFlashMode = .off
        transition = CircularTransition()
        
        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        videoCamera?.start()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        videoCamera?.stop()
    }
    
    
    // MARK: - Deinitializers
    
    deinit {
        videoCamera = nil
        originalImage = nil
        
        processDelegate = nil
        
        croppedPictures.removeAll()
        transition = nil
    }
}


extension CameraViewController {
    
    fileprivate func setupUI() {
        view.addSubview(cameraHeaderView)
        view.addSubview(cameraToolbarView)
        
        setupCameraHeaderViewUI()
        setupCameraToolbarViewUI()
    }
    
    fileprivate func setupCameraHeaderViewUI() {
        
        switch deviceType {
        case .phone:
            cameraHeaderView.addSubview(torchButton)
            cameraHeaderView.addConstraintsWithFormat("H:|-11-[v0(100)]", views: torchButton)
            cameraHeaderView.addConstraintsWithFormat("V:[v0(30)]-10-|", views: torchButton)
        case .pad:
            cameraHeaderView.addSubview(cancelButton)
            cameraHeaderView.addConstraintsWithFormat("H:|-17-[v0(30)]", views: cancelButton)
            cameraHeaderView.addConstraintsWithFormat("V:[v0(30)]-10-|", views: cancelButton)
        default:
            break
        }
        
        cameraHeaderView.addSubview(featureContainerView)
        featureContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        let visualFormat = ":[cameraHeaderView]-(<=1)-[featureContainerView(30)]"
        let views = ["cameraHeaderView": cameraHeaderView, "featureContainerView": featureContainerView]
        
        /// Center horisontally
        let horizontalConstraint = NSLayoutConstraint.constraints(
            withVisualFormat: "V" + visualFormat,
            options: .alignAllCenterX,
            metrics: nil,
            views: views)
        
        cameraHeaderView.addConstraints(horizontalConstraint)
        
        /// Center vertically
        let verticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H" + visualFormat,
            options: .alignAllCenterY,
            metrics: nil,
            views: views)
        
        cameraHeaderView.addConstraints(verticalConstraints)
        
        featureContainerView.addSubview(featureButton)
        cameraHeaderView.addConstraintsWithFormat("H:|[v0]|", views: featureButton)
        cameraHeaderView.addConstraintsWithFormat("V:|-8-[v0(40)]", views: featureButton)
        
        cameraHeaderView.addSubview(gridButton)
        cameraHeaderView.addConstraintsWithFormat("H:[v0(40)]-20-|", views: gridButton)
        cameraHeaderView.addConstraintsWithFormat("V:[v0(40)]-0-|", views: gridButton)
    }
    
    fileprivate func setupCameraToolbarViewUI() {
        
        switch deviceType {
        case .phone:
            cameraToolbarView.addSubview(cancelButton)
            cameraToolbarView.addConstraintsWithFormat("H:|-11-[v0(40)]", views: cancelButton)
            cameraToolbarView.addConstraintsWithFormat("V:|-11-[v0]-11-|", views: cancelButton)
        default:
            break
        }
        cameraToolbarView.addSubview(captureButton)
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        
        let visualFormat = ":[cameraToolbarView]-(<=1)-[captureButton(52)]"
        let views = ["cameraToolbarView": cameraToolbarView, "captureButton": captureButton]
        
        /// Center horisontally
        let horizontalConstraint = NSLayoutConstraint.constraints(
            withVisualFormat: "V" + visualFormat,
            options: .alignAllCenterX,
            metrics: nil,
            views: views)
        
        cameraToolbarView.addConstraints(horizontalConstraint)
        
        /// Center vertically
        let verticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H" + visualFormat,
            options: .alignAllCenterY,
            metrics: nil,
            views: views)
        
        cameraToolbarView.addConstraints(verticalConstraints)
    }
}


// MARK: - Action's

extension CameraViewController {
    
    @objc fileprivate func torchTapped(_ button: UIButton) {
        if let cameraFlashMode = videoCamera?.cameraFlashMode {
            switch cameraFlashMode {
            case .off:
                videoCamera?.cameraFlashMode = .on
                button.setImage(UIImage(named: "flashON"), for: .normal)
                button.setTitle("On".localized(), for: .normal)
            case .on:
                videoCamera?.cameraFlashMode = .auto
                button.setImage(UIImage(named: "flashAuto"), for: .normal)
                button.setTitle("Auto".localized(), for: .normal)
            case .auto:
                videoCamera?.cameraFlashMode = .off
                button.setImage(UIImage(named: "flashOff"), for: .normal)
                button.setTitle("Off".localized(), for: .normal)
            }
        }

    }
    
    @objc fileprivate func featureTapped(_ button: UIButton) {
        if let isEnabled = videoCamera?.borderDetectionEnabled {
            if isEnabled {
                videoCamera?.borderDetectionEnabled = false
                button.setImage(UIImage(named: "autoDetectEdgesOff"), for: .normal)
            } else {
                videoCamera?.borderDetectionEnabled = true
                button.setImage(UIImage(named: "autoDetectEdgesOn"), for: .normal)
            }
        }
    }
    
    @objc fileprivate func gridTapped(_ button: UIButton) {
        UIView.animate(withDuration: 0.25) { [unowned self] in
            if self.gridImageView.alpha == 1.0 {
                self.gridImageView.alpha = 0.0
                button.setImage(UIImage(named: "gridOn"), for: .normal)
            } else {
                self.gridImageView.alpha = 1.0
                button.setImage(UIImage(named: "grid"), for: .normal)
            }
        }
    }
    
    @objc fileprivate func cancelTapped(_ button: UIButton) {
        self.processDelegate?.didFinishImageTransfer()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func captureTapped(_ button: UIButton) {
        self.gridImageView.alpha = 0.0
        
        videoCamera?.captureImage { [unowned self] (image) in
            self.originalImage = image
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let cropController = storyboard.instantiateInitialViewController() as! CropperViewController
            cropController.originalImage = image
            
//            cropController.transitioningDelegate = self
//            cropController.modalPresentationStyle = .custom
            self.present(cropController, animated: true, completion: nil)
            self.gridImageView.alpha = 1.0 /// ???
        }
    }
}


// MARK: - ProcessImagesViewControllerDelegate

extension CameraViewController: Processable {
    
    func didFinishImageTransfer() {
        processDelegate?.didFinishImageTransfer()
    }
}


// MARK: - UIViewControllerTransitioningDelegate

extension CameraViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        transition.startingPoint = CGPoint(x: (view.frame.width / 2) - 20, y: view.frame.height - 20)
        transition.circleColor = UIColor.paleGrey
        
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        transition.startingPoint = CGPoint(x: (view.frame.width / 2) - 20, y: view.frame.height - 2)
        transition.circleColor = UIColor.paleGrey
        
        return transition
    }
}
