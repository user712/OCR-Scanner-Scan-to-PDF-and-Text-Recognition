//
//  CameraSession.swift
//  AVCamera
//
//  Created  on 3/7/17.
//  Copyright © 2017 A. 
//

import UIKit
import Foundation
import AVFoundation

struct CameraSessionContext {
    static var SessionRunningAndDeviceAuthorizedContext = "SessionRunningAndDeviceAuthorizedContext"
    static var CapturingStillImageContext = "CapturingStillImageContext"
    static var RecordingContext = "RecordingContext"
}

class CameraSession: NSObject {
    
    // MARK: - Properties
    
    let previewView: AVCamPreviewView
    let controller: UIViewController
    
    var sessionQueue: DispatchQueue!
    var session: AVCaptureSession?
    var videoDeviceInput: AVCaptureDeviceInput?
    var movieFileOutput: AVCaptureMovieFileOutput?
    var stillImageOutput: AVCaptureStillImageOutput?
    var deviceAuthorized = false
    var backgroundRecordId: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    var sessionRunningAndDeviceAuthorized: Bool {
        get {
            return (self.session?.isRunning != nil && self.deviceAuthorized )
        }
    }
    var runtimeErrorHandlingObserver: AnyObject?
    var lockInterfaceRotation: Bool = false

    
    // MARK: - Initializers
    
    init(previewView: AVCamPreviewView, controller: UIViewController) {
        self.previewView = previewView
        self.controller = controller
        super.init()
        
        prepareCamera()
    }
}

extension CameraSession {
    
    func startCaptureSession() {
        if let captureSession = self.session {
            if !captureSession.isRunning {
                self.prepareCamera()
                self.beginSession()
            }
        }
    }
    
    func stopCaptureSession() {
        if let captureSession = self.session {
            captureSession.stopRunning()
            
            if let inputs = captureSession.inputs as? [AVCaptureInput] {
                for input in inputs {
                    captureSession.removeInput(input)
                }
            }
            
            //        self.captureSession.removeOutput(stillImageOutput)
            
            self.stopSession() 
        }
    }
}

extension CameraSession {
    
     fileprivate func prepareCamera() {
        let session: AVCaptureSession = AVCaptureSession()
        self.session = session
        
        self.previewView.session = session
        self.previewView.session?.sessionPreset = AVCaptureSessionPresetPhoto
        
        self.checkDeviceAuthorizationStatus()
        
        let sessionQueue: DispatchQueue = DispatchQueue(label: "com.Camera.SuperCamera.sessionQueue",attributes: [])
        self.sessionQueue = sessionQueue
        
        sessionQueue.async { [unowned self] in
            self.backgroundRecordId = UIBackgroundTaskInvalid
            
            let videoDevice: AVCaptureDevice! = CameraSession.deviceWithMediaType(AVMediaTypeVideo, preferringPosition: AVCaptureDevicePosition.back)
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
                self.controller.present(alert, animated: true, completion: nil)
            }
            
            if session.canAddInput(videoDeviceInput){
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
                
                DispatchQueue.main.async {
                    // Why are we dispatching this to the main queue?
                    // Because AVCaptureVideoPreviewLayer is the backing layer for AVCamPreviewView and UIView can only be manipulated on main thread.
                    // Note: As an exception to the above rule, it is not necessary to serialize video orientation changes on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
                    
                    if let orientation: AVCaptureVideoOrientation =  AVCaptureVideoOrientation(rawValue: UIDevice.current.orientation.rawValue) {
                        if self.previewView.layer is AVCaptureVideoPreviewLayer {
                            (self.previewView.layer as! AVCaptureVideoPreviewLayer).connection.videoOrientation = orientation
                            (self.previewView.layer as! AVCaptureVideoPreviewLayer).videoGravity = AVLayerVideoGravityResizeAspectFill
                        }
                    }
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
                self.controller.present(alert, animated: true, completion: nil)
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
    }
    
    fileprivate func beginSession() {
        self.sessionQueue.async { [unowned self] in
            self.addObserver(self, forKeyPath: "sessionRunningAndDeviceAuthorized", options: [.old , .new] , context: &CameraSessionContext.SessionRunningAndDeviceAuthorizedContext)
            self.addObserver(self, forKeyPath: "stillImageOutput.capturingStillImage", options:[.old , .new], context: &CameraSessionContext.CapturingStillImageContext)
            self.addObserver(self, forKeyPath: "movieFileOutput.recording", options: [.old , .new], context: &CameraSessionContext.RecordingContext)
            
            NotificationCenter.default.addObserver(self, selector: #selector(CameraSession.subjectAreaDidChange(_:)), name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange, object: self.videoDeviceInput?.device)
            
            self.runtimeErrorHandlingObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVCaptureSessionRuntimeError, object: self.session, queue: nil) {
                (note: Notification?) in
                self.sessionQueue.async { [unowned self] in
                    
                    if let sess = self.session {
                        sess.startRunning()
                    }
                    
                    // strongSelf.recordButton.title  = NSLocalizedString("Record", "Recording button record title")
                }
            }
            
            self.session?.startRunning()
        }
    }
    
    fileprivate func stopSession() {
        self.sessionQueue.async { [unowned self] in
            if let sess = self.session {
                sess.stopRunning()
                
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange, object: self.videoDeviceInput?.device)
                NotificationCenter.default.removeObserver(self.runtimeErrorHandlingObserver!)
                self.removeObserver(self, forKeyPath: "sessionRunningAndDeviceAuthorized", context: &CameraSessionContext.SessionRunningAndDeviceAuthorizedContext)
                self.removeObserver(self, forKeyPath: "stillImageOutput.capturingStillImage", context: &CameraSessionContext.CapturingStillImageContext)
                self.removeObserver(self, forKeyPath: "movieFileOutput.recording", context: &CameraSessionContext.RecordingContext)
            }
        }
    }
    
    fileprivate func checkDeviceAuthorizationStatus(){
        let mediaType:String = AVMediaTypeVideo;
        
        AVCaptureDevice.requestAccess(forMediaType: mediaType) { (granted: Bool) in
            if granted {
                self.deviceAuthorized = true;
            } else {
                
                DispatchQueue.main.async { [unowned self] in
                    let alert: UIAlertController = UIAlertController(
                        title: "AVCam",
                        message: "AVCam does not have permission to access camera",
                        preferredStyle: UIAlertControllerStyle.alert)
                    let action = UIAlertAction(title: "OK", style: .default) { _ in }
                    alert.addAction(action)
                    self.controller.present(alert, animated: true, completion: nil)
                }
                self.deviceAuthorized = false;
            }
        }
    }
    
    fileprivate // MARK:  Custom Function
    
    func focusWithMode(_ focusMode: AVCaptureFocusMode, exposureMode: AVCaptureExposureMode, point: CGPoint, monitorSubjectAreaChange: Bool){
        
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
    
    class func deviceWithMediaType(_ mediaType: String, preferringPosition: AVCaptureDevicePosition) -> AVCaptureDevice? {
        
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
    
    // MARK: Selector
    
    @objc fileprivate func subjectAreaDidChange(_ notification: Notification) {
        let devicePoint: CGPoint = CGPoint(x: 0.5, y: 0.5)
        self.focusWithMode(AVCaptureFocusMode.continuousAutoFocus, exposureMode: AVCaptureExposureMode.continuousAutoExposure, point: devicePoint, monitorSubjectAreaChange: false)
    }
}
