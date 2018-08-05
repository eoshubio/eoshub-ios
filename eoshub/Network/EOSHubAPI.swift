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
    
    enum URL: String {
        case term
        case privacy_policy
    }
}

extension EOSHubAPI.Token: RxAPIRequest {
    var url: String {
        return Config.eoshubHost + "/v1/token/" + rawValue
    }
}

extension EOSHubAPI.URL {
    func getHtml() -> URL {
        return getHtml(languateCode: Locale.current.languageCode ?? "en")
    }
    func getHtml(languateCode: String) -> URL {
        if languateCode == "ko" {
            return URL(string: Config.eoshubHost + "/" + rawValue)!
        } else {
            return URL(string: Config.eoshubHost + "/" + rawValue + "?lang=en")!
        }
    }
}
