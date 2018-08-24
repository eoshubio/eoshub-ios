//
//  Sha256.swift
//  eoshub
//
//  Created by kein on 2018. 8. 24..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation

struct Sha256 {
    static func digest(data : Data) -> Data {
            var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
            data.withUnsafeBytes {
                _ = CC_SHA256($0, CC_LONG(data.count), &hash)
            }
            return Data(bytes: hash)
    }
}
