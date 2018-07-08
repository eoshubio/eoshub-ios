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
            vc = UIStoryboard(name: "Wallet", bundle: nil).instantiateViewController(withIdentifier: "VoteViewController") as? VoteViewController
        }
        
        show(viewController: vc, animated: animated) {
            
        }
    }
    
}

