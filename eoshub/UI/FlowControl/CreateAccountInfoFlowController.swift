//
//  CreateAccountInfoFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 8. 11..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class CreateAccountInfoFlowController: FlowController, CreateAccountInfoFlowEventDelegate {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .createAccInfo }
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func show(animated: Bool) {
        
        guard let vc = UIStoryboard(name: "Create", bundle: nil).instantiateViewController(withIdentifier: "CreateAccountInfoViewController") as? CreateAccountInfoViewController else { preconditionFailure() }
        vc.flowDelegate = self
        
        show(viewController: vc, animated: animated) {
            
        }
    }
    
    func goGetCode(from nc: UINavigationController) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = CreateAccountInvoiceFlowController(configure: config)
        fc.start(animated: true)
    }
}

protocol CreateAccountInfoFlowEventDelegate: FlowEventDelegate {
    func goGetCode(from nc: UINavigationController)
}
