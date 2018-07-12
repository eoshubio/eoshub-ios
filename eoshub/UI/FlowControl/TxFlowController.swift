//
//  TxFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 13..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class TxFlowController: FlowController {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .tx }
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    

    func show(animated: Bool) {
        
        guard let vc = UIStoryboard(name: "Wallet", bundle: nil).instantiateViewController(withIdentifier: "TxViewController") as? TxViewController else { return }
        //        vc.flowDelegate = self
//        vc.configure(account: account)
        show(viewController: vc, animated: animated) {
            
        }
    }
    
}



