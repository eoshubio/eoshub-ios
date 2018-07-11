//
//  AccountManager.swift
//  eoshub
//
//  Created by kein on 2018. 7. 11..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import RxSwift

class AccountManager {
    static let shared = AccountManager()
    
    let accountInfoRefreshed = PublishSubject<Void>()
    
    let pinConfirmed = PublishSubject<Void>()
    
    var needPinConfirm: Bool = true
    
}
