//
//  LGConversionListCellModel.swift
//  LGChatViewController
//
//  Created by jamy on 10/20/15.
//  Copyright © 2015 jamy. All rights reserved.
//

import Foundation


class LGConversionListCellModel {
    let iconName: Observable<String>
    let userName: Observable<String>
    let lastMessage: Observable<String>
    let timer: Observable<String>
    
    private let emptyString = ""
    
    init() {
        iconName = Observable(emptyString)
        userName = Observable(emptyString)
        lastMessage = Observable(emptyString)
        timer = Observable(emptyString)
    }
}