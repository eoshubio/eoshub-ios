//
//  ConfirmPinFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 10..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import LocalAuthentication

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
        EHAnalytics.trackScreen(name: id.rawValue, classOfFlow: PinCodeViewController.self)
        guard let vc = UIStoryboard(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: "PinCodeViewController") as? PinCodeViewController else { preconditionFailure() }
        vc.flowDelegate = self
        vc.configure(mode: .confirm(pin))
        show(viewController: vc, animated: animated) {
            
        }
    }
    
    func confirmed(from nc: UINavigationController) {
        
        //Set PIN to keychain with Encryption
        Security.shared.setPin(pin: pin)
  
        Security.shared.needAuthentication = false
        Security.shared.authorized.onNext(true)
        finish(viewControllerToFinish: nc, animated: true, completion: nil)
        
    }
}

protocol ConfirmFlowEventDelegate: FlowEventDelegate {
    func confirmed(from nc: UINavigationController)
}
