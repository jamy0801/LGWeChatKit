//
//  LGChatVideoCell.swift
//  LGWeChatKit
//
//  Created by jamy on 11/4/15.
//  Copyright © 2015 jamy. All rights reserved.
//

import UIKit
import AVFoundation

class LGChatVideoCell: LGChatBaseCell {

    let videoIndicator: UIImageView
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        videoIndicator = UIImageView()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundImageView.addSubview(videoIndicator)
        
        videoIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        backgroundImageView.addConstraint(NSLayoutConstraint(item: backgroundImageView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 160))
        backgroundImageView.addConstraint(NSLayoutConstraint(item: backgroundImageView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 120))
        
        contentView.addConstraint(NSLayoutConstraint(item: videoIndicator, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 40))
        contentView.addConstraint(NSLayoutConstraint(item: videoIndicator, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 40))
        contentView.addConstraint(NSLayoutConstraint(item: videoIndicator, attribute: .CenterY, relatedBy: .Equal, toItem: backgroundImageView, attribute: .CenterY, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: videoIndicator, attribute: .CenterX, relatedBy: .Equal, toItem: backgroundImageView, attribute: .CenterX, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: backgroundImageView, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .Bottom, multiplier: 1, constant: -5))
        
        videoIndicator.image = UIImage(named: "MessageVideoPlay")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setMessage(message: Message) {
        super.setMessage(message)
        let message = message as! videoMessage
        let asset = AVAsset(URL: message.url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        do {
            let cgImage = try imageGenerator.copyCGImageAtTime(CMTimeMake(0, 1), actualTime: nil)
            backgroundImageView.image = UIImage(CGImage: cgImage)
        } catch let error as NSError {
            NSLog("%@", error)
        }
    }
}
