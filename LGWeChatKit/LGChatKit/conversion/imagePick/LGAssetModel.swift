//
//  LGAssetModel.swift
//  LGChatViewController
//
//  Created by jamy on 10/23/15.
//  Copyright © 2015 jamy. All rights reserved.
//

import Foundation
import Photos

class LGAssetModel {
    var select: Bool
    var asset: PHAsset
    
    init(asset: PHAsset, select: Bool) {
        self.asset = asset
        self.select = select
    }
    
    func setSelect(isSelect: Bool) {
        self.select = isSelect
    }
}