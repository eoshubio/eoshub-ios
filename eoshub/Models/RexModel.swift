//
//  RexModel.swift
//  eoshub
//
//  Created by kein on 06/05/2019.
//  Copyright © 2019 EOS Hub. All rights reserved.
//

import Foundation

/*
 {
 "version": 0,
 "owner": "accountname",
 "balance": "0.0000 EOS"
 }
 */
struct RexFund: JSONInitializable {
    let owner: String
    let balance: Currency
    
    init?(json: JSON) {
        guard let owner = json.string(for: "owner"),
              let balanceString = json.string(for: "balance"),
              let balance = Currency(eosCurrency: balanceString) else { return nil }
        self.owner = owner
        self.balance = balance
    }
    
    init(account: String) {
        owner = account
        balance = Currency.zeroEOS
    }
}

/*
 {
 "version": 0,
 "owner": "accountname",
 "vote_stake": "5.5000 EOS",
 "rex_balance": "54989.0905 REX",
 "matured_rex": 0,
 "rex_maturities": [{
 "first": "2019-05-10T00:00:00",
 "second": 499900903
 },{
 "first": "2019-05-11T00:00:00",
 "second": 49990002
 }
 ]
 }
 */
struct RexBalance: JSONInitializable {
    let owner: String
    let voteStake: Currency
    let rexBalance: Currency
    let maturedRex: Currency
    let maturities: [RexMaturity]
    
    init?(json: JSON) {
        guard let owner = json.string(for: "owner"),
              let voteStakeString = json.string(for: "vote_stake"),
              let rexBalanceString = json.string(for: "rex_balance"),
              let maturedRexValue = json.uint64(for: "matured_rex"),
              let maturities = json.arrayJson(for: "rex_maturities") else { return nil }
        
        guard let voteStake = Currency(eosCurrency: voteStakeString),
              let rexBalance = Currency.create(stringValue: rexBalanceString, contract: "eosio") else { return nil }
        
        self.owner = owner
        self.voteStake = voteStake
        self.rexBalance = rexBalance
        self.maturedRex = Currency(integer: maturedRexValue, token: .rex)
        self.maturities = maturities.compactMap(RexMaturity.init)
    }
    
    init(account: String) {
        owner = account
        voteStake = Currency.zeroEOS
        rexBalance = Currency(balance: 0, token: .rex)
        maturedRex = Currency(balance: 0, token: .rex)
        maturities = []
    }
}


struct RexMaturity: JSONInitializable {
    let timestamp: TimeInterval
    let rex: Currency
    
    init?(json: JSON) {
        guard let dateString = json.string(for: "first"),
            let date = Date.UTCToDate(date: dateString),
            let amountValue = json.uint64(for: "second") else { return nil }
        self.timestamp = date.timeIntervalSince1970
        self.rex = Currency(integer: amountValue, token: .rex)
    }
}

struct RexInfo {
    let fund: RexFund
    let balance: RexBalance
    
    static func empty(account: String) -> RexInfo {
        return RexInfo(fund: RexFund(account: account), balance: RexBalance(account: account))
    }
}
