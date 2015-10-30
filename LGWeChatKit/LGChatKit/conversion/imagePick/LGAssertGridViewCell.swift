//
//  LGAssertGridViewCell.swift
//  LGChatViewController
//
//  Created by jamy on 10/22/15.
//  Copyright © 2015 jamy. All rights reserved.
//

import UIKit

class LGAssertGridViewCell: UICollectionViewCell {
    
    let buttonWidth: CGFloat = 30
    var assetIdentifier: String!
    var imageView:UIImageView!
    var selectIndicator: UIButton
    var assetModel: LGAssetModel!
    var buttonSelect: Bool {
        willSet {
            if newValue {
                selectIndicator.selected = true
                selectIndicator.setImage(UIImage(named: "CellBlueSelected"), forState: .Normal)
            } else {
                selectIndicator.selected = false
                selectIndicator.setImage(UIImage(named: "CellGreySelected"), forState: .Normal)
            }
        }
    }
    
    override init(frame: CGRect) {
        selectIndicator = UIButton(type: .Custom)
        selectIndicator.tag = 1

        buttonSelect = false
        super.init(frame: frame)
        imageView = UIImageView(frame: bounds)
        imageView.contentMode = .ScaleToFill
        contentView.addSubview(imageView)
        
        selectIndicator.frame = CGRectMake(bounds.width - buttonWidth , 0, buttonWidth, buttonWidth)
        contentView.addSubview(selectIndicator)
        selectIndicator.setImage(UIImage(named: "CellGreySelected"), forState: .Normal)
        
        backgroundColor = UIColor.whiteColor()
        imageView.image = UIImage(named: "bike_traveler")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    let durationTime = 0.3
    
    func selectButton(button: UIButton) {
        if button.tag == 1 {
            button.tag = 0
            let groupAnimation = CAAnimationGroup()
    
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
            buttonSelect = true
            assetModel.select = true
            selectIndicator.layer.addAnimation(groupAnimation, forKey: "selectZoom")
        } else {
            button.tag = 1
            buttonSelect = false
            assetModel.select = false
        }
    }
}
