//
//  LGRecordVideo.swift
//  record
//
//  Created by jamy on 11/6/15.
//  Copyright © 2015 jamy. All rights reserved.
//

import Foundation
import AVFoundation
import Photos
import UIKit


private let needSaveToPHlibrary = false

class LGRecordVideoModel: NSObject, AVCaptureFileOutputRecordingDelegate {
    var captureSession: AVCaptureSession!
    var captureDeviceInput: AVCaptureDeviceInput!
    var captureMovieFileOutput: AVCaptureMovieFileOutput!
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier!
    
    var filePath: NSURL?
    var fileName: String!
    
    var complectionClosure: ((NSURL) -> Void)?
    var cancelClosure: (Void -> Void)?
    
    override init() {
        super.init()
        captureSession = AVCaptureSession()
        let captureDevice = getCameraDevice(.Back)
        if captureDevice == nil {
            return
        }
        let audioCaptureDevice = AVCaptureDevice.devicesWithMediaType(AVMediaTypeAudio).first as! AVCaptureDevice
        
        var audioCaptureDeviceInput: AVCaptureDeviceInput?
        do {
            try audioCaptureDeviceInput = AVCaptureDeviceInput(device: audioCaptureDevice)
        } catch let error as NSError {
            NSLog("%@", error)
            return
        }
        
        do {
            try captureDeviceInput = AVCaptureDeviceInput(device: captureDevice)
        } catch let error as NSError {
            NSLog("%@", error)
            return
        }
        
        captureSession.beginConfiguration()
        captureMovieFileOutput = AVCaptureMovieFileOutput()
        
        if captureSession.canAddInput(captureDeviceInput) {
            captureSession.addInput(captureDeviceInput)
            captureSession.addInput(audioCaptureDeviceInput!)
        }
        
        if captureSession.canAddOutput(captureMovieFileOutput) {
            captureSession.addOutput(captureMovieFileOutput)
            let connection = captureMovieFileOutput.connectionWithMediaType(AVMediaTypeVideo)
            if connection.supportsVideoStabilization {
                connection.preferredVideoStabilizationMode = .Auto
            }
        }
        captureSession.commitConfiguration()
        
        addNotificationToDevice(captureDevice!)
    }
 
    deinit {
        captureSession.removeInput(captureDeviceInput)
        captureSession.removeInput(captureDeviceInput)
        captureSession.removeOutput(captureMovieFileOutput)
        removeNotification()
    }
    
    func getCameraDevice(position: AVCaptureDevicePosition) -> (AVCaptureDevice?) {
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        for device in devices {
            let device = device as! AVCaptureDevice
            if device.position == position {
                return device
            }
        }
        return nil
    }
    
    func start() {
        captureSession.startRunning()
    }
    
    func stop() {
        captureSession.stopRunning()
    }
    
