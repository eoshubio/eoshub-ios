//
//  Wallet.swift
//  eoshub
//
//  Created by kein on 2018. 7. 9..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import RxSwift



protocol EOSAccountViewModel {
    var account: String { get }
    var pubKey: String { get }
    var totalEOS: Double { get }
    var stakedEOS: Double { get }
    var refundingEOS: Double { get }
    var availableEOS: Double { get }
    var refundRequestTime: TimeInterval { get }
    var ownerMode: Bool { get set }
}



