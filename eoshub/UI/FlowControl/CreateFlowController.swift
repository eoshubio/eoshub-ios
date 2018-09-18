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
    
    private func getRequest() -> CreateAccountRequest {
        let userId = UserManager.shared.userId
        if let request = DB.shared.realm.objects(CreateAccountRequest.self).filter("id BEGINSWITH '\(userId)' AND completed = false").last {
            return request
        } else {
            let request = CreateAccountRequest(userId: userId)
            DB.shared.addCreateAccountRequest(request: request)
            return request
        }
    }
    
    func configure(items: [CreateViewCellType]) {
        self.items = items
    }
    
    func show(animated: Bool) {
        EHAnalytics.trackScreen(name: id.rawValue, classOfFlow: CreateViewController.self)
        guard let vc = UIStoryboard(name: "Create", bundle: nil).instantiateViewController(withIdentifier: "CreateViewController") as? CreateViewController else { preconditionFailure() }
        vc.flowDelegate = self
        vc.configure(items: items)
        
        let nc = BaseNavigationController(rootViewController: vc)
        
        show(viewController: nc, animated: animated) {
            
        }
    }
    
    
    func goCreateAccount(from nc: UINavigationController) {
        
        let request = getRequest()
        
        
        if request.currentStage == .invoice {
            let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
            let fc = CreateAccountFlowController(configure: config)
            fc.start(animated: true)
            
            let invoiceConfig = FlowConfigure(container: nc, parent: fc, flowType: .navigation)
            let invoiceFC = CreateAccountInvoiceFlowController(configure: invoiceConfig)
            invoiceFC.configure(request: request)
            invoiceFC.start(animated: true)
            
        } else {
            let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
            let fc = CreateAccountFlowController(configure: config)
            fc.start(animated: true)
        }
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
    
    func goToRestore(from nc: UINavigationController) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = RestoreAccountFlowController(configure: config)
        fc.start(animated: true)
    }
}

protocol CreateFlowEventDelegate: FlowEventDelegate {
    func goCreateAccount(from nc: UINavigationController)
    func goImportPrivateKey(from nc: UINavigationController)
    func goImportPublicKey(from nc: UINavigationController)
    func goToRestore(from nc: UINavigationController)
}
