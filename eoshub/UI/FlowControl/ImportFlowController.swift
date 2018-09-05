//
//  ImportFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 10..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit


class ImportFlowController: FlowController, ImportFlowEventDelegate {
        var configure: FlowConfigure
        
        var id: FlowIdentifier { return .importPri }
        
        required init(configure: FlowConfigure) {
            self.configure = configure
        }
    
        func show(animated: Bool) {
            EHAnalytics.trackScreen(name: id.rawValue, classOfFlow: ImportViewController.self)
            guard let vc = UIStoryboard(name: "Create", bundle: nil).instantiateViewController(withIdentifier: "ImportViewController") as? ImportViewController else { preconditionFailure() }
            vc.flowDelegate = self
            show(viewController: vc, animated: animated) {
                
            }
        }
        
    func goFindAccount(from nc: UINavigationController) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = FindFlowController(configure: config)
        fc.start(animated: true)
    }
    
    func returnToMain(from nc: UINavigationController) {
       finish(viewControllerToFinish: nc, animated: true, completion: nil)
    }
}


protocol ImportFlowEventDelegate: FlowEventDelegate {
    func goFindAccount(from nc: UINavigationController)
    func returnToMain(from nc: UINavigationController)
}
