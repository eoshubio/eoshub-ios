//
//  PreferAccountFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 22..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit


class PreferAccountFlowController: FlowController, PreferAccountFlowEventDelegate {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .importPub }
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func show(animated: Bool) {
        EHAnalytics.trackScreen(name: id.rawValue, classOfFlow: PreferAccountViewController.self)
        guard let vc = UIStoryboard(name: "Create", bundle: nil).instantiateViewController(withIdentifier: "PreferAccountViewController") as? PreferAccountViewController else { preconditionFailure() }
        vc.flowDelegate = self
        show(viewController: vc, animated: animated) {
            
        }
    }

    
    func returnToMain(from nc: UINavigationController) {
        finish(viewControllerToFinish: nc, animated: true, completion: nil)
    }
}


protocol PreferAccountFlowEventDelegate: FlowEventDelegate {
    func returnToMain(from nc: UINavigationController)
}

