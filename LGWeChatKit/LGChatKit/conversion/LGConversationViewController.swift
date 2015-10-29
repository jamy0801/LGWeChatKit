//
//  LGConversationViewController.swift
//  LGChatViewController
//
//  Created by jamy on 10/9/15.
//  Copyright © 2015 jamy. All rights reserved.
//

import UIKit
import AVFoundation


let toolBarMinHeight: CGFloat = 44.0
let indicatorViewH: CGFloat = 120

class LGConversationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate , UITextViewDelegate, LGAudioRecorderDelegate, LGEmotionViewDelegate, LGImagePickControllerDelegate, LGMapViewControllerDelegate{
    
    var tableView: UITableView!
    var toolBarView: LGToolBarView!
    var emojiView: LGEmotionView!
    var shareView: LGShareMoreView!
    var recordIndicatorView: LGRecordIndicatorView!
    
    var messageList = [Message]()
    
    var recorder: LGAudioRecorder!
    var player: LGAudioPlayer!
    
    // MARK: - lifecycle
    init(){
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
        title = "jamy"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "bg3")!)
        
        tableView = UITableView(frame: CGRectMake(0, 0, view.bounds.width, view.bounds.height - toolBarMinHeight), style: .Plain)
        tableView.backgroundColor = UIColor.clearColor()
        tableView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        tableView.delegate = self
        tableView.dataSource  = self
        tableView.estimatedRowHeight = 44.0
        tableView.contentInset = UIEdgeInsetsMake(0, 0, toolBarMinHeight / 2, 0)
        tableView.separatorStyle = .None
        tableView.registerClass(LGChatImageCell.self, forCellReuseIdentifier: NSStringFromClass(LGChatImageCell))
        tableView.registerClass(LGChatTextCell.self, forCellReuseIdentifier: NSStringFromClass(LGChatTextCell))
        tableView.registerClass(LGChatVoiceCell.self, forCellReuseIdentifier: NSStringFromClass(LGChatVoiceCell))
    
        view.addSubview(tableView)
        
        recordIndicatorView = LGRecordIndicatorView(frame: CGRectMake(self.view.center.x - indicatorViewH / 2, self.view.center.y - indicatorViewH / 3, indicatorViewH, indicatorViewH))
 
        
        emojiView = LGEmotionView(frame: CGRectMake(0, 0, view.bounds.width, 196))
        emojiView.delegate = self
        
        shareView = LGShareMoreView(frame: CGRectMake(0, 0, view.bounds.width, 196), selector: "shareMoreClick:", target: self)
        
        toolBarView = LGToolBarView(taget: self, voiceSelector: "voiceClick:", recordSelector: "recordClick:", emotionSelector: "emotionClick:", moreSelector: "moreClick:")
        toolBarView.textView.delegate = self
        view.addSubview(toolBarView)
        toolBarView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: toolBarView, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: toolBarView, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: toolBarView, attribute: .Top, relatedBy: .Equal, toItem: tableView, attribute: .Bottom, multiplier: 1, constant: 0))
        toolBarView.addConstraint(NSLayoutConstraint(item: toolBarView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: toolBarMinHeight))
        
        
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tapTableView:"))
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardChange:", name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if player != nil {
            if player.audioPlayer.playing {
                player.stopPlaying()
            }
        }
    }
    
    // show menuController
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    // MARK: - tableView dataSource/Delegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageList.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: LGChatBaseCell
        
        let message = messageList[indexPath.row]
        
        switch message.messageType {
        case .Text:
            cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(LGChatTextCell), forIndexPath: indexPath) as! LGChatTextCell
        case .Image:
            cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(LGChatImageCell), forIndexPath: indexPath) as! LGChatImageCell
        case .Voice:
            cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(LGChatVoiceCell), forIndexPath: indexPath) as! LGChatVoiceCell
        }
        
        // add gustureRecognizer to show menu items
        let action: Selector = "showMenuAction:"
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: action)
        doubleTapGesture.numberOfTapsRequired = 2
        cell.backgroundImageView.addGestureRecognizer(doubleTapGesture)
        cell.backgroundImageView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: action))
        cell.backgroundImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "clickCellAction:"))
        
        
        cell.setMessage(message)
        
        return cell
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return nil
    }
    
    
    func scrollToBottom() {
        if messageList.count <= 1 {
            return
        }
        
        let indexPath = NSIndexPath(forRow: messageList.count - 1, inSection: 0)
       tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
    }
    
    func reloadTableView() {
        tableView.reloadData()
        scrollToBottom()
    }
    
    // MARK: - keyBoard notification
    func keyboardChange(notification: NSNotification) {
        let userInfo = notification.userInfo as NSDictionary!
        let newFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let animationTimer = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        if newFrame.origin.y == UIScreen.mainScreen().bounds.size.height {
            UIView.animateWithDuration(animationTimer, animations: { () -> Void in
                self.view.transform = CGAffineTransformIdentity
            })
        } else {
            UIView.animateWithDuration(animationTimer, animations: { () -> Void in
                self.view.transform = CGAffineTransformMakeTranslation(0, -newFrame.size.height)
            })
        }
    }
    
    // MARK: - menu actions
    
    func showMenuAction(gestureRecognizer: UITapGestureRecognizer) {
        let twoTaps = (gestureRecognizer.numberOfTapsRequired == 2)
        let doubleTap = (twoTaps && gestureRecognizer.state == .Ended)
        let longPress = (!twoTaps && gestureRecognizer.state == .Began)
        
        if doubleTap || longPress {
            let pressIndexPath = tableView.indexPathForRowAtPoint(gestureRecognizer.locationInView(tableView))!
            tableView.selectRowAtIndexPath(pressIndexPath, animated: false, scrollPosition: .None)
            
            let menuController = UIMenuController.sharedMenuController()
            let localImageView = gestureRecognizer.view!
            
            menuController.setTargetRect(localImageView.frame, inView: localImageView.superview!)
            menuController.menuItems = [UIMenuItem(title: "复制", action: "copyAction:"), UIMenuItem(title: "转发", action: "transtionAction:"), UIMenuItem(title: "删除", action: "deleteAction:"), UIMenuItem(title: "更多", action: "moreAciton:")]
           
            menuController.setMenuVisible(true, animated: true)
        }
    }
    
    func copyAction(menuController: UIMenuController) {
       // let selectedIndexPath = tableView.indexPathForSelectedRow
        UIPasteboard.generalPasteboard().string = "复制测试！！！"
    }
    
    func transtionAction(menuController: UIMenuController) {
        
    }
    
    func deleteAction(menuController: UIMenuController) {
        
    }
    
    func moreAciton(menuController: UIMenuController) {
        
    }
    
    
    // MARK: - gestureRecognizer
    func tapTableView(gestureRecognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
        toolBarView.showEmotion(false)
        toolBarView.showMore(false)
    }
    
    func clickCellAction(gestureRecognizer: UITapGestureRecognizer) {
        let pressIndexPath = tableView.indexPathForRowAtPoint(gestureRecognizer.locationInView(tableView))!
        let pressCell = tableView.cellForRowAtIndexPath(pressIndexPath)
        let message = messageList[pressIndexPath.row]
        
        if message.messageType == LGMessageType.Voice {
            let message = message as! voiceMessage
            let cell = pressCell as! LGChatVoiceCell
            let play = LGAudioPlayer()
            player = play
            player.startPlaying(message)
            cell.beginAnimation()

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(message.voiceTime.intValue) * 1000 * 1000 * 1000), dispatch_get_main_queue(), { () -> Void in
                cell.stopAnimation()
            })
        }
    }
    
    
}

