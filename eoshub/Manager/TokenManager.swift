//
//  TokenManager.swift
//  eoshub
//
//  Created by kein on 2018. 7. 14..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import Alamofire

class TokenManager {
    static let shared = TokenManager()

    private let bag = DisposeBag()
    
    //TODO: Save/Load with Realm, download from server
    lazy var knownTokens: Results<TokenInfo> = {
       return DB.shared.getTokens()
    }()
    
    init() {
    
    }
    
    func load() {
        Log.d("Download tokens")
        EOSHubAPI.Token.list
            .responseJSON(method: .get, parameter: nil, encoding: URLEncoding.default)
            .subscribe(onNext: { [weak self] (json) in
                self?.syncTokens(json: json)
                }, onError: { (error) in
                    Log.e(error)
            })
            .disposed(by: bag)
    }
    
    func syncTokens(json: JSON) {
        let data = json.json(for: "resultData")
        guard let list = data?.arrayJson(for: "tokenList") else { return }
        
        var tokens: [TokenInfo] = list.compactMap(TokenInfo.create)
        tokens.insert(contentsOf: [.pandora, TokenInfo(contract: "eoshubtokenz", symbol: "NOVA", name: "NovaShock")], at: 0) //TODO: uncomment
        
        DB.shared.addOrUpdateObjects(tokens)
    }

}
