//
//  Wallet.swift
//  eoshub
//
//  Created by kein on 2018. 7. 9..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import RxSwift

//TODO: 내일 할일 - (Account + EHAccount) -> EOSAccountViewModel 변환함수 만들기
class AccountInfo: EOSAccountViewModel {
    let account: String
    let pubKey: String
    var totalEOS: Double {
        return availableEOS + stakedEOS
    }
    var availableEOS: Double
    var stakedEOS: Double
    
    //TODO: implement
    var refundingEOS: Double = 0
    var refundingRemainTime: TimeInterval = 0
    var ownerMode: Bool = false
    var estimatedPrice: String = ""
    
    init(with eosioAccount: Account, isOwner: Bool) {
        account = eosioAccount.name
        pubKey = eosioAccount.permissions.first?.keys.first?.key ?? ""
        availableEOS = eosioAccount.liquidBalance.quantity
        stakedEOS = eosioAccount.resources.staked
        ownerMode = isOwner
        
    }
    
//    var account: String {
//        return name
//    }
//
//    var pubKey: String {
//        return permissions.first?.keys.first?.key ?? ""
//    }
//
//    var totalEOS: Double {
//        return liquidBalance
//    }
//
//
//
//    var stakedEOS: Double {
//        return resources.staked
//    }
//
//    //TODO: implement
//    var refundingEOS: Double {
//        return 0
//    }
//
//    var availableEOS: Double {
//        return totalEOS - stakedEOS - refundingEOS
//    }
//
//    //TODO: implement
//    var refundingRemainTime: String {
//        return ""
//    }
//
//    //TODO: implement
//    var estimatedPrice: String = ""
//    var ownerMode = false

}


protocol EOSAccountViewModel {
    var account: String { get }
    var pubKey: String { get }
    var totalEOS: Double { get }
    var estimatedPrice: String { get set }
    var stakedEOS: Double { get }
    var refundingEOS: Double { get }
    var availableEOS: Double { get }
    var refundingRemainTime: TimeInterval { get }
    var ownerMode: Bool { get set }
}

extension EOSAccountViewModel {
    var refundingDateString: String {
        return Date(timeIntervalSinceNow: refundingRemainTime).dateToTime()
    }
    
}

extension AccountInfo: CellType {
    
    var nibName: String {
        return "WalletCell"
    }
}
