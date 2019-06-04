//
//  RexBorrowFlowController.swift
//  eoshub
//
//  Created by kein on 06/05/2019.
//  Copyright © 2019 EOS Hub. All rights reserved.
//

import Foundation

class RexBorrowFlowController: FlowController {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .rexBorrow }
    
    fileprivate var account: AccountInfo!
    fileprivate var rexInfo: RexInfoSubject!
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func configure(account: AccountInfo, rexInfo: RexInfoSubject) {
        self.account = account
        self.rexInfo = rexInfo
    }
    
    func show(animated: Bool) {
        
        EHAnalytics.trackScreen(name: id.rawValue, classOfFlow: RexBorrowFlowController.self)
        guard let vc = UIStoryboard(name: "Rex", bundle: nil).instantiateViewController(withIdentifier: "RexBorrowViewController") as? RexBorrowViewController else { preconditionFailure() }
        vc.configure(account: account, rexInfo: rexInfo)
        show(viewController: vc, animated: animated) {
            
        }
    }
    
}
