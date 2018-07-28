//
//  EOSHubAPI.swift
//  eoshub
//
//  Created by kein on 2018. 7. 27..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation

struct EOSHubAPI {
    enum Token: String {
        case list
    }
}

extension EOSHubAPI.Token: RxAPIRequest {
    var url: String {
        return Config.eoshubHost + "/v1/token/" + rawValue
    }
}
