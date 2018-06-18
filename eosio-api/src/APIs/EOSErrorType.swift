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
}
