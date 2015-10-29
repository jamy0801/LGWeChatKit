//
//  LGFriendListCecll.swift
//  LGChatViewController
//
//  Created by jamy on 10/20/15.
//  Copyright © 2015 jamy. All rights reserved.
//

import UIKit

class LGFriendListCell: LGConversionListBaseCell {

    let iconView: UIImageView!
    let userNameLabel: UILabel!
    let phoneLabel: UILabel!

    let messageListCellHeight = 44
    let imageHeight = 40
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        iconView = UIImageView(frame: CGRectMake(5, CGFloat(messageListCellHeight - imageHeight) / 2, CGFloat(imageHeight), CGFloat(imageHeight)))
        iconView.layer.cornerRadius = 5.0
        iconView.layer.masksToBounds = true
        
        userNameLabel = UILabel()
        userNameLabel.textAlignment = .Left
        userNameLabel.font = UIFont.systemFontOfSize(14.0)
        
        phoneLabel = UILabel()
        phoneLabel.textAlignment = .Left
        phoneLabel.font = UIFont.systemFontOfSize(13.0)
        phoneLabel.textColor = UIColor.lightGrayColor()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(iconView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(phoneLabel)
        
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        phoneLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addConstraint(NSLayoutConstraint(item: userNameLabel, attribute: .Left, relatedBy: .Equal, toItem: contentView, attribute: .Left, multiplier: 1, constant: CGFloat(messageListCellHeight + 8)))
        contentView.addConstraint(NSLayoutConstraint(item: userNameLabel, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1, constant: 5))
        
        contentView.addConstraint(NSLayoutConstraint(item: phoneLabel, attribute: .Left, relatedBy: .Equal, toItem: userNameLabel, attribute: .Left, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: phoneLabel, attribute: .Top, relatedBy: .Equal, toItem: userNameLabel, attribute: .Bottom, multiplier: 1, constant: 5))
        contentView.addConstraint(NSLayoutConstraint(item: phoneLabel, attribute: .Right, relatedBy: .Equal, toItem: contentView, attribute: .Right, multiplier: 1, constant: -70))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    var viewModel: contactCellModel? {
        didSet {
            viewModel?.iconName.observe {
                [unowned self] in
                self.iconView.image = UIImage(named: $0)
            }
            
            viewModel?.name.observe {
                [unowned self] in
                self.userNameLabel.text = $0
            }
            
            viewModel?.phone.observe {
                [unowned self] in
                self.phoneLabel.text = $0
            }
        }
    }
    
}
