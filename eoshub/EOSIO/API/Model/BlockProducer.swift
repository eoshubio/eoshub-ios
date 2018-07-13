//
//  BlockProducer.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 27..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation

struct BlockProducer: JSONInitializable {
    let owner: String
    let totalVotes: Currency
    let key: String
    let isActive: Bool
    let url: String
    let lastClameTime: String
    let location: Int
    
    
    init?(json: JSON) {
        guard let ownerName = json.string(for: "owner") else { return nil }
        owner = ownerName
        let votesString = json.string(for: "total_votes") ?? "0.0000"
        totalVotes = Currency(currency: votesString + " EOS") ?? .zeroEOS
        guard let producerkey = json.string(for: "producer_key") else { return nil }
        key = producerkey
        isActive = json.bool(for: "is_active") ?? false
        url = json.string(for: "url") ?? ""
        lastClameTime = json.string(for: "last_claim_time") ?? ""
        location = json.integer(for: "location") ?? 0
    }
    
}


