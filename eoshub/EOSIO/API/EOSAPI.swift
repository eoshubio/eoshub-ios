//
//  EOSApi.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 13..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift


struct EOSAPI {
    public enum Chain: String {
        case get_info
        case get_block
        case get_block_header_state
        case get_account
        case get_abi
        case get_code
        case get_table_rows
        case get_currency_stats
        case get_currency_balance
        case abi_json_to_bin
        case abi_bin_to_json
        case get_required_keys
        case get_producers
        case push_block
        case push_transaction
        case push_transactions
    }
    
    public enum History: String {
        case get_actions
        case get_transaction
        case get_key_accounts
        case get_controlled_accounts
    }

}

extension EOSAPI.Chain: RxAPIRequest {
    var url: String {
        return  EOSHost.shared.url + "/chain/" +  rawValue
    }
}

extension EOSAPI.History: RxAPIRequest {
    var url: String {
        return EOSHost.shared.urlContainsHistory + "/history/" + rawValue
    }
}



