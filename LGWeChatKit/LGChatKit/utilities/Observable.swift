//
//  Observable.swift
//  LGChatViewController
//
//  Created by jamy on 10/20/15.
//  Copyright © 2015 jamy. All rights reserved.
//

import Foundation


class Observable<T> {
    typealias Observer = T -> Void
    var observer: Observer?
    
    func observe(observer: Observer?) {
        self.observer = observer
        observer?(value)
    }
    
    var value: T {
        didSet {
            observer?(value)
        }
    }
    
    init(_ v: T) {
        value = v
    }
}