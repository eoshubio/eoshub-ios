//
//  Account.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 26..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import RxSwift

struct Account: JSONInitializable {
    let name: String
    let liquidBalance: Currency
    let ramQuota: Int64
    let netWeight: Int64
    let cpuWeight: Int64
    let netLimit: Bandwidth //20 bytes
    let cpuLimit: Bandwidth //3 us
    let ramUsage: Int64
    let permissions: [Authority]
    let resources: Resources
    var voterInfo: VoterInfo? = nil
    var refundInfo: RefundInfo? = nil
    
    init?(json: JSON) {
        guard let accountName = json.string(for: "account_name") else { return nil }
        name = accountName
        if let balance = json.string(for: "core_liquid_balance"), let liquidEOS = Currency(eosCurrency: balance) {
            liquidBalance = liquidEOS
        } else {
            liquidBalance = Currency.zeroEOS
        }
        
        ramQuota = json.integer64(for: "ram_quota") ?? 0
        netWeight = json.integer64(for: "net_weight") ?? 0
        cpuWeight = json.integer64(for: "cpu_weight") ?? 0
        if let limit = json.json(for: "net_limit"), let netLimit = Bandwidth(json: limit) {
            self.netLimit = netLimit
        } else {
            self.netLimit = .zero
        }
        
        if let limit = json.json(for: "cpu_limit"), let cpuLimit = Bandwidth(json: limit) {
            self.cpuLimit = cpuLimit
        } else {
            self.cpuLimit = .zero
        }
        
        self.ramUsage = json.integer64(for: "ram_usage") ?? 0
        
        self.permissions = json.arrayJson(for: "permissions")?.compactMap(Authority.init) ?? []
        
        if let resJSON = json.json(for: "self_delegated_bandwidth"), let res = Resources(json: resJSON) {
            self.resources = res
        } else {
            self.resources = .zero
        }
        
        if let voterInfoJSON = json.json(for: "voter_info") {
            self.voterInfo = VoterInfo(json: voterInfoJSON)
        }
        
        if let refundJSON = json.json(for: "refund_request") {
            self.refundInfo = RefundInfo(json: refundJSON)
        }
    }
    
}

//TODO: 아래 내용 처리
//"self_delegated_bandwidth": null,

