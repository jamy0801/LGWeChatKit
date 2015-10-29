//
//  LGChatMessageCell.swift
//  LGChatViewController
//
//  Created by jamy on 10/11/15.
//  Copyright © 2015 jamy. All rights reserved.
//

import UIKit

class LGChatTextCell: LGChatBaseCell {

    let messageLabel: UILabel
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    
        messageLabel = UILabel(frame: CGRectZero)
        messageLabel.userInteractionEnabled = false
        messageLabel.numberOfLines = 0
        messageLabel.font = messageFont
        
        super.init(style: .Default, reuseIdentifier: reuseIdentifier)
        selectionStyle = .None

        backgroundImageView.addSubview(messageLabel)
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        backgroundImageView.addConstraint(NSLayoutConstraint(item: backgroundImageView, attribute: .Width, relatedBy: .Equal, toItem: messageLabel, attribute: .Width, multiplier: 1, constant: 30))
        backgroundImageView.addConstraint(NSLayoutConstraint(item: messageLabel, attribute: .CenterX, relatedBy: .Equal, toItem: backgroundImageView, attribute: .CenterX, multiplier: 1, constant: 0))
        backgroundImageView.addConstraint(NSLayoutConstraint(item: messageLabel, attribute: .CenterY, relatedBy: .Equal, toItem: backgroundImageView, attribute: .CenterY, multiplier: 1, constant: -5))
        messageLabel.preferredMaxLayoutWidth = 210
        backgroundImageView.addConstraint(NSLayoutConstraint(item: messageLabel, attribute: .Height, relatedBy: .Equal, toItem: backgroundImageView, attribute: .Height, multiplier: 1, constant: -30))
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func setMessage(message: Message) {
        super.setMessage(message)
        let message = message as! textMessage
        messageLabel.text = message.text

        //indicatorView.hidden = false
        if message.incoming != (tag == receiveTag) {
            
            if message.incoming {
                tag = receiveTag
                backgroundImageView.image = backgroundImage.incoming
                backgroundImageView.highlightedImage = backgroundImage.incomingHighlighed
                messageLabel.textColor = UIColor.blackColor()
            } else {
                tag = sendTag
                backgroundImageView.image = backgroundImage.outgoing
                backgroundImageView.highlightedImage = backgroundImage.outgoingHighlighed
                messageLabel.textColor = UIColor.whiteColor()
            }
            
            let messageConstraint : NSLayoutConstraint = backgroundImageView.constraints[1]
            messageConstraint.constant = -messageConstraint.constant
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        backgroundImageView.highlighted = selected
    }
}

