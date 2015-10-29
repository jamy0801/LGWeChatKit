//
//  LGCommonEx.swift
//  LGChatViewController
//
//  Created by jamy on 10/8/15.
//  Copyright © 2015 jamy. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    class func imageWithColor(color: UIColor) -> UIImage {
        
        let rect = CGRectMake(0, 0, 1.0, 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    
    func resizeImage() -> UIImage {
       return self.stretchableImageWithLeftCapWidth(Int(self.size.width / CGFloat(2)), topCapHeight: Int(self.size.height / CGFloat(2)))
    }
}

extension UIButton {
    func addAnimation(durationTime: Double) {
        let groupAnimation = CAAnimationGroup()
        groupAnimation.removedOnCompletion = true
        
        let animationZoomOut = CABasicAnimation(keyPath: "transform.scale")
        animationZoomOut.fromValue = 0
        animationZoomOut.toValue = 1.2
        animationZoomOut.duration = 3/4 * durationTime
        
        let animationZoomIn = CABasicAnimation(keyPath: "transform.scale")
        animationZoomIn.fromValue = 1.2
        animationZoomIn.toValue = 1.0
        animationZoomIn.beginTime = 3/4 * durationTime
        animationZoomIn.duration = 1/4 * durationTime
        
        groupAnimation.animations = [animationZoomOut, animationZoomIn]
        self.layer.addAnimation(groupAnimation, forKey: "addAnimation")
    }
}


extension NSString {
    func stringWidthFont(font: UIFont) -> CGFloat {
        if self.length < 1 {
            return 0.0
        }
        
        let size = self.boundingRectWithSize(CGSizeMake(200, 1000), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return size.width ?? 0.0
    }
}


extension UIButton {
    class func createButton(title: String, backGroundColor: UIColor) -> UIButton {
        let button = UIButton(type: UIButtonType.Custom)
        button.setTitle(title, forState: .Normal)
        button.backgroundColor = backGroundColor
        button.setBackgroundImage(UIImage.imageWithColor(backGroundColor), forState: .Normal)
        return button
    }
}




