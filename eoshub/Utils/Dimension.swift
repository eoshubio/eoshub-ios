//
//  Dimension.swift
//  eoshub
//
//  Created by kein on 2018. 7. 8..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

enum DisplaySize {
    case size_3_5, size_4_0, size_4_7, size_5_5, size_x, unknown
}

public let screenRatio3_5: CGFloat = 0.85
public let screenRatio4_0: CGFloat = 0.85
public let screenRatio5_5: CGFloat = 1.1

public let screenHeight3_5: CGFloat = 480
public let screenHeight4_0: CGFloat = 568
public let screenHeight4_7: CGFloat = 667
public let screenHeight5_5: CGFloat = 736
public let screenHeightX: CGFloat = 812


public func ptToPx(_ pt: CGFloat) -> CGFloat {
    return pt * getScreenScale()
}

public func ptToPxForXHeight(_ pt: CGFloat) -> CGFloat {
    
    if UIScreen.main.bounds.height == 812 {
        return pt * getScreenScale() * 1.217 // (812/667)
    }
    
    return pt * getScreenScale()
}

func getScreenScale() -> CGFloat {
    switch UIScreen.main.bounds.height {
    case screenHeight3_5:
        return screenRatio4_0
    case screenHeight4_0:
        return screenRatio4_0
    case screenHeight5_5:
        return screenRatio5_5
    default:
        break
    }
    return 1.0
}

func getDisplaySize() -> DisplaySize {
    switch UIScreen.main.bounds.height {
    case screenHeight3_5:
        return .size_3_5
    case screenHeight4_0:
        return .size_4_0
    case screenHeight4_7:
        return .size_4_7
    case screenHeight5_5:
        return .size_5_5
    case screenHeightX:
        return .size_x;
    default:
        return .unknown
    }
}

