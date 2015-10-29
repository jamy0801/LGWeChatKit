//
//  LGAssetViewModel.swift
//  LGWeChatKit
//
//  Created by jamy on 10/28/15.
//  Copyright © 2015 jamy. All rights reserved.
//

import Foundation
import Photos

class LGAssetViewModel {
    let asset: Observable<PHAsset>
    let image: Observable<UIImage>
    
    init(assetMode: LGAssetModel) {
        asset = Observable(assetMode.asset)
        image = Observable(UIImage())
    }
    
    func getTargetSize(size: CGSize) -> CGSize {
        let scale = UIScreen.mainScreen().scale
        let targetSize = CGSizeMake(size.width * scale, size.height * scale)
        
        return targetSize
    }
    
    
    func updateStaticImage(size: CGSize) {
        let option = PHImageRequestOptions()
        option.deliveryMode = .HighQualityFormat
        option.networkAccessAllowed = true
        
        PHImageManager.defaultManager().requestImageForAsset(asset.value, targetSize: getTargetSize(size), contentMode: .AspectFit, options: option) { (image, _: [NSObject : AnyObject]?) -> Void in
            if (image == nil) {
                return
            }
            
            self.image.value = image!
        }
    }
}