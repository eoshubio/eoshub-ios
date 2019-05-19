//
//  Contract.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 17..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation

struct Contract: JSONOutput {
    let code: String
    let action: Action
    let args: JSON
    let authorization: Authorization
    
    var json: JSON {
        var param: JSON = [:]
        param["code"] = code
        param["action"] = action.name.value
        param["args"] = args
        return param
    }
}



extension Contract {
    static func newAccount(name: String, owner: Authority, active: Authority, authorization: Authorization) -> Contract {
        let agrs: JSON = [Args.newaccount.creator: authorization.actor.value,
                          Args.newaccount.name: name,
                          Args.newaccount.owner: owner.json,
                          Args.newaccount.active: active.json ]
        let contract = Contract(code: "eosio", action: .newaccount, args: agrs, authorization: authorization)
        return contract
    }
    
    static func transfer(code: String = "eosio.token", from: String, to: String, quantity: Currency, memo: String = "", authorization: Authorization) -> Contract {
        let contract = Contract(code: code,
                                action: .transfer,
                                args: [Args.transfer.from: from,
                                       Args.transfer.to: to,
                                       Args.transfer.quantity: quantity.stringValue,
                                       Args.transfer.memo: memo],
                                authorization: authorization)
        return contract
    }
    
    static func buyram(payer: String, receiver: String, quant: Currency, authorization: Authorization) -> Contract {
        let contract = Contract(code: "eosio",
                                action: .buyram,
                                args: [Args.buyram.payer: payer,
                                       Args.buyram.receiver: receiver,
                                       Args.buyram.quant: quant.stringValue],
                                authorization: authorization)
        return contract
    }
    
    static func sellram(account: String, bytes: Int64, authorization: Authorization) -> Contract {
        let contract = Contract(code: "eosio",
                                action: .sellram,
                                args: [Args.sellram.account: account,
                                       Args.sellram.bytes: bytes],
                                authorization: authorization)
        return contract
    }
    
    
    
    static func buyramBytes(payer: String/*eoshub*/, receiver: String, bytes: Int64, authorization: Authorization) -> Contract {
        let contract = Contract(code: "eosio",
                                action: .buyrambytes,
                                args: [Args.buyrambytes.payer: payer,
                                       Args.buyrambytes.receiver: receiver,
                                       Args.buyrambytes.bytes: bytes],
                                authorization: authorization)
        return contract
    }
    
    static func delegateBW(from: String, receiver: String, cpu: Currency, net: Currency, authorization: Authorization) -> Contract {
        let contract = Contract(code: "eosio",
                                action: .delegatebw,
                                args: [Args.delegatebw.from: from,
                                       Args.delegatebw.receiver: receiver,
                                       Args.delegatebw.stake_cpu_quantity: cpu.stringValue,
                                       Args.delegatebw.stake_net_quantity: net.stringValue,
                                       Args.delegatebw.transfer : false],
                                authorization: authorization)
        return contract
    }
    
    static func undelegateBW(from: String, receiver: String, cpu: Currency, net: Currency, authorization: Authorization) -> Contract {
        let contract = Contract(code: "eosio",
                                action: .undelegatebw,
                                args: [Args.undelegatebw.from: from,
                                       Args.undelegatebw.receiver: receiver,
                                       Args.undelegatebw.unstake_cpu_quantity: cpu.stringValue,
                                       Args.undelegatebw.unstake_net_quantity: net.stringValue],
                                authorization: authorization)
        return contract
    }
    
    static func voteProducer(voter: String, producers: [String], authorization: Authorization) -> Contract {
        let contract = Contract(code: "eosio",
                                action: .voteproducer,
                                args: [Args.voteproducer.voter: voter,
                                       Args.voteproducer.proxy: "",
                                       Args.voteproducer.producers: producers],
                                authorization: authorization)
        return contract
    }
    
    static func refund(owner: String, authorization: Authorization) -> Contract {
        let contract = Contract(code: "eosio",
                                action: .refund, args: [Args.refund.owner: owner],
                                authorization: authorization)
        return contract
    }
    
    static func updateauth(account: String, permission: Permission, auth: Authority, authorization: Authorization) -> Contract {
        let parent = permission == Permission.owner ? "" : Permission.owner.value
        let contract = Contract(code: "eosio",
                                action: .updateauth,
                                args: [Args.updateauth.account: account,
                                       Args.updateauth.permission: permission.value,
                                       Args.updateauth.parent: parent,
                                       Args.updateauth.auth: auth.json],
                                authorization: authorization)
        
        return contract
    }
    
