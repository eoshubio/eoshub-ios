//
//  Array+extension.swift
//  eoshub
//
//  Created by kein on 2018. 7. 29..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

extension Array where Element : Equatable {
    var unique: [Element] {
        var uniqueValues: [Element] = []
        forEach { item in
            if !uniqueValues.contains(item) {
                uniqueValues += [item]
            }
        }
        return uniqueValues
    }
}
