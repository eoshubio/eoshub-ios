//
//  ForgetPWFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 8. 5..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class ForgetPWFlowController: FlowController, FlowEventDelegate {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .forgetPW }
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func show(animated: Bool) {
        EHAnalytics.trackScreen(name: id.rawValue, classOfFlow: ForgotPWViewController.self)
        guard let vc = UIStoryboard(name: "Intro", bundle: nil).instantiateViewController(withIdentifier: "ForgotPWViewController") as? ForgotPWViewController else { preconditionFailure() }
        vc.flowDelegate = self
        show(viewController: vc, animated: animated) {
            
        }
    }
}