// MARK: extension for toobar action

extension LGConversationViewController {

    func voiceClick(button: UIButton) {
        if toolBarView.recordButton.hidden == false {
            toolBarView.showRecord(false)
        } else {
            toolBarView.showRecord(true)
            self.view.endEditing(true)
        }
    }
    
    func recordClick(button: UIButton) {
        button.setTitle("松开     结束", forState: .Normal)
        button.addTarget(self, action: "recordComplection:", forControlEvents: .TouchUpInside)
        button.addTarget(self, action: "recordDragOut:", forControlEvents: .TouchDragOutside)
        button.addTarget(self, action: "recordCancel:", forControlEvents: .TouchUpOutside)
        
        let currentTime = NSDate().timeIntervalSinceReferenceDate
        let record = LGAudioRecorder(fileName: "\(currentTime).wav")
        record.delegate = self
        recorder = record
        recorder.startRecord()
        
        recordIndicatorView = LGRecordIndicatorView(frame: CGRectMake(self.view.center.x - indicatorViewH / 2, self.view.center.y - indicatorViewH / 3, indicatorViewH, indicatorViewH))
        view.addSubview(recordIndicatorView)
    }
    
    func recordComplection(button: UIButton) {
        button.setTitle("按住     说话", forState: .Normal)
        recorder.stopRecord()
        recorder.delegate = nil
        recordIndicatorView.removeFromSuperview()
        recordIndicatorView = nil
        
        if recorder.timeInterval != nil {
            let message = voiceMessage(incoming: false, sentDate: NSDate(), iconName: "", voicePath: recorder.recorder.url, voiceTime: recorder.timeInterval)
            let receiveMessage = voiceMessage(incoming: true, sentDate: NSDate(), iconName: "", voicePath: recorder.recorder.url, voiceTime: recorder.timeInterval)
            
            messageList.append(message)
            messageList.append(receiveMessage)
            reloadTableView()
        }
    }
    
