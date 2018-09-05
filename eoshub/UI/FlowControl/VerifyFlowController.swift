//
//  VerifyFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 8. 5..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation

import UIKit

class VerifyFlowController: FlowController, VerifyFlowEventDelegate {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .signinEmail }
    
    fileprivate var viewModel: VerifyViewController.ViewModel!
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func configure(viewModel: VerifyViewController.ViewModel) {
        self.viewModel = viewModel
    }
    
    func show(animated: Bool) {
        EHAnalytics.trackScreen(name: id.rawValue, classOfFlow: VerifyViewController.self)
        guard let vc = UIStoryboard(name: "Intro", bundle: nil).instantiateViewController(withIdentifier: "VerifyViewController") as? VerifyViewController else { preconditionFailure() }
        vc.flowDelegate = self
        vc.configure(viewModel: viewModel)
        show(viewController: vc, animated: animated) {
            
        }
    }
    
    

}

protocol VerifyFlowEventDelegate: FlowEventDelegate {

}
