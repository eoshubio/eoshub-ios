//
//  Packable.swift
//  eosio-api
//
//  Created by kein on 2018. 7. 1..
//  Copyright © 2018년 kein. All rights reserved.
//  from :https://github.com/eosmoto/eosiopy/blob/master/eosiopy/utils.py
//

import Foundation

typealias Iteration = StrideTo<Int>

protocol Packable {
    @discardableResult func serialize(pack: Pack) -> Pack
}

class Pack {
    var data: [UInt8] = []
    
    var packedBytes: [UInt8] {
        return Array(data[0..<idx])
    }
    
    var idx = 0
    
    init() {
        data = []
    }
    
    func put(_ byte: UInt8) {
        //append
        data.append(byte)
        idx += 1
    }
    
    func put(bytes: [UInt8]) {
        //append
        data += bytes
        idx += bytes.count
    }
    
    func putInt16(value: UInt16) {
        put(UInt8(0xFF & value))
        put(UInt8(0xFF & (value >> 8)))
    }
    
    func putInt32(value: UInt32) {
        put(UInt8(0xFF & value))
        put(UInt8(0xFF & (value >> 8)))
        put(UInt8(0xFF & (value >> 16)))
        put(UInt8(0xFF & (value >> 24)))
    }
    
    func putInt64(value: UInt64) {
        put(UInt8(0xFF & value))
        put(UInt8(0xFF & (value >> 8)))
        put(UInt8(0xFF & (value >> 16)))
        put(UInt8(0xFF & (value >> 24)))
        put(UInt8(0xFF & (value >> 32)))
        put(UInt8(0xFF & (value >> 40)))
        put(UInt8(0xFF & (value >> 48)))
        put(UInt8(0xFF & (value >> 56)))
    }
    
    
    
    func putVariableUInt(value: Int) {
        var val = value
        repeat {
            var b = UInt8(val & 0x7f)
            val >>= 7
            b |= (((val > 0) ? 1 : 0) << 7)
            put(b)
        } while val > 0
    }
    
    func put(string: String) {
        if string == "" {
            putVariableUInt(value: 0)
            return
        }
        putVariableUInt(value: string.count)
        let bytes: [UInt8] = Array(string.utf8)
        put(bytes: bytes)
    }
    
}

