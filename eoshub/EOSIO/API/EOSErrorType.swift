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


enum EOSResponseError: Error, JSONInitializable {
    
    static let notError: [Code] = [.walletAlreadyUnlocked]
    
    enum Code: Int {
        case unknownError
        case messageException = 3050003
        case unAuthorized = 3090003
        case walletAlreadyUnlocked = 3120007 //skip
    }
    
    
    
    case walletAlreadyUnlocked(String)
    case unsatisfiedAuthorization(String)
    case messageException(String)
    case unknownError(String)
    case unknownKey
    
    init?(json: JSON) {
        guard let error = json["error"] as? JSON, let code = error["code"] as? Int else { return nil }
        
        let errorCode = Code(rawValue: code) ?? Code.unknownError
        
        if EOSResponseError.notError.contains(errorCode) {
            NSLog("Not error: \(errorCode)")
            return nil
        }
        
        let message = json.string(for: "message")
        
        let detailMessgae = json.json(for: "error")?.arrayJson(for: "details")?.first?.string(for: "message")
        
        let errorMessage = detailMessgae ?? message ?? "\(code)"
    
        
        switch errorCode {
        case .messageException:
            self = .messageException(errorMessage)
        case .walletAlreadyUnlocked:
            self = .walletAlreadyUnlocked(errorMessage)
        case .unAuthorized:
            self = .unsatisfiedAuthorization(errorMessage)
        case .unknownError:
            if errorMessage == "unknown key" {
                self = .unknownKey
            } else {
                self = .unknownError(errorMessage)
            }
        }
    }
    
}
