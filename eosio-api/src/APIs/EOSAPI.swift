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
        case get_account
        case get_code
        case get_table_rows
        case get_currency_balance
        case abi_json_to_bin
        case abi_bin_to_json
        case push_transaction
        case push_transactions
        case get_required_keys
    }
    
    public enum Wallet: String {
        case create
        case open
        case lock
        case lock_all
        case unlock
        case import_key
        case list_wallets
        case list_keys
        case get_public_keys
        case set_timeout
        case sign_transaction
        case create_key
    }
}

extension EOSAPI.Chain {
    var url: String {
        return  EOSHost.shared.url + "/chain/" +  rawValue
    }
}

extension EOSAPI.Wallet {
    var url: String {
        return  EOSHost.shared.url + "/wallet/" +  rawValue
    }
}



