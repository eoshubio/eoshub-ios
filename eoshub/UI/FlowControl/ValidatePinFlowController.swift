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

class ValidatePinFlowController: FlowController, ValidatePinFlowDelegate {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .validatePin }
    
    var validated = PublishSubject<Bool>()
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func show(animated: Bool) {
        
        guard let vc = UIStoryboard(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: "PinCodeViewController") as? PinCodeViewController else { preconditionFailure() }
        vc.flowDelegate = self
        vc.configure(mode: .validation)
        
        let nc = UINavigationController(rootViewController: vc)
        
        show(viewController: nc, animated: animated) {
            
        }
    }
    
    
    func validated(from nc: UINavigationController) {
        AccountManager.shared.needPinConfirm = false
        AccountManager.shared.pinValidated.onNext(())
        
        validated.onNext(true)
        
        finish(viewControllerToFinish: nc, animated: true, completion: nil)
    }
}

protocol ValidatePinFlowDelegate: FlowEventDelegate {
    
    func validated(from nc: UINavigationController)
    
}
