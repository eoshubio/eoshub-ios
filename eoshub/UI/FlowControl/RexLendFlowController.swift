//
//  RexLendFlowController.swift
//  eoshub
//
//  Created by kein on 06/05/2019.
//  Copyright © 2019 EOS Hub. All rights reserved.
//

import Foundation

class RexLendFlowController: FlowController {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .rexLend }
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func show(animated: Bool) {
        
        EHAnalytics.trackScreen(name: id.rawValue, classOfFlow: RexLendViewController.self)
        guard let vc = UIStoryboard(name: "Rex", bundle: nil).instantiateViewController(withIdentifier: "RexLendViewController") as? RexLendViewController else { preconditionFailure() }
        show(viewController: vc, animated: animated) {
            
        }
    }
    
}

