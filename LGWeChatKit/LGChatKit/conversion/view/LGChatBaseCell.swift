//
//  LGChatBaseCell.swift
//  LGChatViewController
//
//  Created by jamy on 10/12/15.
//  Copyright © 2015 jamy. All rights reserved.
//

import UIKit

let receiveTag = 0, sendTag = 1
let iconImageTag = 10010, backgroundImageTag = 10020, indicatorTag = 10030

let timeFont = UIFont.systemFontOfSize(12.0)
let messageFont = UIFont.systemFontOfSize(14.0)
let indicatorFont = UIFont.systemFontOfSize(10.0)

class LGChatBaseCell: UITableViewCell {
    
    let iconImageView: UIImageView          // show user icon
    let backgroundImageView: UIImageView    // the cell background view
    let timeLabel: UILabel                  // show timer
    let indicatorView: UIButton             // indicator the message status
    
    var iconContraintNotime: NSLayoutConstraint!
    var iconContraintWithTime: NSLayoutConstraint!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        iconImageView = UIImageView(image: UIImage(named: "DefaultHead"))
        iconImageView.layer.cornerRadius = 8.0
        iconImageView.layer.masksToBounds = true
        iconImageView.tag = iconImageTag
        
        backgroundImageView = UIImageView(image: backgroundImage.incoming, highlightedImage: backgroundImage.incomingHighlighed)
        backgroundImageView.userInteractionEnabled = true
        backgroundImageView.layer.cornerRadius = 5.0
        backgroundImageView.layer.masksToBounds = true
        backgroundImageView.tag = backgroundImageTag
        
        timeLabel = UILabel(frame: CGRectZero)
        timeLabel.textAlignment = .Center
        timeLabel.font = timeFont
        
        indicatorView = UIButton(type: .Custom)
        indicatorView.tag = indicatorTag
        indicatorView.setBackgroundImage(UIImage(named: "share_auth_fail"), forState: .Normal)
        indicatorView.hidden = true
        
        indicatorView.setTitleColor(UIColor.blackColor(), forState: .Normal)
        indicatorView.titleLabel?.font = indicatorFont
        
        super.init(style: .Default, reuseIdentifier: reuseIdentifier)
        selectionStyle = .None
        backgroundColor = UIColor.clearColor()
        
        contentView.addSubview(timeLabel)
        contentView.addSubview(iconImageView)
        contentView.addSubview(backgroundImageView)
        contentView.addSubview(indicatorView)
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.translatesAutoresizingMaskIntoConstraints = false

        // add timerLabel constaint, only need add x,y
        contentView.addConstraint(NSLayoutConstraint(item: timeLabel, attribute: .Left, relatedBy: .Equal, toItem: contentView, attribute: .Left, multiplier: 1, constant: 10))
        contentView.addConstraint(NSLayoutConstraint(item: timeLabel, attribute: .Right, relatedBy: .Equal, toItem: contentView, attribute: .Right, multiplier: 1, constant: -10))
        contentView.addConstraint(NSLayoutConstraint(item: timeLabel, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1, constant: 5))
        
        // iconView constraint
        contentView.addConstraint(NSLayoutConstraint(item: iconImageView, attribute: .Left, relatedBy: .Equal, toItem: contentView, attribute: .Left, multiplier: 1, constant: 10))
        
        iconImageView.addConstraint(NSLayoutConstraint(item: iconImageView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 45))
        iconImageView.addConstraint(NSLayoutConstraint(item: iconImageView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 45))
        
        // background constraint
        contentView.addConstraint(NSLayoutConstraint(item: backgroundImageView, attribute: .Left, relatedBy: .Equal, toItem: iconImageView, attribute: .Right, multiplier: 1, constant: 10))
        contentView.addConstraint(NSLayoutConstraint(item: backgroundImageView, attribute: .Top, relatedBy: .Equal, toItem: iconImageView, attribute: .Top, multiplier: 1, constant: 0))
       
        // indicator constraint
        indicatorView.addConstraint(NSLayoutConstraint(item: indicatorView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 17))
        indicatorView.addConstraint(NSLayoutConstraint(item: indicatorView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 17))
        contentView.addConstraint(NSLayoutConstraint(item: indicatorView, attribute: .CenterY, relatedBy: .Equal, toItem: backgroundImageView, attribute: .CenterY, multiplier: 1, constant: -5))
        contentView.addConstraint(NSLayoutConstraint(item: indicatorView, attribute: .Left, relatedBy: .Equal, toItem: backgroundImageView, attribute: .Right, multiplier: 1, constant: 0))
        
        iconContraintNotime = NSLayoutConstraint(item: iconImageView, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1, constant: 10)
        iconContraintWithTime = NSLayoutConstraint(item: iconImageView, attribute: .Top, relatedBy: .Equal, toItem: timeLabel, attribute: .Bottom, multiplier: 1, constant: 5)
    
