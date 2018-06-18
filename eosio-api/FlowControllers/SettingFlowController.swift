//
//  SettingFlowController.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 18..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation
import UIKit

class SettingFlowController: FlowController {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .setting }
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func show() {
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingViewController") as? SettingViewController else { preconditionFailure() }
        
        show(viewController: vc, animated: true) {
            
        }
    }
}

