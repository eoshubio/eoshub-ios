//
//  SigninFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 8. 5..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation

import UIKit

class SigninEmailFlowController: FlowController, SigninEmailFlowEventDelegate {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .signinEmail }
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func show(animated: Bool) {
        guard let vc = UIStoryboard(name: "Intro", bundle: nil).instantiateViewController(withIdentifier: "SigninViewController") as? SigninViewController else { preconditionFailure() }
        vc.flowDelegate = self
        show(viewController: vc, animated: animated) {
            
        }
    }
    
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
    
    func goToVerifyEmail(from nc: UINavigationController, email: String) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = VerifyFlowController(configure: config)
        fc.configure(email: email)
        fc.start(animated: true)
    }
    
    func goToForgotPW(from nc: UINavigationController) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = ForgetPWFlowController(configure: config)
        fc.start(animated: true)
    }
}

protocol SigninEmailFlowEventDelegate: FlowEventDelegate {
    func goToTerm(from nc: UINavigationController)
    func goToMain(from nc: UINavigationController)
    func goToVerifyEmail(from nc: UINavigationController, email: String)
    func goToForgotPW(from nc: UINavigationController)
}


