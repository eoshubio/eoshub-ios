//
//  RexUnstakeResPopup.swift
//  eoshub
//
//  Created by kein on 19/05/2019.
//  Copyright © 2019 EOS Hub. All rights reserved.
//

import Foundation
import RxSwift

class RexUnstakeResPopup: CustomPopup {
    @IBOutlet fileprivate weak var lbCPU: UILabel!
    @IBOutlet fileprivate weak var tfCPU: UITextField!
    @IBOutlet fileprivate weak var lbNET: UILabel!
    @IBOutlet fileprivate weak var tfNET: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    func configure(account: AccountInfo, observer: AnyObserver<(cpu: Currency, net: Currency)>) {
        
        lbCPU.text = account.cpuStakedEOS.dot4String + " EOS"
        lbNET.text = account.netStakedEOS.dot4String + " EOS"
        
        
        actionSubject.bind { [weak self] in
                guard let `self` = self else { return }
                let cpuString = self.tfCPU.text ?? "0.0000"
                let netString = self.tfNET.text ?? "0.0000"
                let cpu = Currency(balance: cpuString, token: .eos)
                let net = Currency(balance: netString, token: .eos)
                observer.onNext((cpu: cpu,net: net))
            }
            .disposed(by: bag)
        
        
    }
    
    static func present(account: AccountInfo, observer: AnyObserver<(cpu: Currency, net: Currency)>) {
        guard let popup = Bundle.main.loadNibNamed("RexUnstakeResPopup", owner: nil, options: nil)?.first as? RexUnstakeResPopup else { preconditionFailure() }
        popup.configure(account: account, observer: observer)
        popup.show()
    }
}
