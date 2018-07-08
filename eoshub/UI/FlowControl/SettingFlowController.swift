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
        guard let vc = UIStoryboard(name: "Wallet", bundle: nil).instantiateViewController(withIdentifier: "SettingViewController") as? SettingViewController else { preconditionFailure() }
        vc.flowDelegate = self
        show(viewController: vc, animated: animated) {
            
        }
    }
    
    
    //MARK: SettingFlowEventDelegate
    func goToSetting(from nc: UINavigationController) {
        
    }
    
    func goToWalletDetail(from nc: UINavigationController) {
        
    }
}

protocol SettingFlowEventDelegate: FlowEventDelegate {
    
}
