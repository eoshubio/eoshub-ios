//
//  EOSResponseModel.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 16..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation



struct BinaryString: JSONInitializable {
    
    let bin: String
    
    init?(json: JSON) {
        if let binary = json["binargs"] as? String {
            bin = binary
        } else {
            return nil
        }
    }
}


struct BlockInfo: JSONInitializable {
    let headBlockNum: Int64
    let chainId: String
   
    init?(json: JSON) {
        if let headBlockNum = json["head_block_num"] as? Int64,
            let chainId =  json["chain_id"] as? String {
            self.headBlockNum = headBlockNum
            self.chainId = chainId
        } else {
            return nil
        }
    }
    
}

struct BlockProducers: JSONInitializable {
    var produces: [BlockProducer] = []
    let totalVoteWeight: Double
    
    init?(json: JSON) {
        
        guard let response = json.arrayJson(for: "rows") else { return nil }
        let weightString = json.string(for: "total_producer_vote_weight") ?? "0"
        let weight = Double(weightString) ?? 0
        totalVoteWeight = weight
        
        var idx = -1
        
        produces = response.compactMap({ (json) -> BlockProducer? in
                            idx += 1
                            return BlockProducer(json: json, total: weight, index: idx)
                        })
        
    }
    
}
