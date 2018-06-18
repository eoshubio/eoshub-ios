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
    
    
/*
{"expiration":"2018-06-17T03:14:35",
 "ref_block_num":18378,
 "ref_block_prefix":2290226662,
 "max_net_usage_words":0,
 "max_cpu_usage_ms":0,
 "delay_sec":0,
 "context_free_actions":[],
 "actions":[{"account":"eosio","name":"newaccount","authorization":[{"actor":"eosio","permission":"active"}],"data":"0000000000ea30550082ca54aa3b9d82000000000201000001000000000201000001"}],
 "transaction_extensions":[],
 "signatures":["SIG_K1_KapiPjqhwRxi9MCPHohEGERfeCNwrgUGbui5TxWBYX1QZcxtDuaxgeP1p3tp8pUWi5gvpp9kaJLW6ib9tzRTibgx84ah2x"],
 "context_free_data":[]}
*/

