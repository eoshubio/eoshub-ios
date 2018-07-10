//
//  ConfirmPinFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 10..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit


class ConfirmPinFlowController: FlowController {
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
        //            vc.flowDelegate = self
        vc.configure(mode: .confirm(pin))
        show(viewController: vc, animated: animated) {
            
        }
    }
    
}
