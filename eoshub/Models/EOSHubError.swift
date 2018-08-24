//
//  EOSHubError.swift
//  eoshub
//
//  Created by kein on 2018. 7. 28..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation

enum EOSHubError: Error {
    case userCancelled
    case txNotFound
    
    var localizedDescription: String {
        switch self {
        case .userCancelled:
            return "Canceled."
        case .txNotFound:
            return "Transaction not found. It can take up to 15 minutes for transactions to be reflected in the block chain."
        }
    }
}

enum WalletError: Error {
    case noValidPrivatekey
    
    case authorizationViewisNotSet
    
    case failedToCreateDigest

    case failedToSignature
    
    case cancelled

}