    //Rex
    
    
    /// Deposit into owner's REX fund by transfering from owner's liquid token balance
    static func deposit(owner: String, amount: Currency, authorization: Authorization) -> Contract {
        let contract = Contract(code: "eosio",
                                action: .deposit,
                                args: [Args.deposit.owner: owner,
                                       Args.deposit.amount: amount.stringValue],
                                authorization: authorization)
        return contract
    }
    
    /// Withdraw from owner's REX fund by transfering to owner's liquid token balance
    static func withdraw(owner: String, amount: Currency, authorization: Authorization) -> Contract {
        let contract = Contract(code: "eosio",
                                action: .withdraw,
                                args: [Args.withdraw.owner: owner,
                                       Args.withdraw.amount: amount.stringValue],
                                authorization: authorization)
        return contract
    }
    
    /// Buy REX using tokens in owner's REX fund
    static func buyrex(from: String, amount: Currency, authorization: Authorization) -> Contract {
        let contract = Contract(code: "eosio",
                                action: .buyrex,
                                args: [Args.buyrex.from: from,
                                       Args.buyrex.amount: amount.stringValue],
                                authorization: authorization)
        return contract
    }
    
    /// Sell REX tokens
    static func sellrex(from: String, amount: Currency, authorization: Authorization) -> Contract {
        let contract = Contract(code: "eosio",
                                action: .sellrex,
                                args: [Args.sellrex.from: from,
                                       Args.sellrex.rex: amount.stringValue],
                                authorization: authorization)
        return contract
    }
    
    /// Buy REX using staked tokens
    static func unstaketorex(owner: String, receiver: String, from_cpu: Currency, from_net: Currency, authorization: Authorization) -> Contract {
        let contract = Contract(code: "eosio",
                                action: .unstaketorex,
                                args: [Args.unstaketorex.owner: owner,
                                       Args.unstaketorex.receiver: receiver,
                                       Args.unstaketorex.from_cpu: from_cpu.stringValue,
                                       Args.unstaketorex.from_net: from_net.stringValue],
                                authorization: authorization)
        return contract
    }
    
    /// Rent CPU bandwidth for 30 days
    static func rentcpu(from: String, receiver: String, loan_payment: Currency, loan_fund: Currency, authorization: Authorization) -> Contract {
        let contract = Contract(code: "eosio",
                                action: .rentcpu,
                                args: [Args.rentcpu.from: from,
                                       Args.rentcpu.receiver: receiver,
                                       Args.rentcpu.loan_payment: loan_payment.stringValue,
                                       Args.rentcpu.loan_fund: loan_fund.stringValue],
                                authorization: authorization)
        return contract
    }
    
    /// Rent Network bandwidth for 30 days
    static func rentnet(from: String, receiver: String, loan_payment: Currency, loan_fund: Currency, authorization: Authorization) -> Contract {
        let contract = Contract(code: "eosio",
                                action: .rentnet,
                                args: [Args.rentnet.from: from,
                                       Args.rentnet.receiver: receiver,
                                       Args.rentnet.loan_payment: loan_payment.stringValue,
                                       Args.rentnet.loan_fund: loan_fund.stringValue],
                                authorization: authorization)
        return contract
    }
}

extension Contract {
    enum Action: String {
        case newaccount
        case transfer
        case buyram
        case sellram
        case delegatebw
        case undelegatebw
        case voteproducer
        case buyrambytes
        case refund
        case updateauth
        //rex
        case deposit // - Deposit into owner's REX fund by transfering from owner's liquid token balance
        case withdraw // - Withdraw from owner's REX fund by transfering to owner's liquid token balance
        case buyrex // - Buy REX using tokens in owner's REX fund
        case lendrex // - Deposit tokens to REX fund and use the tokens to buy REX
        case unstaketorex // - Buy REX using staked tokens
        case sellrex // - Sell REX tokens
        case cancelrexorder // - Cancel queued REX sell order if one exists
        case mvtosavings // - Move REX tokens to savings bucket
        case mvfromsavings // - Move REX tokens out of savings bucket
        case rentcpu // - Rent CPU bandwidth for 30 days
        case rentnet // - Rent Network bandwidth for 30 days
        case fundcpuloan // - Deposit into a CPU loan fund
        case fundnetloan // - Deposit into a Network loan fund
        case defundcpuloan // - Withdraw from a CPU loan fund
        case defundnetloan // - Withdraw from a Network loan fund
        case consolidate // - Consolidate REX maturity buckets into one that matures in 4 days
        case updaterex // - Update REX owner vote stake and vote weight
        case rexexec // - Perform REX maintenance by processing expired loans andunfilledll orders
        case closerex // - Delete unused REX-related user table entries
        
        var name: EOSName {
            return EOSName(rawValue)
        }
    }
    
  
}

