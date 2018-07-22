//
//  CreateFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 10..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class CreateFlowController: FlowController, CreateFlowEventDelegate {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .create }
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    var items: [CreateViewCellType] = []
    
    func configure(items: [CreateViewCellType]) {
        self.items = items
    }
    
    func show(animated: Bool) {
        
        guard let vc = UIStoryboard(name: "Create", bundle: nil).instantiateViewController(withIdentifier: "CreateViewController") as? CreateViewController else { preconditionFailure() }
        vc.flowDelegate = self
        vc.configure(items: items)
        
        let nc = UINavigationController(rootViewController: vc)
        
        show(viewController: nc, animated: animated) {
            
        }
    }
    
    
    func goCreateAccount(from nc: UINavigationController) {
        
    }
    
    func goImportPrivateKey(from nc: UINavigationController) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = ImportFlowController(configure: config)
        fc.start(animated: true)
    }
    
    func goImportPublicKey(from nc: UINavigationController) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = PreferAccountFlowController(configure: config)
        fc.start(animated: true)
    }
}

protocol CreateFlowEventDelegate: FlowEventDelegate {
    func goCreateAccount(from nc: UINavigationController)
    func goImportPrivateKey(from nc: UINavigationController)
    func goImportPublicKey(from nc: UINavigationController)
}
