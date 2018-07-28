//
//  SettingFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 8..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class SettingFlowController: FlowController, SettingFlowEventDelegate {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .setting }
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func show(animated: Bool) {
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingViewController") as? SettingViewController else { preconditionFailure() }
        vc.flowDelegate = self
        show(viewController: vc, animated: animated) {
            
        }
    }
    
    
    //MARK: SettingFlowEventDelegate
    func goToLicense(from nc: UINavigationController) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = LicenseFlowController(configure: config)
        fc.start(animated: true)
    }
    
    func goToChangePin(from nc: UINavigationController) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .modal)
        let fc = ChangePinFlowController(configure: config)
        fc.start(animated: true)
    }
    
    
}

protocol SettingFlowEventDelegate: FlowEventDelegate {
    func goToChangePin(from nc: UINavigationController)
    func goToLicense(from nc: UINavigationController)
}
