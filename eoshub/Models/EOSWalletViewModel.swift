//
//  Wallet.swift
//  eoshub
//
//  Created by kein on 2018. 7. 9..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import RxSwift



struct EOSWalletViewModel {
    let account: String
    let pubKey: String
    let totalEOS: Double
    let estimatedPrice: String
    let stakedEOS: Double
    let refundingEOS: Double
    var availableEOS: Double {
        return totalEOS - stakedEOS - refundingEOS
    }
    
    let refundingRemainTime: String
    
    let showSendButton: Bool
    
}


extension EOSWalletViewModel: CellType {
    var nibName: String {
        return "WalletCell"
    }
}
