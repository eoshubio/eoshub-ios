//
//  CreateAccountFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 8. 10..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class CreateAccountFlowController: FlowController, CreateAccountFlowEventDelegate {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .createAcc }
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func getRequest() -> CreateAccountRequest {
        let userId = UserManager.shared.userId
        if let request = DB.shared.realm.objects(CreateAccountRequest.self).filter("id BEGINSWITH '\(userId)' AND completed = false").last {
            return request
        } else {
            let request = CreateAccountRequest(userId: userId)
            DB.shared.addCreateAccountRequest(request: request)
            return request
        }
    }
    
    func show(animated: Bool) {
        EHAnalytics.trackScreen(name: id.rawValue, classOfFlow: CreateAccountViewController.self)
        guard let vc = UIStoryboard(name: "Create", bundle: nil).instantiateViewController(withIdentifier: "CreateAccountViewController") as? CreateAccountViewController else { preconditionFailure() }
        vc.flowDelegate = self
        
        let request = getRequest()
        vc.configure(request: request)
        
        show(viewController: vc, animated: animated) {
            
        }
    }
    
    func goInfo(from nc: UINavigationController, request: CreateAccountRequest) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = CreateAccountInfoFlowController(configure: config)
        fc.configure(request: request)
        fc.start(animated: true)
    }
}

protocol CreateAccountFlowEventDelegate: FlowEventDelegate {
    func goInfo(from nc: UINavigationController, request: CreateAccountRequest)
}
