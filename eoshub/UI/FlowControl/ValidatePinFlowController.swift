//
//  ValidatePinFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 13..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import LocalAuthentication

class ValidatePinFlowController: FlowController, ValidatePinFlowDelegate {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .validatePin }
    
    var validated = PublishSubject<Bool>()
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func show(animated: Bool) {
        
        if Security.shared.enableBioAuth && Security.shared.biometryType() != .none {
            guard let vc = UIStoryboard(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: "TouchIdViewController") as? TouchIdViewController else { preconditionFailure() }
            vc.flowDelegate = self
            let nc = BaseNavigationController(rootViewController: vc)
            show(viewController: nc, animated: animated) {
                
            }
        } else {
            guard let vc = UIStoryboard(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: "PinCodeViewController") as? PinCodeViewController else { preconditionFailure() }
            vc.flowDelegate = self
            vc.configure(mode: .validation)
            
            let nc = BaseNavigationController(rootViewController: vc)
            
            show(viewController: nc, animated: animated) {
                
            }
        }
       
    }
    
    
    func validated(from nc: UINavigationController) {
        Security.shared.needAuthentication = false
        Security.shared.authorized.onNext(true)
        validated.onNext(true)
        validated.onCompleted()
        finish(viewControllerToFinish: nc, animated: true, completion: nil)
        
    }
    
    func cancelled(from nc: UINavigationController) {
        Security.shared.authorized.onNext(false)
        validated.onNext(false)
        validated.onCompleted()
        finish(viewControllerToFinish: nc, animated: true, completion: nil)
    }
}

protocol ValidatePinFlowDelegate: FlowEventDelegate {
    
    func validated(from nc: UINavigationController)
    func cancelled(from nc: UINavigationController)
    
}
