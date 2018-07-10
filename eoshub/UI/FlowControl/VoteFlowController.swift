//
//  VoteFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 9..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class VoteFlowController: FlowController {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .vote }
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func show(animated: Bool) {
        var vc: VoteViewController?
        if case FlowType.tab = configure.flowType {
            vc = (configure.container as? TabBarViewController)?.viewControllers.filter({ $0 is VoteViewController }).first as? VoteViewController
        } else {
            vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VoteViewController") as? VoteViewController
        }
        
        //Make Dummy
        var bps: [DummyBPModel] = []
        for i in 0...400 {
            let bp = DummyBPModel(index: i)
            bps.append(bp)
        }
        vc?.configure(viewModel: bps)
        
        show(viewController: vc, animated: animated) {
            
        }
    }
    
}


class DummyBPModel: BPCellViewModel {
    let index: Int
    
    var rank: Int {
        return index + 1
    }
    
    var selected: Bool = false
    
    var name: String { return "eoshubbp\(index)" }
    
    var url: String { return "https://eos-hob.io" }
    
    var votedPercent: Double = 2.809
    
    init(index: Int) {
        self.index = index
    }
}
