//
//  CreateAccountInvoiceFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 8. 11..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class CreateAccountInvoiceFlowController: FlowController, FlowEventDelegate {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .getTxCode }
    
    fileprivate var request: CreateAccountRequest!
    
    func configure(request: CreateAccountRequest) {
        self.request = request
    }
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func show(animated: Bool) {
        
        guard let vc = UIStoryboard(name: "Create", bundle: nil).instantiateViewController(withIdentifier: "CreateAccountInvoiceViewController") as? CreateAccountInvoiceViewController else { preconditionFailure() }
        
        vc.configure(request: request)
        vc.flowDelegate = self
        show(viewController: vc, animated: animated) {
            
        }
    }

}



