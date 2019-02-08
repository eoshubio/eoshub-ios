//
//  DeleatedBW.swift
//  eoshub
//
//  Created by kein on 08/02/2019.
//  Copyright © 2019 EOS Hub. All rights reserved.
//

import Foundation

struct DelegateBW {
    let account: EOSName
    let net: Currency
    let cpu: Currency
    
    var total: Currency {
        return net + cpu
    }
}
