//
//  LGRecordView.swift
//  record
//
//  Created by jamy on 11/6/15.
//  Copyright © 2015 jamy. All rights reserved.
//  该模块未使用autolayout

import UIKit
import AVFoundation


private let buttonW: CGFloat = 60
class LGRecordVideoView: UIView {
    
    var videoView: UIView!
    var indicatorView: UILabel!
    var recordButton: UIButton!
    var progressView: UIProgressView!
    var progressView2: UIProgressView!
    var recordVideoModel: LGRecordVideoModel!
    var preViewLayer: AVCaptureVideoPreviewLayer!
    
    var recordTimer: NSTimer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    func customInit() {
        backgroundColor = UIColor.blackColor()
        
        if TARGET_IPHONE_SIMULATOR == 1 {
            NSLog("simulator can't do this!!!")
        } else {
            recordVideoModel = LGRecordVideoModel()
            
            videoView = UIView(frame: CGRectMake(0, 0, bounds.width, bounds.height * 0.7))
            videoView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            addSubview(videoView)
            
            preViewLayer = AVCaptureVideoPreviewLayer(session: recordVideoModel.captureSession)
            preViewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            preViewLayer.frame = videoView.bounds
            videoView.layer.insertSublayer(preViewLayer, atIndex: 0)
            
            recordButton = UIButton(type: .Custom)
            recordButton.setTitleColor(UIColor.orangeColor(), forState: .Normal)
            recordButton.layer.cornerRadius = buttonW / 2
            recordButton.layer.borderWidth = 1.5
            recordButton.layer.borderColor = UIColor.orangeColor().CGColor
            recordButton.setTitle("按住拍", forState: .Normal)
            recordButton.addTarget(self, action: "buttonTouchDown", forControlEvents: .TouchDown)
            recordButton.addTarget(self, action: "buttonDragOutside", forControlEvents: .TouchDragOutside)
            recordButton.addTarget(self, action: "buttonCancel", forControlEvents: .TouchUpOutside)
            recordButton.addTarget(self, action: "buttonTouchUp", forControlEvents: .TouchUpInside)
            addSubview(recordButton)
            
            progressView = UIProgressView(frame: CGRectZero)
            progressView.progressTintColor = UIColor.blackColor()
            progressView.trackTintColor = UIColor.orangeColor()
            progressView.hidden = true
            addSubview(progressView)
            
            progressView2 = UIProgressView(frame: CGRectZero)
            progressView2.progressTintColor = UIColor.blackColor()
            progressView2.trackTintColor = UIColor.orangeColor()
            progressView2.hidden = true
            addSubview(progressView2)
            progressView2.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
            
            indicatorView = UILabel()
            indicatorView.textColor = UIColor.whiteColor()
            indicatorView.font = UIFont.systemFontOfSize(12.0)
            indicatorView.backgroundColor = UIColor.redColor()
            indicatorView.hidden = true
            addSubview(indicatorView)
            
            recordButton.bounds = CGRectMake(0, 0, buttonW, buttonW)
            recordButton.center = CGPointMake(center.x, videoView.frame.height + buttonW)
            
            progressView.frame = CGRectMake(0, videoView.frame.height, bounds.width / 2, 2)
            progressView2.frame = CGRectMake(bounds.width / 2 - 1, videoView.frame.height, bounds.width / 2 + 1, 2)
            
            indicatorView.center = CGPointMake(center.x, videoView.frame.height - 20)
            indicatorView.bounds = CGRectMake(0, 0, 50, 20)
        }
    }
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        if TARGET_IPHONE_SIMULATOR == 0 {
            recordVideoModel.start()
        }
    }
    
    func buttonTouchDown() {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.recordButton.transform = CGAffineTransformMakeScale(1.5, 1.5)
            }) { (finish) -> Void in
                self.recordButton.hidden = true
        }
        
        recordVideoModel.beginRecord()
        stopTimer()
        self.progressView.hidden = false
        self.progressView2.hidden = false
        indicatorView.hidden = false
        indicatorView.text = "上移取消"
        recordTimer = NSTimer(timeInterval: 1.0, target: self, selector: "recordTimerUpdate", userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(recordTimer, forMode: NSRunLoopCommonModes)
    }
    
    func buttonDragOutside() {
        indicatorView.hidden = false
        indicatorView.text = "松手取消"
    }
    
    func buttonCancel() {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.recordButton.hidden = false
            self.recordButton.transform = CGAffineTransformIdentity
            }) { (finish) -> Void in
                self.indicatorView.hidden = true
                self.progressView.hidden = true
                self.progressView.progress = 0
                self.progressView2.hidden = true
                self.progressView2.progress = 0
                self.stopTimer()
        }
        recordVideoModel.cancelRecord()
    }
    
    func buttonTouchUp() {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.recordButton.hidden = false
            self.recordButton.transform = CGAffineTransformIdentity
            }) { (finish) -> Void in
                self.indicatorView.hidden = true
                self.progressView.hidden = true
                self.progressView.progress = 0
                self.progressView2.hidden = true
                self.progressView2.progress = 0
                self.stopTimer()
        }
        recordVideoModel.complectionRecord()
    }
    
    func stopTimer() {
        if recordTimer != nil {
            recordTimer.invalidate()
            recordTimer = nil
        }
    }
    
    func recordTimerUpdate() {
        if progressView.progress == 1 {
            buttonTouchUp()
        } else {
            progressView.progress += 0.1
            progressView2.progress += 0.1
        }
    }
}

