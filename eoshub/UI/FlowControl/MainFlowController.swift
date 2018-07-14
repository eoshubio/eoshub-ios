//
//  MainFlowController.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 17..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation
import UIKit

class MainFlowController: FlowController {
    var configure: FlowConfigure

    var id: FlowIdentifier { return .main }
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func show(animated: Bool) {
        let nc = UINavigationController()
        
        let frame = UIScreen.main.bounds
        
        nc.view.frame = frame
        
        show(viewController: nc, animated: animated) {
            let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
            
            if self.checkValidLoginToken() {
                //1. Go To MainTab
                let fc = MainTabFlowController(configure: config)
                fc.start(animated: false)
            } else {
                //2. Go To Login
                let fc = LoginFlowController(configure: config)
                fc.start(animated: false)
            }
            
            
            

        }
    }
    
    //TODO: Login 토큰 존재 여부 판단.
    private func checkValidLoginToken() -> Bool {
        if DB.shared.getUser(from: .kakao) != nil {
            return true
        }
        return false
    }
    
}
