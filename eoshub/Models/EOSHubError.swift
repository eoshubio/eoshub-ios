//
//  EOSHubError.swift
//  eoshub
//
//  Created by kein on 2018. 7. 28..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation

enum EOSHubError: Error, PrettyPrintedPopup {
    case userCanceled
    case txNotFound
    case accountNotFound
    case invalidState
    case failedToSignature
    case failedToGenerateKey
    
    var localizedDescription: String {
        switch self {
        case .userCanceled:
            return "Canceled"
        case .txNotFound:
            return "Transaction not found. It can take up to 15 minutes for transactions to be reflected in the block chain."
        case .accountNotFound:
            return "Account not found"
        case .invalidState:
            return "Invalid state"
        case .failedToSignature:
            return "Failed To Signature"
        case .failedToGenerateKey:
            return "Failed to generate keypair"
        }
    }
    
    func showPopup() {
        var title: String? = nil
        var text: String = ""
        switch self {
        case .userCanceled:
            text = "Canceled"
        case .txNotFound:
            title = "Transaction not found"
            text = "It can take up to 15 minutes for transactions to be reflected in the block chain."
        case .accountNotFound:
            title = "Account not found"
            text = ""
        case .invalidState:
            title = "Invalid state"
            text = "Invalid state. Please contact EOSHub."
        case .failedToSignature:
            title = "Failed To Signature"
            text = "Perhaps the problem is that the password is wrong or you can not access the Biometic (Face ID or Touch ID)."
        case .failedToGenerateKey:
            title = "Failed to generate keypair"
            text = ""
        }
        
        Popup.present(style: .failed, titleString: title, description: text)
    }
}


struct EOSHubResponseError: Error, JSONInitializable, PrettyPrintedPopup {
    
    let code: String
    let message: String?
    let type: String
    let data: Any?
    
    init?(json: JSON) {
        guard let resultType = json.string(for: "resultType"),
              resultType == "FAIL",
              let code = json.string(for: "resultCode") else { return nil }
        
        self.code = code
        self.message = json.string(for: "resultMessage")
        self.type = resultType
        self.data = json["resultData"]
    }
    
    
    func showPopup() {
        let errorText = code.capitalized.replacingOccurrences(of: "_", with: " ")
        
        let text: String = message ?? errorText
        
        Popup.present(style: .failed, description: text)
    }
    
}



enum WalletError: Error {
    case noValidPrivatekey
    
    case authorizationViewisNotSet
    
    case failedToCreateDigest

    case failedToSignature
    
    case canceled

}
