//
//  AirdropFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 9..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class AirdropFlowController: FlowController {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .airdrop }
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func show(animated: Bool) {
        var vc: AirdropViewController?
        if case FlowType.tab = configure.flowType {
            vc = (configure.container as? TabBarViewController)?.viewControllers.filter({ $0 is AirdropViewController }).first as? AirdropViewController
        } else {
            vc = UIStoryboard(name: "Wallet", bundle: nil).instantiateViewController(withIdentifier: "AirdropViewController") as? AirdropViewController
        }
        
        show(viewController: vc, animated: animated) {
            
        }
    }
    
}
