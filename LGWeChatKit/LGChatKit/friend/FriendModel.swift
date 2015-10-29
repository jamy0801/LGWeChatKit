//
//  FriendModel.swift
//  LGChatViewController
//
//  Created by jamy on 10/20/15.
//  Copyright © 2015 jamy. All rights reserved.
//

import Foundation


struct Friend {
    let name: String
    let phone: String
    let iconName: String
}


struct FriendSession {
    let key: String
    let friends: [Friend]
}
