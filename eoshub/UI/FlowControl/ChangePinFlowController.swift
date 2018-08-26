//
//  ChangePinFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 23..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit


class ChangePinFlowController: FlowController, ChangePinFlowEventDelegate {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .changePin }
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func show(animated: Bool) {
        EHAnalytics.trackScreen(name: id.rawValue, classOfFlow: PinCodeViewController.self)
        guard let vc = UIStoryboard(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: "PinCodeViewController") as? PinCodeViewController else { preconditionFailure() }
        vc.flowDelegate = self
        vc.configure(mode: .change)
        
        let nc = BaseNavigationController(rootViewController: vc)
        
        show(viewController: nc, animated: animated) {
            
        }
    }
    
    func goToCreate(from nc: UINavigationController) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = CreatePinFlowController(configure: config)
        fc.start(animated: true)
    }
}

protocol ChangePinFlowEventDelegate: FlowEventDelegate {
    
    func goToCreate(from nc: UINavigationController)
    
}
