//
//  TxConfirmFlowController.swift
//  eoshub
//
//  Created by kein on 27/10/2018.
//  Copyright © 2018 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class TxConfirmFlowController: FlowController {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .txConfirm }
    
    fileprivate var contract: Contract!
    fileprivate var title: String?
    fileprivate weak var result: PublishSubject<String>?
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func configure(contract: Contract, title: String?, result: PublishSubject<String>? ) {
        self.contract = contract
        self.title = title
        self.result = result
    }
    
    func show(animated: Bool) {
        EHAnalytics.trackScreen(name: id.rawValue, classOfFlow: TxConfirmFlowController.self)
        guard let vc = UIStoryboard(name: "Wallet", bundle: nil).instantiateViewController(withIdentifier: "TxConfirmViewController") as? TxConfirmViewController else { return }
        vc.configure(contract: contract, title: title, result: result)
        show(viewController: vc, animated: animated) {
            
        }
    }
    
}

