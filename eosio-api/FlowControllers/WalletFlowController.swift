//
//  WalletFlowController.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 18..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation
import UIKit

class WalletFlowController: FlowController {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .wallet }
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func show() {
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WalletViewController") as? WalletViewController else { preconditionFailure() }
        show(viewController: vc, animated: true) {
            
        }
    }
    

    
}


