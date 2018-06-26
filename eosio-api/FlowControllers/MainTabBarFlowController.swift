//
//  MainTabBarFlowController.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 21..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation
import UIKit

class MainTabBarFlowController: FlowController, MainTabbarFlowEventDelegate {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .mainTabbar }
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func show() {
        
        
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainTabBarViewController") as? MainTabBarViewController else { preconditionFailure() }
        vc.flowDelegate = self
        show(viewController: vc, animated: true) {
            
        }
    }
    
    func goToSetting(nc: UINavigationController) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = SettingFlowController(configure: config)
        fc.start()
    }
}


protocol MainTabbarFlowEventDelegate: FlowEventDelegate {
    func goToSetting(nc: UINavigationController)
}
