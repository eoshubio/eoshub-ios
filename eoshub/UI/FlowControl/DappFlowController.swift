//
//  DappFlowController.swift
//  eoshub
//
//  Created by kein on 23/10/2018.
//  Copyright © 2018 EOS Hub. All rights reserved.
//

import Foundation
import UIKit


class DappFlowController: FlowController, DappFlowEventDelegate {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .dapp }
   
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
 
    
    func show(animated: Bool) {
        EHAnalytics.trackScreen(name: id.rawValue, classOfFlow: DappFlowController.self)
        guard let vc = UIStoryboard(name: "Dapp", bundle: nil).instantiateViewController(withIdentifier: "DappViewController") as? DappViewController else { return }
        vc.flowDelegate = self
        show(viewController: vc, animated: animated) {
            
        }
    }
}

protocol DappFlowEventDelegate: FlowEventDelegate {
   
}

