//
//  Contract+Args.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 24..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation

extension Contract {
    enum Key: String {
        case creator
        case name
        case owner
        case active
        case from
        case to
        case quantity
        case memo
        case receiver
        case stake_net_quantity
        case stake_cpu_quantity
        case unstake_net_quantity
        case unstake_cpu_quantity
        case transfer
        case voter
        case proxy
        case producers
        case payer
        case quant
        case bytes

    }
    
    struct Args {
        struct newaccount {
            static let creator = Key.creator.rawValue
            static let name = Key.name.rawValue
            static let owner = Key.owner.rawValue
            static let active = Key.active.rawValue
        }
        
        struct transfer {
            static let from = Key.from.rawValue
            static let to = Key.to.rawValue
            static let quantity = Key.quantity.rawValue
            static let memo = Key.memo.rawValue
        }
        
        struct buyram {
            static let payer = Key.payer.rawValue
            static let receiver = Key.receiver.rawValue
            static let quant = Key.quant.rawValue
        }
        
        struct buyrambytes {
            static let payer = Key.payer.rawValue
            static let receiver = Key.receiver.rawValue
            static let bytes = Key.bytes.rawValue
        }
        
        struct delegatebw {
            static let from = Key.from.rawValue
            static let receiver = Key.receiver.rawValue
            static let stake_net_quantity = Key.stake_net_quantity.rawValue
            static let stake_cpu_quantity = Key.stake_cpu_quantity.rawValue
            static let transfer = Key.transfer.rawValue
        }
        
        struct undelegatebw {
            static let from = Key.from.rawValue
            static let receiver = Key.receiver.rawValue
            static let unstake_net_quantity = Key.unstake_net_quantity.rawValue
            static let unstake_cpu_quantity = Key.unstake_cpu_quantity.rawValue
        }
        
        struct voteproducer {
            static let voter = Key.voter.rawValue
            static let proxy = Key.proxy.rawValue
            static let producers = Key.producers.rawValue
        }
    }
    
}
