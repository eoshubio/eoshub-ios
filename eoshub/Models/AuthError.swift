//
//  AuthError.swift
//  eoshub
//
//  Created by kein on 2018. 8. 5..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation

enum AuthErrorType: String {
    case ERROR_USER_NOT_FOUND
    case ERROR_WRONG_PASSWORD
    case ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL
    
}




struct AuthError: Error {
    let code: String
    let description: String
    
    var type: AuthErrorType? {
        return AuthErrorType(rawValue: code)
    }
    
    var title: String {
        var errorTitle = code.replacingOccurrences(of: "ERROR_", with: "")
        errorTitle = errorTitle.replacingOccurrences(of: "_", with: " ")
        return errorTitle.capitalized
    }
    
    var localizedDescription: String {
        return description
    }
    
    init(with error: NSError) {
        let info = error.userInfo
        self.code = info.string(for: "error_name") ?? "Unknown error"
        self.description = info.string(for: "NSLocalizedDescription") ?? ""
        
    }
}

extension AuthError {
    static func getError(error: Error) -> AuthError? {
        let error = error as NSError
        return AuthError(with: error)
    }
    
    func showPopup() {
        Popup.present(style: .failed, titleString: title, description: localizedDescription)
    }
}
