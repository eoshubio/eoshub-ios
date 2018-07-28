//
//  LicenseFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 28..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class LicenseFlowController: FlowController {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .license }
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func show(animated: Bool) {
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LicenseViewController") as? LicenseViewController else { preconditionFailure() }
        show(viewController: vc, animated: animated) {
            
        }
    }
    
    
}
