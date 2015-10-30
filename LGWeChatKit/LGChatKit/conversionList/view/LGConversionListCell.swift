//
//  LGConversionListCell.swift
//  LGChatViewController
//
//  Created by jamy on 10/19/15.
//  Copyright © 2015 jamy. All rights reserved.
//

import UIKit

class LGConversionListCell: LGConversionListBaseCell {

    let iconView: UIImageView!
    let userNameLabel: UILabel!
    let messageLabel: UILabel!
    let timerLabel: UILabel!
    
    let messageListCellHeight = 64
    
    
    var viewModel: LGConversionListCellModel? {
        didSet {
            viewModel?.iconName.observe {
                [unowned self] in
                self.iconView.image = UIImage(named: $0)
            }
            
            viewModel?.lastMessage.observe {
                [unowned self] in
                self.messageLabel.text = $0
            }
            
            viewModel?.userName.observe {
                [unowned self] in
                self.userNameLabel.text = $0
            }
            
            viewModel?.timer.observe {
                [unowned self] in
                self.timerLabel.text = $0
            }
        }
    }
    

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        iconView = UIImageView(frame: CGRectMake(5, CGFloat(messageListCellHeight - 50) / 2, 50, 50))
        iconView.layer.cornerRadius = 5.0
        iconView.layer.masksToBounds = true
        
        userNameLabel = UILabel()
        userNameLabel.textAlignment = .Left
        userNameLabel.font = UIFont.systemFontOfSize(14.0)
        
        messageLabel = UILabel()
        messageLabel.textAlignment = .Left
        messageLabel.font = UIFont.systemFontOfSize(13.0)
        messageLabel.textColor = UIColor.lightGrayColor()
        
        timerLabel = UILabel()
        timerLabel.textAlignment = .Right
        timerLabel.font = UIFont.systemFontOfSize(14.0)
        timerLabel.textColor = UIColor.lightGrayColor()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(iconView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(messageLabel)
        contentView.addSubview(timerLabel)
        
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addConstraint(NSLayoutConstraint(item: userNameLabel, attribute: .Left, relatedBy: .Equal, toItem: contentView, attribute: .Left, multiplier: 1, constant: CGFloat(messageListCellHeight + 8)))
        contentView.addConstraint(NSLayoutConstraint(item: userNameLabel, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1, constant: 5))
        
        contentView.addConstraint(NSLayoutConstraint(item: messageLabel, attribute: .Left, relatedBy: .Equal, toItem: userNameLabel, attribute: .Left, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: messageLabel, attribute: .Top, relatedBy: .Equal, toItem: userNameLabel, attribute: .Bottom, multiplier: 1, constant: 10))
        contentView.addConstraint(NSLayoutConstraint(item: messageLabel, attribute: .Right, relatedBy: .Equal, toItem: contentView, attribute: .Right, multiplier: 1, constant: -70))
        
        contentView.addConstraint(NSLayoutConstraint(item: timerLabel, attribute: .Left, relatedBy: .Equal, toItem: contentView, attribute: .Right, multiplier: 1, constant: -65))
        contentView.addConstraint(NSLayoutConstraint(item: timerLabel, attribute: .Top, relatedBy: .Equal, toItem: userNameLabel, attribute: .Top, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: timerLabel, attribute: .Right, relatedBy: .Equal, toItem: contentView, attribute: .Right, multiplier: 1, constant: -5))
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
