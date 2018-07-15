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

class TokenManager {
    static let shared = TokenManager()
    
    //TODO: Download from server
    private static var contractMap: [Symbol: String] = ["EOS": Config.eosInfo.contract,
                                                        "PDR": Config.pandoraInfo.contract,
                                                        "NOVA": Config.pandoraInfo.contract]
    
    static func getContract(for symbol: Symbol) -> String? {
        return contractMap[symbol]
    }
    
    //TODO: Save/Load with Realm
    var knownTokens: [TokenInfo] = [.pandora, TokenInfo(contract: "eoshubtokenz", symbol: "NOVA", name: "novashock")]
    
    init() {
        
    }
    
//    func loadTokenInfos() -> Observable<Void> {
//        infos.removeAll()
//        return Observable.from(Array(eoshubAccounts))
//            .concatMap { (account) -> Observable<> in
//
//
//    }
}
