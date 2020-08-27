//
//  AVCameraViewController.swift
//  AVCamera
//
//  Created by Developer on 3/9/17.
//  Copyright © 2017 A. 
//

import UIKit
import AVFoundation
import AssetsLibrary
import QuickLook

var SessionRunningAndDeviceAuthorizedContext = "SessionRunningAndDeviceAuthorizedContext"
var CapturingStillImageContext = "CapturingStillImageContext"
var RecordingContext = "RecordingContext"

class AVCameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    // MARK: - Properties
    
    @IBOutlet weak var previewView: AVCamPreviewView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var snapButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override var shouldAutorotate : Bool {
        return !self.lockInterfaceRotation
    }
    
    var resolution: CameraResolution!
    
    var sessionQueue: DispatchQueue!
    var session: AVCaptureSession?
    var videoDeviceInput: AVCaptureDeviceInput?
    var movieFileOutput: AVCaptureMovieFileOutput?
    var stillImageOutput: AVCaptureStillImageOutput?
    
    fileprivate let videoDataOutput = AVCaptureVideoDataOutput()
    
    var deviceAuthorized: Bool  = false
    var backgroundRecordId: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    
    var sessionRunningAndDeviceAuthorized: Bool {
        get {
            return (self.session?.isRunning != nil && self.deviceAuthorized )
        }
    }
    
    var runtimeErrorHandlingObserver: AnyObject?
    var lockInterfaceRotation: Bool = false
    
    fileprivate var qlController: QLPreviewController!
    fileprivate var previewItem: PreviewItem!
    fileprivate var pdfDatasource: PreviewDatasource!
    fileprivate let itemURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("capture.jpg")
    
    fileprivate let videoDataOutputQueue = DispatchQueue(label: "video data queue")
    
    fileprivate var desiredVideoOrientation: AVCaptureVideoOrientation {
        switch UIDevice.current.orientation {
        case .portrait, .portraitUpsideDown, .faceUp, .faceDown, .unknown:
            return .portrait
        case .landscapeLeft:
            return .landscapeRight
        case .landscapeRight:
            return .landscapeLeft
        }
    }
    
    
    // MARK: - LyfeCicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        print("Camera resolution = \(self.getCaptureResolution())")
        self.resolution = CameraResolution(width: self.getCaptureResolution().width, height: self.getCaptureResolution().height)
        
        let session: AVCaptureSession = AVCaptureSession()
        self.session = session
        
        self.previewView.session = session
        self.previewView.session?.sessionPreset = AVCaptureSessionPresetPhoto
        
        self.checkDeviceAuthorizationStatus()
        
        let sessionQueue: DispatchQueue = DispatchQueue(label: "com.sic.cam.sessionQueue",attributes: [])
        
        self.sessionQueue = sessionQueue
        
        sessionQueue.async {
            self.backgroundRecordId = UIBackgroundTaskInvalid
            
            let videoDevice: AVCaptureDevice! = AVCameraViewController.deviceWithMediaType(AVMediaTypeVideo, preferringPosition: AVCaptureDevicePosition.back)
            var error: NSError? = nil
            
            
            var videoDeviceInput: AVCaptureDeviceInput?
            do {
                videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            } catch let error1 as NSError {
                error = error1
                videoDeviceInput = nil
            } catch {
                fatalError()
            }
            
            if (error != nil) {
                print(error!)
                let alert = UIAlertController(title: "Error", message: error!.localizedDescription
                    , preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
            if session.canAddInput(videoDeviceInput){
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
                
                DispatchQueue.main.async {
                    // Why are we dispatching this to the main queue?
                    // Because AVCaptureVideoPreviewLayer is the backing layer for AVCamPreviewView and UIView can only be manipulated on main thread.
                    // Note: As an exception to the above rule, it is not necessary to serialize video orientation changes on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
                    
                    let orientation: AVCaptureVideoOrientation =  AVCaptureVideoOrientation(rawValue: UIDevice.current.orientation.rawValue)!
                    
                    (self.previewView.layer as! AVCaptureVideoPreviewLayer).connection.videoOrientation = orientation
                    (self.previewView.layer as! AVCaptureVideoPreviewLayer).videoGravity = AVLayerVideoGravityResizeAspectFill
                }
            }
            
            let audioCheck = AVCaptureDevice.devices(withMediaType: AVMediaTypeAudio)
            if (audioCheck?.isEmpty)! {
                print("no audio device")
                return
            }
            let audioDevice: AVCaptureDevice! = audioCheck!.first as! AVCaptureDevice
            
            var audioDeviceInput: AVCaptureDeviceInput?
            
            do {
                audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice)
            } catch let error2 as NSError {
                error = error2
                audioDeviceInput = nil
            } catch {
                fatalError()
            }
            
            if error != nil{
                print(error!)
                let alert = UIAlertController(title: "Error", message: error!.localizedDescription
                    , preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            if session.canAddInput(audioDeviceInput){
                session.addInput(audioDeviceInput)
            }
            
            let movieFileOutput: AVCaptureMovieFileOutput = AVCaptureMovieFileOutput()
            if session.canAddOutput(movieFileOutput){
                session.addOutput(movieFileOutput)
                
                let connection: AVCaptureConnection? = movieFileOutput.connection(withMediaType: AVMediaTypeVideo)
                let stab = connection?.isVideoStabilizationSupported
                if (stab != nil) {
                    connection!.preferredVideoStabilizationMode = .auto
                }
                self.movieFileOutput = movieFileOutput
            }
            
            let stillImageOutput: AVCaptureStillImageOutput = AVCaptureStillImageOutput()
            if session.canAddOutput(stillImageOutput) {
                stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
                session.addOutput(stillImageOutput)
                
                self.stillImageOutput = stillImageOutput
            }
        }
        
        qlController = QLPreviewController()
        previewItem = PreviewItem(itemURL: itemURL, itemTitle: itemURL.deletingPathExtension().lastPathComponent)
        pdfDatasource = PreviewDatasource(previewItem: previewItem)
        qlController.dataSource = pdfDatasource
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.sessionQueue.async {
            
            self.addObserver(self, forKeyPath: "sessionRunningAndDeviceAuthorized", options: [.old , .new] , context: &SessionRunningAndDeviceAuthorizedContext)
            self.addObserver(self, forKeyPath: "stillImageOutput.capturingStillImage", options:[.old , .new], context: &CapturingStillImageContext)
            self.addObserver(self, forKeyPath: "movieFileOutput.recording", options: [.old , .new], context: &RecordingContext)
            
            NotificationCenter.default.addObserver(self, selector: #selector(AVCameraViewController.subjectAreaDidChange(_:)), name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange, object: self.videoDeviceInput?.device)
            
            self.runtimeErrorHandlingObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVCaptureSessionRuntimeError, object: self.session, queue: nil) {
                (note: Notification?) in
                self.sessionQueue.async { [unowned self] in
                    if let sess = self.session {
                        sess.startRunning()
                    }
                    //                    strongSelf.recordButton.title  = NSLocalizedString("Record", "Recording button record title")
                }
            }
            
            (self.previewView.layer as! AVCaptureVideoPreviewLayer).connection.videoOrientation = self.desiredVideoOrientation
            
            /// MARK: - isn't work, update queue
            if let captureSession = self.session {
                if captureSession.canAddOutput(self.videoDataOutput) {
                    captureSession.addOutput(self.videoDataOutput)
                    self.videoDataOutput.alwaysDiscardsLateVideoFrames = true
                    self.videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
                    self.videoDataOutput.setSampleBufferDelegate(self, queue: self.videoDataOutputQueue)
                }
                
                captureSession.commitConfiguration()
            }
            
            self.session?.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.sessionQueue.async {
            if let sess = self.session {
                sess.stopRunning()
                
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange, object: self.videoDeviceInput?.device)
                NotificationCenter.default.removeObserver(self.runtimeErrorHandlingObserver!)
                
                self.removeObserver(self, forKeyPath: "sessionRunningAndDeviceAuthorized", context: &SessionRunningAndDeviceAuthorizedContext)
                
                self.removeObserver(self, forKeyPath: "stillImageOutput.capturingStillImage", context: &CapturingStillImageContext)
                self.removeObserver(self, forKeyPath: "movieFileOutput.recording", context: &RecordingContext)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Layout
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        
        (self.previewView.layer as! AVCaptureVideoPreviewLayer).connection.videoOrientation = AVCaptureVideoOrientation(rawValue: toInterfaceOrientation.rawValue)!
        
        //        if let layer = self.previewView.layer as? AVCaptureVideoPreviewLayer{
        //            layer.connection.videoOrientation = self.convertOrientation(toInterfaceOrientation)
        //        }
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
    }
}

extension AVCameraViewController {
    
    //    observeValueForKeyPath:ofObject:change:context:
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if context == &CapturingStillImageContext{
            let isCapturingStillImage: Bool = (change![NSKeyValueChangeKey.newKey]! as AnyObject).boolValue
            if isCapturingStillImage {
                self.runStillImageCaptureAnimation()
            }
            
        } else if context  == &RecordingContext{
            let isRecording: Bool = (change![NSKeyValueChangeKey.newKey]! as AnyObject).boolValue
            
            DispatchQueue.main.async {
                if isRecording {
                    self.recordButton.titleLabel!.text = "Stop"
                    self.recordButton.isEnabled = true
                    //                    self.snapButton.enabled = false
                    self.cameraButton.isEnabled = false
                } else {
                    //                    self.snapButton.enabled = true
                    self.recordButton.titleLabel!.text = "Record"
                    self.recordButton.isEnabled = true
                    self.cameraButton.isEnabled = true
                }
            }
            
        } else {
            return super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    // MARK: Selector
    func subjectAreaDidChange(_ notification: Notification){
        let devicePoint: CGPoint = CGPoint(x: 0.5, y: 0.5)
        self.focusWithMode(AVCaptureFocusMode.continuousAutoFocus, exposureMode: AVCaptureExposureMode.continuousAutoExposure, point: devicePoint, monitorSubjectAreaChange: false)
    }
    
    // MARK:  Custom Function
    
    func focusWithMode(_ focusMode:AVCaptureFocusMode, exposureMode:AVCaptureExposureMode, point:CGPoint, monitorSubjectAreaChange:Bool){
        
        self.sessionQueue.async {
            let device: AVCaptureDevice! = self.videoDeviceInput!.device
            
            do {
                try device.lockForConfiguration()
                
                if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(focusMode){
                    device.focusMode = focusMode
                    device.focusPointOfInterest = point
                }
                if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode){
                    device.exposurePointOfInterest = point
                    device.exposureMode = exposureMode
                }
                device.isSubjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
                device.unlockForConfiguration()
                
            } catch {
                print(error)
            }
        }
        
    }
    
    class func setFlashMode(_ flashMode: AVCaptureFlashMode, device: AVCaptureDevice){
        
        if device.hasFlash && device.isFlashModeSupported(flashMode) {
            var error: NSError? = nil
            do {
                try device.lockForConfiguration()
                device.flashMode = flashMode
                device.unlockForConfiguration()
                
            } catch let error1 as NSError {
                error = error1
                print(error!)
            }
        }
    }
    
    func runStillImageCaptureAnimation(){
        DispatchQueue.main.async {
            self.previewView.layer.opacity = 0.0
            print("opacity 0")
            UIView.animate(withDuration: 0.25, animations: {
                self.previewView.layer.opacity = 1.0
                print("opacity 1")
            })
        }
    }
    
    class func deviceWithMediaType(_ mediaType: String, preferringPosition:AVCaptureDevicePosition) -> AVCaptureDevice? {
        
        var devices = AVCaptureDevice.devices(withMediaType: mediaType);
        
        if (devices?.isEmpty)! {
            print("This device has no camera. Probably the simulator.")
            return nil
        } else {
            var captureDevice: AVCaptureDevice = devices![0] as! AVCaptureDevice
            
            for device in devices! {
                if (device as AnyObject).position == preferringPosition {
                    captureDevice = device as! AVCaptureDevice
                    break
                }
            }
            return captureDevice
        }
    }
    
    func checkDeviceAuthorizationStatus(){
        let mediaType:String = AVMediaTypeVideo;
        
        AVCaptureDevice.requestAccess(forMediaType: mediaType) { (granted: Bool) in
            if granted {
                self.deviceAuthorized = true;
            } else {
                
                DispatchQueue.main.async {
                    let alert: UIAlertController = UIAlertController(
                        title: "AVCam",
                        message: "AVCam does not have permission to access camera",
                        preferredStyle: UIAlertControllerStyle.alert)
                    let action = UIAlertAction(title: "OK", style: .default) { _ in }
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
                self.deviceAuthorized = false;
            }
        }
    }
    
    
    // MARK: File Output Delegate
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        
        if error != nil {
            print(error)
        }
        
        self.lockInterfaceRotation = false
        
        // Note the backgroundRecordingID for use in the ALAssetsLibrary completion handler to end the background task associated with this recording. This allows a new recording to be started, associated with a new UIBackgroundTaskIdentifier, once the movie file output's -isRecording is back to NO — which happens sometime after this method returns.
        
        let backgroundRecordId: UIBackgroundTaskIdentifier = self.backgroundRecordId
        self.backgroundRecordId = UIBackgroundTaskInvalid
        
        
        ALAssetsLibrary().writeVideoAtPath(toSavedPhotosAlbum: outputFileURL, completionBlock: { (assetURL, error) in
            if error != nil{
                print(error!)
            }
            
            do {
                try FileManager.default.removeItem(at: outputFileURL)
            } catch {
                print(error)
            }
            
            if backgroundRecordId != UIBackgroundTaskInvalid {
                UIApplication.shared.endBackgroundTask(backgroundRecordId)
            }
        })
    }
}


extension AVCameraViewController {
    
    // MARK: Actions
    
    @IBAction func toggleMovieRecord(_ sender: AnyObject) {
        
        self.recordButton.isEnabled = false
        
        self.sessionQueue.async {
            if !self.movieFileOutput!.isRecording{
                self.lockInterfaceRotation = true
                
                if UIDevice.current.isMultitaskingSupported {
                    self.backgroundRecordId = UIApplication.shared.beginBackgroundTask(expirationHandler: {})
                }
                
                self.movieFileOutput!.connection(withMediaType: AVMediaTypeVideo).videoOrientation =
                    AVCaptureVideoOrientation(rawValue: (self.previewView.layer as! AVCaptureVideoPreviewLayer).connection.videoOrientation.rawValue )!
                
                // Turning OFF flash for video recording
                AVCameraViewController.setFlashMode(AVCaptureFlashMode.off, device: self.videoDeviceInput!.device)
                
                let outputFilePath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("movie.mov")
                
                self.movieFileOutput!.startRecording( toOutputFileURL: outputFilePath, recordingDelegate: self)
            } else {
                self.movieFileOutput!.stopRecording()
            }
        }
    }
    
    @IBAction func snapStillImage(_ sender: AnyObject) {
        print("snapStillImage")
        self.sessionQueue.async {
            // Update the orientation on the still image output video connection before capturing.
            
            let videoOrientation =  (self.previewView.layer as! AVCaptureVideoPreviewLayer).connection.videoOrientation
            
            self.stillImageOutput!.connection(withMediaType: AVMediaTypeVideo).videoOrientation = videoOrientation
            
            // Flash set to Auto for Still Capture
            AVCameraViewController.setFlashMode(AVCaptureFlashMode.auto, device: self.videoDeviceInput!.device)
            
            self.stillImageOutput?.captureStillImageAsynchronously(from: self.stillImageOutput!.connection(withMediaType: AVMediaTypeVideo), completionHandler: { (imageDataSampleBuffer, error) in
                
                if error == nil {
                    if let data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer) {
                        
                        /*
                         try? data.write(to: self.itemURL)
                         self.qlController.reloadData()
                         self.present(self.qlController, animated: true, completion: nil)
                        */
                        
                         /*
                         let image:UIImage = UIImage( data: data)!
                         
                         let libaray:ALAssetsLibrary = ALAssetsLibrary()
                         let orientation: ALAssetOrientation = ALAssetOrientation(rawValue: image.imageOrientation.rawValue)!
                         libaray.writeImage(toSavedPhotosAlbum: image.cgImage, orientation: orientation, completionBlock: nil)
                         */
                        
                        
                        let image = self.contentsOfResolutionIndependentFile(self.itemURL)
                        try? data.write(to: self.itemURL)
                        
                        let cropController = CustomCropViewController()
                        cropController.image = image
                        cropController.cameraResolution = self.resolution
                        self.present(cropController, animated: true, completion: nil)
                        
                        print("save to album")
                    }
                    
                } else {
                    print("Did not capture still image")
                    print(error!)
                }
            })
        }
    }
    
    @IBAction func changeCamera(_ sender: AnyObject) {
        
        print("Camera changed")
        
        self.cameraButton.isEnabled = false
        self.recordButton.isEnabled = false
        self.snapButton.isEnabled = false
        
        self.sessionQueue.async {
            
            let currentVideoDevice:AVCaptureDevice = self.videoDeviceInput!.device
            let currentPosition: AVCaptureDevicePosition = currentVideoDevice.position
            var preferredPosition: AVCaptureDevicePosition = AVCaptureDevicePosition.unspecified
            
            switch currentPosition {
            case AVCaptureDevicePosition.front:
                preferredPosition = AVCaptureDevicePosition.back
            case AVCaptureDevicePosition.back:
                preferredPosition = AVCaptureDevicePosition.front
            case AVCaptureDevicePosition.unspecified:
                preferredPosition = AVCaptureDevicePosition.back
                
            }
            
            guard let device = AVCameraViewController.deviceWithMediaType(AVMediaTypeVideo, preferringPosition: preferredPosition) else {
                print("there is no AVCapture Device")
                return
            }
            
            var videoDeviceInput: AVCaptureDeviceInput?
            
            do {
                videoDeviceInput = try AVCaptureDeviceInput(device: device)
            } catch _ as NSError {
                videoDeviceInput = nil
            } catch {
                fatalError()
            }
            
            self.session!.beginConfiguration()
            self.session!.removeInput(self.videoDeviceInput)
            
            if self.session!.canAddInput(videoDeviceInput) {
                
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange, object:currentVideoDevice)
                
                AVCameraViewController.setFlashMode(AVCaptureFlashMode.auto, device: device)
                
                NotificationCenter.default.addObserver(self, selector: #selector(AVCameraViewController.subjectAreaDidChange(_:)), name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange, object: device)
                
                self.session!.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
                
            } else {
                self.session!.addInput(self.videoDeviceInput)
            }
            
            self.session!.commitConfiguration()
            
            DispatchQueue.main.async {
                self.recordButton.isEnabled = true
                self.snapButton.isEnabled = true
                self.cameraButton.isEnabled = true
            }
        }
    }
    
    @IBAction func focusAndExposeTap(_ gestureRecognizer: UIGestureRecognizer) {
        print("focusAndExposeTap")
        let devicePoint: CGPoint = (self.previewView.layer as! AVCaptureVideoPreviewLayer).captureDevicePointOfInterest(for: gestureRecognizer.location(in: gestureRecognizer.view))
        
        print(devicePoint)
        
        self.focusWithMode(AVCaptureFocusMode.autoFocus, exposureMode: AVCaptureExposureMode.autoExpose, point: devicePoint, monitorSubjectAreaChange: true)
    }
    
    @IBAction func closeTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}


// MARK: - Get camera resolution

extension AVCameraViewController {
    
    /// Returns the current screen resolution (differs by device type)
    func getCaptureResolution() -> CGSize {
        // Define default resolution
        var resolution = CGSize(width: 0, height: 0)
        
        // Set if video portrait orientation
        let portraitOrientation = (UIScreen.main.bounds.height > UIScreen.main.bounds.width)
        
        let captureDevice = AVCameraViewController.deviceWithMediaType(AVMediaTypeVideo, preferringPosition: AVCaptureDevicePosition.back)
        
        if let formatDescription = captureDevice?.activeFormat.formatDescription {
            let dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription)
            resolution = CGSize(width: CGFloat(dimensions.width), height: CGFloat(dimensions.height))
        } else {
            print("formatDescription error. Setting resolution to screen default")
            resolution = CGSize(width: CGFloat(UIScreen.main.bounds.width), height: CGFloat(UIScreen.main.bounds.height))
        }
        
        if (!portraitOrientation) {
            resolution = CGSize(width: resolution.height, height: resolution.width)
        }
        
        // Return resolution
        return resolution
    }
}


// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension AVCameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        print("captureOutput")
        
    }
}


extension AVCameraViewController {

    func contentsOfResolutionIndependentFile(_ fileURL: URL) -> UIImage? {
        if let systemVesion = CInt(UIDevice.current.systemVersion) {
            if systemVesion >= 7 && UIScreen.main.scale == 2.0 {
                let path2xURL = URL(fileURLWithPath: fileURL.deletingLastPathComponent().lastPathComponent).appendingPathComponent("\(fileURL.deletingPathExtension().lastPathComponent)2x.\(fileURL.pathExtension)")
                
                if FileManager.default.fileExists(atPath: path2xURL.path) {
                    if let dataImage = try? Data(contentsOf: path2xURL), let cgImage = UIImage(data: dataImage)?.cgImage {
                        return UIImage(cgImage: cgImage, scale: 2.0, orientation: .up)
                    }
                }
            }
        }
        
        return UIImage(contentsOfFile: fileURL.path)
    }
}




