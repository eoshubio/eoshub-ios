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
}


enum EOSResponseError: Error, JSONInitializable {
    
    static let notError: [Code] = [.walletAlreadyUnlocked]
    
    enum Code: Int {
        case unknownError
        case messageException = 3050003
        case unAuthorized = 3090003
        case walletAlreadyUnlocked = 3120007 //skip
    }
    
    
    
    case walletAlreadyUnlocked(String?)
    case unsatisfiedAuthorization(String?)
    case messageException(String?)
    case unknownError(String?)
    
    init?(json: JSON) {
        guard let error = json["error"] as? JSON, let code = error["code"] as? Int else { return nil }
        
        let errorCode = Code(rawValue: code) ?? Code.unknownError
        
        if EOSResponseError.notError.contains(errorCode) {
            NSLog("Nor error: \(errorCode)")
            return nil
        }
        
        let message = json["message"] as? String
        
        switch errorCode {
        case .messageException:
            self = .messageException(message)
        case .walletAlreadyUnlocked:
            self = .walletAlreadyUnlocked(message)
        case .unAuthorized:
            self = .unsatisfiedAuthorization(message)
        case .unknownError:
            self = .unknownError(message)
        }
    }
}