        contentView.addConstraint(iconContraintWithTime)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        timeLabel.hidden = false
        contentView.addConstraint(iconContraintWithTime)
    }
    
    func setMessage(message: Message) {
        
        if !timeLabel.hidden {
            contentView.removeConstraint(iconContraintNotime)
            timeLabel.text = message.dataString
        } else {
            contentView.removeConstraint(iconContraintWithTime)
            contentView.addConstraint(iconContraintNotime)
        }
        
        if message.iconName.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
            if let image = UIImage(named: message.iconName) {
                iconImageView.image = image
            }
        }
        
        if message.incoming != (tag == receiveTag) {
            var layoutAttribute: NSLayoutAttribute
            var layoutConstraint: CGFloat
            var backlayoutAttribute: NSLayoutAttribute
            
            if message.incoming {
                tag = receiveTag
                backgroundImageView.image = backgroundImage.incoming
                backgroundImageView.highlightedImage = backgroundImage.incomingHighlighed
                layoutAttribute = .Left
                backlayoutAttribute = .Right
                layoutConstraint = 10
            } else {
                tag = sendTag
                backgroundImageView.image = backgroundImage.outgoing
                backgroundImageView.highlightedImage = backgroundImage.outgoingHighlighed
                layoutAttribute = .Right
                backlayoutAttribute = .Left
                layoutConstraint = -10
            }
            
            let constraints: NSArray = contentView.constraints
            
            // reAdd iconImageView left/right constraint
            let indexOfConstraint = constraints.indexOfObjectPassingTest { (constraint, idx, stop) in
                return (constraint.firstItem as! UIView).tag == iconImageTag && (constraint.firstAttribute == NSLayoutAttribute.Left || constraint.firstAttribute == NSLayoutAttribute.Right)
            }
            contentView.removeConstraint(constraints[indexOfConstraint] as! NSLayoutConstraint)
            contentView.addConstraint(NSLayoutConstraint(item: iconImageView, attribute: layoutAttribute, relatedBy: .Equal, toItem: contentView, attribute: layoutAttribute, multiplier: 1, constant: layoutConstraint))
            
            // reAdd backgroundImageView left/right constraint
            let indexOfBackConstraint = constraints.indexOfObjectPassingTest { (constraint, idx, stop) in
                return (constraint.firstItem as! UIView).tag == backgroundImageTag && (constraint.firstAttribute == NSLayoutAttribute.Left || constraint.firstAttribute == NSLayoutAttribute.Right)
            }
            contentView.removeConstraint(constraints[indexOfBackConstraint] as! NSLayoutConstraint)
            contentView.addConstraint(NSLayoutConstraint(item: backgroundImageView, attribute: layoutAttribute, relatedBy: .Equal, toItem: iconImageView, attribute: backlayoutAttribute, multiplier: 1, constant: layoutConstraint))
            
            // reAdd indicator left/right constraint
            let indexOfIndicatorConstraint = constraints.indexOfObjectPassingTest { (constraint, idx, stop) in
                return (constraint.firstItem as! UIView).tag == indicatorTag && (constraint.firstAttribute == NSLayoutAttribute.Left || constraint.firstAttribute == NSLayoutAttribute.Right)
            }
            contentView.removeConstraint(constraints[indexOfIndicatorConstraint] as! NSLayoutConstraint)
            contentView.addConstraint(NSLayoutConstraint(item: indicatorView, attribute: layoutAttribute, relatedBy: .Equal, toItem: backgroundImageView, attribute: backlayoutAttribute, multiplier: 1, constant: 0))
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        backgroundImageView.highlighted = selected
    }
}

let backgroundImage = backgroundImageMake()

func backgroundImageMake() -> (incoming: UIImage, incomingHighlighed: UIImage, outgoing: UIImage, outgoingHighlighed: UIImage) {
    let maskOutgoing = UIImage(named: "SenderTextNodeBkg")!
    let maskOutHightedgoing = UIImage(named: "SenderTextNodeBkgHL")!
    let maskIncoming = UIImage(named: "ReceiverTextNodeBkg")!
    let maskInHightedcoming = UIImage(named: "ReceiverTextNodeBkgHL")!
    
    let incoming = maskIncoming.resizeImage()
    let incomingHighlighted = maskInHightedcoming.resizeImage()
    let outgoing = maskOutgoing.resizeImage()
    let outgoingHighlighted = maskOutHightedgoing.resizeImage()
    
    return (incoming, incomingHighlighted, outgoing, outgoingHighlighted)
}


func imageWithColor(image: UIImage, red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIImage! {
    let rect = CGRect(origin: CGPointZero, size: image.size)
    UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
    let context = UIGraphicsGetCurrentContext()
    image.drawInRect(rect)
    CGContextSetRGBFillColor(context, red, green, blue, alpha)
    CGContextSetBlendMode(context, CGBlendMode.SourceAtop)
    CGContextFillRect(context, rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage
}

