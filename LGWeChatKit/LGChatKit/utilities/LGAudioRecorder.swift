//
//  LGAudioRecorder.swift
//  LGChatViewController
//
//  Created by jamy on 10/13/15.
//  Copyright © 2015 jamy. All rights reserved.
//

import UIKit
import AVFoundation

protocol LGAudioRecorderDelegate {
    func audioRecorderUpdateMetra(metra: Float)
}


let soundPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!

let audioSettings: [String: AnyObject] = [AVLinearPCMIsFloatKey: NSNumber(bool: false),
    AVLinearPCMIsBigEndianKey: NSNumber(bool: false),
    AVLinearPCMBitDepthKey: NSNumber(int: 16),
    AVFormatIDKey: NSNumber(unsignedInt: kAudioFormatLinearPCM),
    AVNumberOfChannelsKey: NSNumber(int: 1), AVSampleRateKey: NSNumber(int: 16000),
    AVEncoderAudioQualityKey: NSNumber(integer: AVAudioQuality.Medium.rawValue)]


class LGAudioRecorder: NSObject, AVAudioRecorderDelegate {
    
    var audioData: NSData!
    var operationQueue: NSOperationQueue!
    var recorder: AVAudioRecorder!
    
    var startTime: Double!
    var endTimer: Double!
    var timeInterval: NSNumber!
    
    var delegate: LGAudioRecorderDelegate?
    
    convenience init(fileName: String) {
        self.init()
        
        let filePath = NSURL(fileURLWithPath: (soundPath as NSString).stringByAppendingPathComponent(fileName))
        
        recorder = try! AVAudioRecorder(URL: filePath, settings: audioSettings)
        recorder.delegate = self
        recorder.meteringEnabled = true
        
    }
    
    override init() {
        operationQueue = NSOperationQueue()
        super.init()
    }
    
    func startRecord() {
        startTime = NSDate().timeIntervalSince1970
        performSelector("readyStartRecord", withObject: self, afterDelay: 0.5)
    }
    
    func readyStartRecord() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
        } catch {
            NSLog("setCategory fail")
            return
        }
        
        do {
            try audioSession.setActive(true)
        } catch {
            NSLog("setActive fail")
            return
        }
        recorder.record()
        let operation = NSBlockOperation()
        operation.addExecutionBlock(updateMeters)
        operationQueue.addOperation(operation)
    }
    
    
    func stopRecord() {
        endTimer = NSDate().timeIntervalSince1970
        timeInterval = nil
        if (endTimer - startTime) < 0.5 {
            NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: "readyStartRecord", object: self)
        } else {
            timeInterval = NSNumber(int: NSNumber(double: recorder.currentTime).intValue)
            if timeInterval.intValue < 1 {
                performSelector("readyStopRecord", withObject: self, afterDelay: 0.4)
            } else {
                readyStopRecord()
            }
        }
        operationQueue.cancelAllOperations()
    }
    
    
    func readyStopRecord() {
        recorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false, withOptions: .NotifyOthersOnDeactivation)
        } catch {
            // no-op
        }
        audioData = NSData(contentsOfURL: recorder.url)
    }
    
    func updateMeters() {
        repeat {
            recorder.updateMeters()
            timeInterval = NSNumber(float: NSNumber(double: recorder.currentTime).floatValue)
            let averagePower = recorder.averagePowerForChannel(0)
           // let pearPower = recorder.peakPowerForChannel(0)
          //  NSLog("%@   %f  %f", timeInterval, averagePower, pearPower)
            delegate?.audioRecorderUpdateMetra(averagePower)
            NSThread.sleepForTimeInterval(0.2)
        } while(recorder.recording)
    }
    
    // MARK: audio delegate
    func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder, error: NSError?) {
        NSLog("%@", (error?.localizedDescription)!)
    }
}
