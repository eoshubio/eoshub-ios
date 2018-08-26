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
    
    var verifyViewModel: VerifyViewController.ViewModel?
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func configure(verifyViewModel: VerifyViewController.ViewModel) {
        self.verifyViewModel = verifyViewModel
    }
    
    func show(animated: Bool) {
        EHAnalytics.trackScreen(name: id.rawValue, classOfFlow: TermViewController.self)
        guard let vc = UIStoryboard(name: "Intro", bundle: nil).instantiateViewController(withIdentifier: "TermViewController") as? TermViewController else { preconditionFailure() }
        vc.flowDelegate = self
        show(viewController: vc, animated: animated) {

        }
    }
    
    //MARK: TermFlowEventDelegate
    func goToNext(from nc: UINavigationController) {
        if let parent = configure.parent?.id, parent == .signinEmail {
            let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
            let fc = VerifyFlowController(configure: config)
            if let viewModel = verifyViewModel {
                fc.configure(viewModel: viewModel)
            }
            fc.start(animated: true)
            nc.viewControllers = nc.viewControllers.filter({ ($0 is TermViewController) == false })
            
        } else {
            let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
            let fc = WalletFlowController(configure: config)
            fc.start(animated: true)
        }
    }
}

protocol TermFlowEventDelegate: FlowEventDelegate {
    func goToNext(from nc: UINavigationController)
}


