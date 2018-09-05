//
//  BlockProducer.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 27..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation

struct BlockProducer {
    let index: Int
    let owner: String
    let totalVotes: Double
    let key: String
    let isActive: Bool
    let url: String
    let lastClameTime: String
    let location: Int
    var ratio: Double = 0
    
    init?(json: JSON, total: Double, index: Int) {
        self.index = index
        guard let ownerName = json.string(for: "owner") else { return nil }
        owner = ownerName
        let votesString = json.string(for: "total_votes") ?? "0"
        totalVotes = Double(votesString) ?? 0
        if total > 0 {
            ratio = totalVotes / total
        }
        
        guard let producerkey = json.string(for: "producer_key") else { return nil }
        key = producerkey
        isActive = json.bool(for: "is_active") ?? false
        url = json.string(for: "url") ?? ""
        lastClameTime = json.string(for: "last_claim_time") ?? ""
        location = json.integer(for: "location") ?? 0
    }
    
}


