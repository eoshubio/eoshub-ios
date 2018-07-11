//
//  StakeProgressBar.swift
//  eoshub
//
//  Created by kein on 2018. 7. 12..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

enum EOSState: Int, ProgressItem {
    case available, staked, refunding
    
    var id: Int {
        return rawValue
    }
    
    var fillColor: UIColor {
        switch self {
        case .staked:
            return Color.blue.uiColor
        case .refunding:
            return Color.red.uiColor
        case .available:
            return Color.green.uiColor
        }
    }
}

struct EOSAmount: ProgressValue {
    let id: Int
    let value: Float
}

