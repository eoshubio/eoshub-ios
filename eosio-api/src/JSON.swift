//
//  JSON.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 13..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation

typealias JSON = [String: Any]

protocol JSONInitializable {
    init?(json: JSON)
}

protocol JSONOutput {
    var json: JSON { get }
}



