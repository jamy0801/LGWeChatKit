//
//  LGAssetToolView.swift
//  LGChatViewController
//
//  Created by jamy on 10/23/15.
//  Copyright © 2015 jamy. All rights reserved.
//

import UIKit

private let buttonWidth = 20
private let durationTime = 0.3

class LGAssetToolView: UIView {
    var preViewButton: UIButton!
    var totalButton: UIButton!
    var sendButton: UIButton!
    weak var parent: UIViewController!
    
    var selectCount = Int() {
        willSet {
            if newValue > 0 {
                totalButton.addAnimation(durationTime)
                totalButton.hidden = false
                totalButton.setTitle("\(newValue)", forState: .Normal)
            } else {
                totalButton.hidden = true
            }
        }
    }
    
    var addSelectCount: Int? {
        willSet {
            selectCount += newValue!
        }
    }
    
    convenience init(leftTitle:String, leftSelector: Selector, rightSelector: Selector, parent: UIViewController) {
        self.init()
        self.parent = parent
        
        preViewButton = UIButton(type: .Custom)
        preViewButton.titleLabel?.font = UIFont.systemFontOfSize(14.0)
        preViewButton.setTitle(leftTitle, forState: .Normal)
        preViewButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        preViewButton.addTarget(parent, action: leftSelector, forControlEvents: .TouchUpInside)
        
        totalButton = UIButton(type: .Custom)
        totalButton.titleLabel?.font = UIFont.systemFontOfSize(14.0)
        totalButton.setBackgroundImage(UIImage.imageWithColor(UIColor.greenColor()), forState: .Normal)
        totalButton.layer.cornerRadius = CGFloat(buttonWidth / 2)
        totalButton.layer.masksToBounds = true
        totalButton.hidden = true
        
        sendButton = UIButton(type: .Custom)
        sendButton.titleLabel?.font = UIFont.systemFontOfSize(14.0)
        sendButton.setTitle("发送", forState: .Normal)
        sendButton.setTitleColor(UIColor.grayColor(), forState: .Normal)
        sendButton.addTarget(parent, action: rightSelector, forControlEvents: .TouchUpInside)
        
        backgroundColor = UIColor.groupTableViewBackgroundColor()
        
        addSubview(preViewButton)
        addSubview(totalButton)
        addSubview(sendButton)
        
        preViewButton.translatesAutoresizingMaskIntoConstraints = false
        totalButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: preViewButton, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 5))
        addConstraint(NSLayoutConstraint(item: preViewButton, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: sendButton, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: -5))
        addConstraint(NSLayoutConstraint(item: sendButton, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: totalButton, attribute: .Right, relatedBy: .Equal, toItem: sendButton, attribute: .Left, multiplier: 1, constant: -5))
        addConstraint(NSLayoutConstraint(item: totalButton, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))
        totalButton.addConstraint(NSLayoutConstraint(item: totalButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant: CGFloat(buttonWidth)))
        totalButton.addConstraint(NSLayoutConstraint(item: totalButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: CGFloat(buttonWidth)))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
