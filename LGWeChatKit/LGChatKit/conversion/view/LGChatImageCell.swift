//
//  LGChatImageCell.swift
//  LGChatViewController
//
//  Created by jamy on 10/12/15.
//  Copyright © 2015 jamy. All rights reserved.
//

import UIKit

class LGChatImageCell: LGChatBaseCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundImageView.addConstraint(NSLayoutConstraint(item: backgroundImageView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 120))
        backgroundImageView.addConstraint(NSLayoutConstraint(item: backgroundImageView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 140))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setMessage(message: Message) {
        super.setMessage(message)
       let message = message as! imageMessage
        backgroundImageView.image = message.image
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        
    }
}
