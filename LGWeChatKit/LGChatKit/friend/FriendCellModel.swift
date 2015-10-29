//
//  FriendCellModel.swift
//  LGChatViewController
//
//  Created by jamy on 10/21/15.
//  Copyright © 2015 jamy. All rights reserved.
//

import Foundation


class contactCellModel {
    let name: Observable<String>
    let phone: Observable<String>
    let iconName: Observable<String>
    
    init(_ friend: Friend) {
        name = Observable(friend.name)
        phone = Observable(friend.phone)
        iconName = Observable(friend.iconName)
    }
}

class contactSessionModel {
    let key: Observable<String>
    let friends: Observable<[contactCellModel]>
    
    init() {
        key = Observable("")
        friends = Observable([])
    }
}