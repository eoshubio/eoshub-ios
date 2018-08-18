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
    
}

enum WalletError: Error {
    case noValidPrivatekey
    
    case authorizationViewisNotSet
    
    case failedToCreateDigest

    case failedToSignature
    
    case cancelled

}
