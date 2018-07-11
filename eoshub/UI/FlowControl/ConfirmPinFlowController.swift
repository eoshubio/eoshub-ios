//
//  ConfirmPinFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 10..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit


class ConfirmPinFlowController: FlowController, ConfirmFlowEventDelegate {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .confirmPin }
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    private var pin: String!
    
    func configure(pin: String) {
        self.pin = pin
    }
    
    func show(animated: Bool) {
        guard let vc = UIStoryboard(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: "PinCodeViewController") as? PinCodeViewController else { preconditionFailure() }
        vc.flowDelegate = self
        vc.configure(mode: .confirm(pin))
        show(viewController: vc, animated: animated) {
            
        }
    }
    
    func confirmed(from nc: UINavigationController) {
        AccountManager.shared.needPinConfirm = false
        AccountManager.shared.pinConfirmed.onNext(())
        
        finish(viewControllerToFinish: nc, animated: true, completion: nil)
//        guard let rootNC = nc.presentingViewController as? UINavigationController else { return }
//        let config = FlowConfigure(container: rootNC, parent: nil, flowType: .navigation)
//        let fc = MainTabFlowController(configure: config)
//        fc.start(animated: false)
//
//
//        nc.dismiss(animated: true) {
//
//        }
    }
}

protocol ConfirmFlowEventDelegate: FlowEventDelegate {
    func confirmed(from nc: UINavigationController)
}
