//
//  BPInfo.swift
//  eoshub
//
//  Created by kein on 2018. 7. 14..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation

class BPInfo: BPCellViewModel {
    let index: Int
    
    var selected: Bool = false
    
    let name: String
    
    let url: String
    
    var votesRatio: Double
    
    let isActive: Bool
    
    
    init(bp: BlockProducer) {
        index = bp.index
        name = bp.owner
        url = bp.url
        votesRatio = bp.ratio
        isActive = bp.isActive
    
    }
}
