//
//  DispatchQueue.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 17..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation


func dispatch_async_on_mainThread(_ block: @escaping ()->()) {
    if Thread.isMainThread {
        block()
    } else {
        DispatchQueue.main.async(execute: {
            block()
        })
    }
}

func dispatch_sync_on_mainThread(_ block: ()->()) {
    if Thread.isMainThread {
        block()
    } else {
        DispatchQueue.main.sync(execute: {
            block()
        })
    }
}
