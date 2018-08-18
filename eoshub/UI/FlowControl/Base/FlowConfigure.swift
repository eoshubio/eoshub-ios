//
//  FlowConfigure.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 17..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation
import UIKit

enum FlowType {
    case window
    case navigation
    case modal
    case tab(Int)
}


struct FlowConfigure {
    let container: UIAppearanceContainer
    let parent: FlowController?
    let flowType: FlowType
    
    init(container: UIAppearanceContainer, parent: FlowController?, flowType: FlowType) {
        self.container = container
        self.parent = parent
        self.flowType = flowType
    }
}
