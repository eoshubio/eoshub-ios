//
//  EOSIOConfig.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 17..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation

//TODO: eoshub 의 개인키를 클라이언트에 저장하면 안되므로, Production 레벨에서 삭제한다.
struct EOSIO {
    static let publicKey = "EOS6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV"
    static let privateKey = "5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3"
}

internal struct EOSHub {
    struct Junglenet {
        static let publicKey = "EOS6wWmsEAawx9AfbzEb9cSugdnAjmCnRUYfadp3zkxZNvDnbKEZv"
        static let privateKey = "5KCFf2amNPEHvbzkrs2EoNKgMFFe1qPzKfaiuzAWAdPE2b8Kcgb"
        static let account = "eoshubtest"
    }
    
    
    static let publicKey = Junglenet.publicKey
    static let privateKey = Junglenet.privateKey
    static let account = Junglenet.account
}

