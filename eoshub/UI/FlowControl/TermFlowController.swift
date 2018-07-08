//
//  TermFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 8..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class TermFlowController: FlowController, TermFlowEventDelegate {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .term }
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func show(animated: Bool) {
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TermViewController") as? TermViewController else { preconditionFailure() }
        vc.flowDelegate = self
        show(viewController: vc, animated: animated) {

        }
    }
    
    //MARK: TermFlowEventDelegate
    func goToWallet(from nc: UINavigationController) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = WalletFlowController(configure: config)
        fc.start(animated: true)
    }
}

protocol TermFlowEventDelegate: FlowEventDelegate {

    func goToWallet(from nc: UINavigationController)
}


