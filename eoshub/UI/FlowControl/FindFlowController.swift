//
//  FindFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 10..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class FindFlowController: FlowController {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .findAccount }
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func show(animated: Bool) {
        EHAnalytics.trackScreen(name: id.rawValue, classOfFlow: FindAccountViewController.self)
        guard let vc = UIStoryboard(name: "Create", bundle: nil).instantiateViewController(withIdentifier: "FindAccountViewController") as? FindAccountViewController else { preconditionFailure() }
        //            vc.flowDelegate = self
        show(viewController: vc, animated: animated) {
            
        }
    }
    
    
}
