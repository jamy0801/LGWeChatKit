//
//  LGVideoController.swift
//  LGWeChatKit
//
//  Created by jamy on 11/4/15.
//  Copyright © 2015 jamy. All rights reserved.
//

import UIKit
import AVFoundation

class LGVideoController: UIViewController {

    var totalTimer: String!
    var playItem: AVPlayerItem!
    var playView: LGAVPlayView!
    var timerObserver: AnyObject?
    
     init() {
        super.init(nibName: nil, bundle: nil)
        playView = LGAVPlayView(frame: view.bounds)
         view.addSubview(playView)
        playView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tapView:"))
    }
    
    func tapView(gesture: UITapGestureRecognizer) {
        removeConfigure()
        dismissViewControllerAnimated(true) { () -> Void in
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        removeConfigure()
    }
    
    func removeConfigure() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        playItem.removeObserver(self, forKeyPath: "status", context: nil)
        if let observer = timerObserver {
            let layer = playView.layer as! AVPlayerLayer
            layer.player?.removeTimeObserver(observer)
        }
        playView.removeFromSuperview()
        playView = nil
    }
    
    // MARK: - 初始化配置
    
    func setPlayUrl(url: NSURL) {
        playItem = AVPlayerItem(URL: url)
        configurationItem()
    }
    
    func setPlayAsset(asset: AVAsset) {
        playItem = AVPlayerItem(asset: asset)
        configurationItem()
    }
    
    func configurationItem() {
        let play = AVPlayer(playerItem: playItem)
        let layer = playView.layer as! AVPlayerLayer
        layer.player = play
        
        playItem.addObserver(self, forKeyPath: "status", options: .New, context: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "videoPlayDidEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
    }
    
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "status" {
            if playItem.status == .ReadyToPlay {
                let dutation = playItem.duration
                let totalSecond = CGFloat(playItem.duration.value) / CGFloat(playItem.duration.timescale)
                totalTimer = converTimer(totalSecond)
                configureSlider(dutation)
                monitoringPlayback(self.playItem)
                
                let layer = playView.layer as! AVPlayerLayer
                layer.player?.play()
            }
        }
    }
    
    func videoPlayDidEnd(notifation: NSNotification) {
        playItem.seekToTime(CMTimeMake(0, 1))
    }

    // MARK: operation
    
    func converTimer(time: CGFloat) -> String {
        let date = NSDate(timeIntervalSince1970: Double(time))
        let dateFormat = NSDateFormatter()
        if time / 3600 >= 1 {
            dateFormat.dateFormat = "HH:mm:ss"
        } else {
            dateFormat.dateFormat = "mm:ss"
        }
        let formatTime = dateFormat.stringFromDate(date)
        
        return formatTime
    }
    
    
    func configureSlider(duration: CMTime) {
        playView.slider.maximumValue = Float(CMTimeGetSeconds(duration))
    }
    
    func monitoringPlayback(item: AVPlayerItem) {
        let layer = playView.layer as! AVPlayerLayer
        timerObserver = layer.player!.addPeriodicTimeObserverForInterval(CMTimeMake(1, 1), queue: nil, usingBlock: { (time) -> Void in
            let currentSecond = item.currentTime().value / Int64(item.currentTime().timescale)
            self.playView.slider.setValue(Float(currentSecond), animated: true)
            let timeStr = self.converTimer(CGFloat(currentSecond))
            self.playView.timerIndicator.text = "\(timeStr)/\(self.totalTimer)"
        })
    }
}