    func recordDragOut(button: UIButton) {
        button.setTitle("按住     说话", forState: .Normal)
        recordIndicatorView.showText("松开手指,取消发送", textColor: UIColor.redColor())
    }
    
    
    func recordCancel(button: UIButton) {
        button.setTitle("按住     说话", forState: .Normal)
        recorder.stopRecord()
        recorder.delegate = nil
        recordIndicatorView.removeFromSuperview()
        recordIndicatorView = nil
    }
    
    func emotionClick(button: UIButton) {
        if toolBarView.emotionButton.tag == 1 {
            toolBarView.showEmotion(true)
            toolBarView.textView.inputView = emojiView
        } else {
            toolBarView.showEmotion(false)
            toolBarView.textView.inputView = nil
        }
        toolBarView.textView.becomeFirstResponder()
        toolBarView.textView.reloadInputViews()
    }
    
    func moreClick(button: UIButton) {
        if toolBarView.moreButton.tag == 2 {
            toolBarView.showMore(true)
            toolBarView.textView.inputView = shareView
        } else {
            toolBarView.showMore(false)
            toolBarView.textView.inputView = nil
        }
        
        toolBarView.textView.becomeFirstResponder()
        toolBarView.textView.reloadInputViews()
    }
    
    // shareMore click
    
    func shareMoreClick(button: UIButton) {
        let shareType = shareMoreType(rawValue: button.tag)!
        
        switch shareType {
        case .picture:
            let imagePick = LGImagePickController()
            imagePick.delegate = self
            let nav = UINavigationController(rootViewController: imagePick)
            self.presentViewController(nav, animated: true, completion: nil)
        case .video:
            NSLog("video")
        case .location:
            let mapCtrl = LGMapViewController()
            mapCtrl.delegate = self
            let nav = UINavigationController(rootViewController: mapCtrl)
            self.presentViewController(nav, animated: true, completion: nil)
        default:
            break
        }
    }
    
    func sendImage(image: UIImage) {
        let message = imageMessage(incoming: false, sentDate: NSDate(), iconName: "", image: image)
        messageList.append(message)
        reloadTableView()
    }
    
    // MARK: - mapview delegate
    
    func mapViewController(controller: LGMapViewController, didSelectLocationSnapeShort image: UIImage) {
        toolBarView.showMore(false)
        sendImage(image)
    }
    
    // MARK: - imagePick delegate
    func imagePickerController(picker: LGImagePickController, didFinishPickingImages images: [UIImage]) {
        toolBarView.showMore(false)
        for image in images {
            sendImage(image)
        }
    }
    
    func imagePickerControllerDidCancel(picker: LGImagePickController) {
        toolBarView.showMore(false)
    }
    
    // MARK: - emojiDelegate
    func selectEmoji(code: String, description: String, delete: Bool) {
        NSLog("%@--%@", code, description)
    }
    
    // MARK: - textViewDelegate
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            let messageStr = textView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            let message = textMessage(incoming: false, sentDate: NSDate(), iconName: "", text: messageStr)
            let receiveMessage = textMessage(incoming: true, sentDate: NSDate(), iconName: "", text: messageStr)
            
            messageList.append(message)
            messageList.append(receiveMessage)
            
            reloadTableView()
            textView.text = ""
            return false
        }
        return true
    }
    
    // MARK: -LGrecordDelegate
    func audioRecorderUpdateMetra(metra: Float) {
        if recordIndicatorView != nil {
         recordIndicatorView.updateLevelMetra(metra)
        }
    }
}


