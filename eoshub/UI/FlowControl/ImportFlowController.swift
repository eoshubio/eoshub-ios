//
//  ImportFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 10..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit


class ImportFlowController: FlowController {
        var configure: FlowConfigure
        
        var id: FlowIdentifier { return .importPri }
        
        required init(configure: FlowConfigure) {
            self.configure = configure
        }
    
        func show(animated: Bool) {
            guard let vc = UIStoryboard(name: "Create", bundle: nil).instantiateViewController(withIdentifier: "ImportViewController") as? ImportViewController else { preconditionFailure() }
//            vc.flowDelegate = self
            show(viewController: vc, animated: animated) {
                
            }
        }
        

}

