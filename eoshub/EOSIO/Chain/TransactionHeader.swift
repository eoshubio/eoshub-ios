//
//  TransactionHeader.swift
//  eosio-api
//
//  Created by kein on 2018. 7. 4..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation


class TransactionHeader: Packable, JSONInitializable, JSONOutput {
    private let expirationSec: TimeInterval = 180
    
    @discardableResult func serialize(pack: Pack) -> Pack {
        let expiration = Int(expirationDate.timeIntervalSince1970)
        pack.putInt32(value: UInt32(expiration))
        pack.putInt16(value: UInt16(refBlockNum & 0xFFFF))
        pack.putInt32(value: UInt32(refBlockPrefix & 0xFFFFFFFF))
        pack.putVariableUInt(value: netUsageWords)
        pack.putVariableUInt(value: maxCpuUsage)
        pack.putVariableUInt(value: delaySec)
        return pack
    }
    
    let expirationDate: Date
    let refBlockNum: Int
    let refBlockPrefix: Int64
    var netUsageWords: Int = 0 //number of 8 byte words this transaction can serialize into after compressions
    var maxCpuUsage: Int = 0 //number of CPU usage units to bill transaction for (ms)
    var delaySec = 0 // number of CPU usage units to bill transaction for
    
    var json: JSON {
        var params: JSON = [:]
        params["expiration"] = expirationDate.dateToUTC()
        params["ref_block_num"] = refBlockNum
        params["ref_block_prefix"] = refBlockPrefix
        params["max_net_usage_words"] = netUsageWords
        params["max_cpu_usage_ms"] = maxCpuUsage
        params["delay_sec"] = delaySec
        return params
    }
    
    init(block: Block) {
        expirationDate = block.timeStamp.addingTimeInterval(expirationSec)
        refBlockNum = block.blockNum
        refBlockPrefix = block.refBlockPrefix
    }
    
    required init?(json: JSON) {
        guard let timeStamp = json["expiration"] as? String else { return nil }
        guard let date = Date.UTCToDate(date: timeStamp) else { return nil }
        guard let refBlockNum = json.integer(for: "ref_block_num") else { return nil }
        
        guard let refBlockPrefix = json.integer64(for: "ref_block_prefix") else { return nil }
        
        self.expirationDate = date
        self.refBlockNum = refBlockNum
        self.refBlockPrefix = refBlockPrefix
        self.netUsageWords = json.integer(for: "max_net_usage_words") ?? 0
        self.maxCpuUsage = json.integer(for: "max_cpu_usage_ms") ?? 0
        self.delaySec = json.integer(for: "delay_sec") ?? 0
        
    }
}
