//
//  CreateAccountFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 8. 10..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class CreateAccountFlowController: FlowController, CreateAccountFlowEventDelegate {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .createAcc }
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func show(animated: Bool) {
        
        guard let vc = UIStoryboard(name: "Create", bundle: nil).instantiateViewController(withIdentifier: "CreateAccountViewController") as? CreateAccountViewController else { preconditionFailure() }
        vc.flowDelegate = self
        
        show(viewController: vc, animated: animated) {
            
        }
    }
    
    func goInfo(from nc: UINavigationController) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = CreateAccountInfoFlowController(configure: config)
        fc.start(animated: true)
    }
}

protocol CreateAccountFlowEventDelegate: FlowEventDelegate {
    func goInfo(from nc: UINavigationController)
}
