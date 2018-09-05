//
//  VoteInfo.swift
//  eoshub
//
//  Created by kein on 2018. 7. 14..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation

struct VoterInfo: JSONInitializable {
    let isProxy: Bool
    let lastVoteWeight: String
    let owner: String
    let producers: [String]
    let proxiedVoteWeight: String
    let proxy: String
    let staked: Int64
    
    init?(json: JSON) {
        guard let owner = json.string(for: "owner") else { return nil }
        self.owner = owner
        isProxy = json.bool(for: "is_proxy") ?? false
        lastVoteWeight = json.string(for: "last_vote_weight") ?? "0"
        producers = json.arrayString(for: "producers") ?? []
        proxiedVoteWeight = json.string(for: "proxied_vote_weight") ?? "0"
        proxy = json.string(for: "proxy") ?? ""
        staked = json.integer64(for: "staked") ?? 0
    }
}
