//
//  RestoreAccountFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 9. 16..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit


class RestoreAccountFlowController: FlowController, PreferAccountFlowEventDelegate {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .restore }
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func show(animated: Bool) {
        EHAnalytics.trackScreen(name: id.rawValue, classOfFlow: RestoreAccountViewController.self)
        guard let vc = UIStoryboard(name: "Create", bundle: nil).instantiateViewController(withIdentifier: "RestoreAccountViewController") as? RestoreAccountViewController else { preconditionFailure() }
        vc.flowDelegate = self
        show(viewController: vc, animated: animated) {
            
        }
    }
    
    
    func returnToMain(from nc: UINavigationController) {
        finish(viewControllerToFinish: nc, animated: true, completion: nil)
    }
}



