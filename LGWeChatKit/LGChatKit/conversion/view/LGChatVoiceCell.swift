//
//  LGChatVoiceCell.swift
//  LGChatViewController
//
//  Created by jamy on 10/12/15.
//  Copyright © 2015 jamy. All rights reserved.
//

import UIKit

let voiceIndicatorImageTag = 10040

class LGChatVoiceCell: LGChatBaseCell {

    let voicePlayIndicatorImageView: UIImageView
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        voicePlayIndicatorImageView = UIImageView(frame: CGRectZero)
        voicePlayIndicatorImageView.tag = voiceIndicatorImageTag
        voicePlayIndicatorImageView.animationDuration = 1.0
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundImageView.addSubview(voicePlayIndicatorImageView)
        
        voicePlayIndicatorImageView.translatesAutoresizingMaskIntoConstraints = false
        
        voicePlayIndicatorImageView.addConstraint(NSLayoutConstraint(item: voicePlayIndicatorImageView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 12.5))
        voicePlayIndicatorImageView.addConstraint(NSLayoutConstraint(item: voicePlayIndicatorImageView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 17))
        backgroundImageView.addConstraint(NSLayoutConstraint(item: voicePlayIndicatorImageView, attribute: .Left, relatedBy: .Equal, toItem: backgroundImageView, attribute: .Left, multiplier: 1, constant: 15))
        backgroundImageView.addConstraint(NSLayoutConstraint(item: voicePlayIndicatorImageView, attribute: .CenterY, relatedBy: .Equal, toItem: backgroundImageView, attribute: .CenterY, multiplier: 1, constant: -5))
        contentView.addConstraint(NSLayoutConstraint(item: backgroundImageView, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .Bottom, multiplier: 1, constant: -5))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            voicePlayIndicatorImageView.startAnimating()
        } else {
            voicePlayIndicatorImageView.stopAnimating()
        }
    }
    
    override func setMessage(message: Message) {
        super.setMessage(message)
        
        let message = message as! voiceMessage
        setUpVoicePlayIndicatorImageView(!message.incoming)
        
        // hear we can set backgroudImageView's length dure to the voice timer
        let margin = CGFloat(2) * CGFloat(message.voiceTime.intValue)
        backgroundImageView.addConstraint(NSLayoutConstraint(item: backgroundImageView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 60 + margin))
        
        indicatorView.hidden = false
        indicatorView.setBackgroundImage(UIImage.imageWithColor(UIColor.clearColor()), forState: .Normal)

        indicatorView.setTitle("\(message.voiceTime.integerValue)\"", forState: .Normal)
        
        var layoutAttribute: NSLayoutAttribute
        var layoutConstant: CGFloat
        if message.incoming {
            layoutAttribute = .Left
            layoutConstant = 15
        } else {
            layoutAttribute = .Right
            layoutConstant = -15
        }
        
        let constraints: NSArray = backgroundImageView.constraints
        
        let indexOfBackConstraint = constraints.indexOfObjectPassingTest { (constraint, idx, stop) in
            return (constraint.firstItem as! UIView).tag == voiceIndicatorImageTag && (constraint.firstAttribute == NSLayoutAttribute.Left || constraint.firstAttribute == NSLayoutAttribute.Right)
        }
        
        backgroundImageView.removeConstraint(constraints[indexOfBackConstraint] as! NSLayoutConstraint)
        backgroundImageView.addConstraint(NSLayoutConstraint(item: voicePlayIndicatorImageView, attribute: layoutAttribute, relatedBy: .Equal, toItem: backgroundImageView, attribute: layoutAttribute, multiplier: 1, constant: layoutConstant))
    }
    
    func stopAnimation() {
        if voicePlayIndicatorImageView.isAnimating() {
            voicePlayIndicatorImageView.stopAnimating()
        }
    }
    
    
    func beginAnimation() {
        voicePlayIndicatorImageView.startAnimating()
    }
    
    func setUpVoicePlayIndicatorImageView(send: Bool) {
        var images = NSArray()
        if send {
            images = NSArray(objects: UIImage(named: "SenderVoiceNodePlaying001")!, UIImage(named: "SenderVoiceNodePlaying002")!, UIImage(named: "SenderVoiceNodePlaying003")!)
            voicePlayIndicatorImageView.image = UIImage(named: "SenderVoiceNodePlaying")
        } else {
            images = NSArray(objects: UIImage(named: "ReceiverVoiceNodePlaying001")!, UIImage(named: "ReceiverVoiceNodePlaying002")!, UIImage(named: "ReceiverVoiceNodePlaying003")!)
            voicePlayIndicatorImageView.image = UIImage(named: "ReceiverVoiceNodePlaying")
        }
        
        voicePlayIndicatorImageView.animationImages = (images as! [UIImage])
    }
    
}
