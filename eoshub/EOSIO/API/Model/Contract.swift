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
        param["action"] = action.rawValue
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
        let contract = Contract(code: "eosio",
                                action: .updateauth,
                                args: [Args.updateauth.account: account,
                                       Args.updateauth.permission: permission.value,
                                       Args.updateauth.parent: Permission.owner.value,
                                       Args.updateauth.auth: auth.json],
                                authorization: authorization)
        
        return contract
    }
}

extension Contract {
    enum Action: String {
        case newaccount, transfer, buyram, sellram, delegatebw, undelegatebw, voteproducer
        case buyrambytes
        case refund
        case updateauth
    }
}

