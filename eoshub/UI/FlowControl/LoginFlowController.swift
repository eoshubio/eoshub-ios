//
//  LoginFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 8..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class LoginFlowController: FlowController, LoginFlowEventDelegate {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .login }
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func show(animated: Bool) {
        guard let vc = UIStoryboard(name: "Intro", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else { preconditionFailure() }
        vc.flowDelegate = self
        show(viewController: vc, animated: animated) {
            
        }
    }
    
    
    //MARK: LoginFlowEventDelegate
    func goToTerm(from nc: UINavigationController) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = TermFlowController(configure: config)
        fc.start(animated: true)
    }
    
    func goToMain(from nc: UINavigationController) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = MainTabFlowController(configure: config)
        fc.start(animated: true)
    }
}

protocol LoginFlowEventDelegate: FlowEventDelegate {
    
    func goToTerm(from nc: UINavigationController)
    func goToMain(from nc: UINavigationController)
    
}