    func addNotificationToDevice(newCaptureDevice: AVCaptureDevice) {
        let captureDevice = captureDeviceInput.device
        do {
            try captureDevice.lockForConfiguration()
        } catch let error as NSError {
            NSLog("%@", error)
            return
        }
        captureDevice.subjectAreaChangeMonitoringEnabled = true
        captureDevice.unlockForConfiguration()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "notificateAreChanged:", name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: newCaptureDevice)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "notificateSessionError:", name: AVCaptureSessionRuntimeErrorNotification, object: captureSession)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sessionWasInterrupted:", name: AVCaptureSessionWasInterruptedNotification, object: captureSession)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sessionInterruptEnd:", name: AVCaptureSessionInterruptionEndedNotification, object: captureSession)
    }
    
    func removeNotificationFromDevice(oldCaptureDevice: AVCaptureDevice) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: oldCaptureDevice)
    }
    
    func removeNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func notificateAreChanged(notification: NSNotification) {
        
    }
    
    func sessionWasInterrupted(notification: NSNotification) {
        NSLog("------sessionWasInterrupted---------")
    }
    
    func sessionInterruptEnd(notification: NSNotification) {
         NSLog("------sessionInterruptEnd---------")
    }
    
    func notificateSessionError(notification: NSNotification) {
        NSLog("notificateSessionError")
    }
    
    func beginRecord() {
        if !captureMovieFileOutput.recording {
            if UIDevice.currentDevice().multitaskingSupported {
                backgroundTaskIdentifier = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler(nil)
            }
            
            var fileName = String(stringInterpolationSegment: arc4random_uniform(1000))
            fileName = fileName + ".m4v"
            let filePath = NSString(string: NSTemporaryDirectory()).stringByAppendingPathComponent(fileName)
            let fileUrl = NSURL(fileURLWithPath: filePath)
            
            self.fileName = fileName
            self.filePath = fileUrl
            
            captureMovieFileOutput.startRecordingToOutputFileURL(fileUrl, recordingDelegate: self)
        } else {
            captureMovieFileOutput.stopRecording()
        }
    }
    
    func complectionRecord() {
        if captureMovieFileOutput.recording {
            captureMovieFileOutput.stopRecording()
        }
    }
    
    func cancelRecord() {
        if captureMovieFileOutput.recording {
            captureMovieFileOutput.stopRecording()
        }
        if filePath != nil {
            do {
                try NSFileManager.defaultManager().removeItemAtURL(filePath!)
            } catch let error as NSError {
                NSLog("remove file error: %@", error)
            }
        }
        
        if let cancelOperation = cancelClosure {
            cancelOperation()
        }
    }
    
    func changeCameraPosition() {
        let currentDevice = captureDeviceInput.device
        let currentPosition = currentDevice.position
        removeNotificationFromDevice(currentDevice)
        
        var changePosition: AVCaptureDevicePosition = .Front
        if currentPosition == .Unspecified || currentPosition == .Front {
            changePosition = .Back
        }
        
        if let changeDevice = getCameraDevice(changePosition) {
            addNotificationToDevice(changeDevice)
            var changeDeviceInput: AVCaptureDeviceInput!
            do {
                changeDeviceInput = try AVCaptureDeviceInput(device: changeDevice)
            } catch let error as NSError {
                NSLog("changeCamera: %@", error)
                return
            }
            
            captureSession.beginConfiguration()
            captureSession.removeInput(captureDeviceInput)
            if captureSession.canAddInput(changeDeviceInput) {
                captureSession.addInput(changeDeviceInput)
                captureDeviceInput = changeDeviceInput
            }
            captureSession.commitConfiguration()
        }
    }
    
    func setFlashMode(flashMode: AVCaptureFlashMode) {
        let captureDevice = captureDeviceInput.device
        do {
            try captureDevice.lockForConfiguration()
        } catch let error as NSError {
            NSLog("%@", error)
            return
        }
        if captureDevice.isFlashModeSupported(flashMode) {
            captureDevice.flashMode = flashMode
        }
        captureDevice.unlockForConfiguration()
    }
    
    
    func setFocusMode(focusMode: AVCaptureFocusMode) {
        let captureDevice = captureDeviceInput.device
        do {
            try captureDevice.lockForConfiguration()
        } catch let error as NSError {
            NSLog("%@", error)
            return
        }
        if captureDevice.isFocusModeSupported(focusMode) {
            captureDevice.focusMode = focusMode
        }
        captureDevice.unlockForConfiguration()
    }
    
    func setFocusExposureMode(focusMode: AVCaptureFocusMode, exposureMode: AVCaptureExposureMode, point: CGPoint) {
        let captureDevice = captureDeviceInput.device
        do {
            try captureDevice.lockForConfiguration()
        } catch let error as NSError {
            NSLog("%@", error)
            return
        }
        
        if captureDevice.isFocusModeSupported(focusMode) {
            captureDevice.focusMode = focusMode
        }
        if captureDevice.focusPointOfInterestSupported {
            captureDevice.focusPointOfInterest = point
        }
        
        if captureDevice.isExposureModeSupported(exposureMode) {
            captureDevice.exposureMode = exposureMode
        }
        if captureDevice.exposurePointOfInterestSupported {
            captureDevice.exposurePointOfInterest = point
        }
        
        captureDevice.unlockForConfiguration()
    }
 
    // MARK: delegate
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        NSLog("begin record")
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        NSLog("record finish")
        if error == nil {
            
            let lastBackgroundTaskIdentifier = backgroundTaskIdentifier
            self.backgroundTaskIdentifier = UIBackgroundTaskInvalid
            if let complection = complectionClosure {
                complection(filePath!)
            }
            
            if needSaveToPHlibrary {
                PHPhotoLibrary.sharedPhotoLibrary().performChanges({ () -> Void in
                    PHAssetCreationRequest.creationRequestForAsset().addResourceWithType(.Video, fileURL: outputFileURL, options: nil)
                    }) { (finish, errors) -> Void in
                        if errors == nil {
                            NSLog("保存成功")
                        } else {
                            NSLog("保存失败：%@", errors!)
                        }
                        if lastBackgroundTaskIdentifier != UIBackgroundTaskInvalid {
                            UIApplication.sharedApplication().endBackgroundTask(lastBackgroundTaskIdentifier)
                        }
                }
            }
        } else {
            NSLog("record error:%@", error)
        }
    }
    
}
