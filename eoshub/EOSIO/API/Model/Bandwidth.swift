//
//  Resource.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 26..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation

struct Bandwidth: JSONInitializable {
    let used: Int64
    let available: Int64
    let max: Int64
    
    init?(json: JSON) {
        guard let used = json.integer64(for: "used") else { return nil }
        guard let available = json.integer64(for: "available") else { return nil }
        guard let max = json.integer64(for: "max") else { return nil }
        self.used = used
        self.available = available
        self.max = max
    }
    
    init() {
        used = 0
        available = 0
        max = 0
    }
    
}

extension Bandwidth {
    static let zero = Bandwidth()
}
