//
//  EOSHubAPI.swift
//  eoshub
//
//  Created by kein on 2018. 7. 27..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

struct EOSHubAPI {
    enum Token: String {
        case list
    }
    
    enum Account: String {
        case memo
        case create
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

extension EOSHubAPI.Account: RxAPIRequest {
    var url: String {
        return Config.eoshubHost + "/v1/account/" + rawValue
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

extension EOSHubAPI {
    
    
    static func getMemo(userId: String) -> Observable<JSON> {
        let header = ["user_id": userId]
        
        return EOSHubAPI.Account.memo
            .responseJSON(method: .get, parameter: [:], encoding: URLEncoding.default, header: header)
    }
    
    static func refreshMemo(userId: String) -> Observable<JSON> {
        let header = ["user_id": userId]
        
        return EOSHubAPI.Account.memo
            .responseJSON(method: .post, parameter: [:], encoding: URLEncoding.default, header: header)
    }
    
    static func createAccount(userId: String, txId: String, accountName: String, ownerKey: String, activeKey: String) -> Observable<JSON> {
        let header = ["user_id": userId]
        let parmas = ["txId": txId,
                      "accountName": accountName,
                      "ownerKey": ownerKey,
                      "activeKey": activeKey]
        
        return EOSHubAPI.Account.create
            .responseJSON(method: .post, parameter: parmas, encoding: URLEncoding.default, header: header)
        
    }
    
}
