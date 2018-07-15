//
//  RefundRequest.swift
//  eoshub
//
//  Created by kein on 2018. 7. 15..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation

struct RefundInfo: JSONInitializable {
    let cpuAmountEOS: Double
    let netAmountEOS: Double
    let requestedTime: TimeInterval
    var totalAmount: Double {
        return cpuAmountEOS + netAmountEOS
    }
    
    init?(json: JSON) {
        guard let cpuAmount = json.string(for: "cpu_amount"),
                let netAmount = json.string(for: "net_amount"),
                let date = json.string(for: "request_time"),
                let requestTime = Date.UTCToDate(date: date)?.timeIntervalSince1970 else { return nil }
        
        cpuAmountEOS = Currency(currency: cpuAmount)!.quantity
        netAmountEOS = Currency(currency: netAmount)!.quantity
        requestedTime = requestTime
        
    }
}
