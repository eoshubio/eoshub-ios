//
//  CreatePinFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 10..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit


class CreatePinFlowController: FlowController, CreatePinFlowDelegate {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .createPin }
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func show(animated: Bool) {
        
        guard let vc = UIStoryboard(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: "PinCodeViewController") as? PinCodeViewController else { preconditionFailure() }
        vc.flowDelegate = self
        vc.configure(mode: .create)
        
        if case FlowType.navigation = configure.flowType {
            //navigation
            show(viewController: vc, animated: animated) {
                
            }
        } else {
            //modal
            let nc = BaseNavigationController(rootViewController: vc)
            show(viewController: nc, animated: animated) {
                
            }
        }
        
    }
    
    func goToConfirm(from nc: UINavigationController, with pin: String) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = ConfirmPinFlowController(configure: config)
        fc.configure(pin: pin)
        fc.start(animated: true)
    }
}

protocol CreatePinFlowDelegate: FlowEventDelegate {
    
    func goToConfirm(from nc: UINavigationController, with pin: String)
    
}
