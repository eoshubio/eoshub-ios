//
//  EOSHubError.swift
//  eoshub
//
//  Created by kein on 2018. 7. 28..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation

enum EOSHubError: Error, PrettyPrintedPopup {
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
    
    func showPopup() {
        var title: String? = nil
        var text: String = ""
        switch self {
        case .userCancelled:
            text = "Canceled."
        case .txNotFound:
            title = "Transaction not found"
            text = "It can take up to 15 minutes for transactions to be reflected in the block chain."
        }
        
        Popup.present(style: .failed, titleString: title, description: text)
    }
}

enum WalletError: Error {
    case noValidPrivatekey
    
    case authorizationViewisNotSet
    
    case failedToCreateDigest

    case failedToSignature
    
    case cancelled

}
