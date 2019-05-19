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
        case account
        case permission
        case parent
        case auth
        case amount
        case from_cpu
        case from_net
        case rex
        case loan_payment
        case loan_fund
        case loan_num
        case payment
        case user
        case max
    }
    
    class Args {
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
        
        struct sellram {
            static let account = Key.account.rawValue
            static let bytes = Key.bytes.rawValue
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
        
        struct refund {
            static let owner = Key.owner.rawValue
        }
        
        struct updateauth {
            static let account = Key.account.rawValue
            static let permission = Key.permission.rawValue
            static let parent = Key.parent.rawValue
            static let auth = Key.auth.rawValue
        }

        struct deposit {
            static let owner = Key.owner.rawValue
            static let amount = Key.amount.rawValue
        }
        
        struct withdraw {
            static let owner = Key.owner.rawValue
            static let amount = Key.amount.rawValue
        }
        
        struct buyrex {
            static let from = Key.from.rawValue
            static let amount = Key.amount.rawValue
        }
        
        struct lendrex {
            static let from = Key.from.rawValue
            static let amount = Key.amount.rawValue
        }
        
        struct unstaketorex {
            static let owner = Key.owner.rawValue
            static let receiver = Key.receiver.rawValue
            static let from_cpu = Key.from_cpu.rawValue
            static let from_net = Key.from_net.rawValue
        }
        
        struct sellrex {
            static let from = Key.from.rawValue
            static let rex = Key.rex.rawValue
        }
        
        struct cancelrexorder {
            static let owner = Key.owner.rawValue
        }
        
        struct mvtosavings {
            static let owner = Key.owner.rawValue
            static let rex = Key.rex.rawValue
        }
        
        struct mvfromsavings {
            static let owner = Key.owner.rawValue
            static let rex = Key.rex.rawValue
        }
        
        struct rentcpu {
            static let from = Key.from.rawValue
            static let receiver = Key.receiver.rawValue
            static let loan_payment = Key.loan_payment.rawValue
            static let loan_fund = Key.loan_fund.rawValue
        }
        
        struct rentnet {
            static let from = Key.from.rawValue
            static let receiver = Key.receiver.rawValue
            static let loan_payment = Key.loan_payment.rawValue
            static let loan_fund = Key.loan_fund.rawValue
        }
        
        struct fundcpuloan {
            static let from = Key.from.rawValue
            static let loan_num = Key.loan_num.rawValue
            static let payment = Key.payment.rawValue
        }
        
        struct fundnetloan {
            static let from = Key.from.rawValue
            static let loan_num = Key.loan_num.rawValue
            static let payment = Key.payment.rawValue
        }
        
        struct defundcpuloan {
            static let from = Key.from.rawValue
            static let loan_num = Key.loan_num.rawValue
            static let payment = Key.payment.rawValue
        }
        
        struct defundnetloan {
            static let from = Key.from.rawValue
            static let loan_num = Key.loan_num.rawValue
            static let payment = Key.payment.rawValue
        }
        
        struct consolidate {
            static let owner = Key.owner.rawValue
        }
        
        struct updaterex {
            static let owner = Key.owner.rawValue
        }
        
        struct rexexec {
            static let user = Key.user.rawValue
            static let max = Key.max.rawValue
        }
        
        struct closerex {
            static let owner = Key.owner.rawValue
        }
    }
}
