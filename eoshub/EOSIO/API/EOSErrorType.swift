//
//  EOSErrorType.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 16..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation



enum EOSErrorType: Error {
    case emptyData
    case emptyResponse
    case invalidFormat
    case walletIsNotExist
    case sigFailed
    case hasNotValidKey
    case invalidState
    case unknownContract
    case contractNotFound
    case authenticationFailed
    case invalidKeys
    case cannotFoundPIN
    case existAccount
}


struct EOSExceptionStack: JSONInitializable {
    var file: String = ""
    var line: Int = 0
    var message: String = ""
    var method: String = ""
    
    init?(json: JSON) {
        file = json.string(for: "file") ?? ""
        line = json.integer(for: "line_number") ?? 0
        message = json.string(for: "message") ?? ""
        method = json.string(for: "method") ?? ""
    }
}

struct EOSResponseError: Error, JSONInitializable {
    let code: Int
    let stack: [EOSExceptionStack]
    let name: String
    let what: String
    
    init?(json: JSON) {
        guard let error = json.json(for: "error") else { return nil }
        guard let code = error.integer(for: "code"),
              let details = error.arrayJson(for: "details"),
              let name = error.string(for: "name"),
              let what = error.string(for: "what") else { return nil }
        
        self.code = code
        self.stack = details.compactMap(EOSExceptionStack.init)
        self.name = name
        self.what = what
    }
    
    init(code: Int, stack: [EOSExceptionStack], name: String, what: String) {
        self.code = code
        self.stack = stack
        self.name = name
        self.what = what
    }
}

extension EOSResponseError: PrettyPrintedPopup {
    
    func showPopup() {
        showErrorPopup()
    }
    
    func showErrorPopup() {
        let title = name.capitalized.replacingOccurrences(of: "_", with: " ")
        if let detail = stack.first?.message {
            Popup.present(style: .failed, titleString: title, description: detail)
        } else {
            Popup.present(style: .failed, titleString: title, description: what)
        }
    }
    
    var isUnknownKey: Bool {
        return stack.filter({ $0.message.contains("unknown key") }).count > 0
    }
}



protocol PrettyPrintedPopup {
    func showPopup()
}



