//
//  DepositPopup.swift
//  eoshub
//
//  Created by kein on 06/05/2019.
//  Copyright © 2019 EOS Hub. All rights reserved.
//

import Foundation
import RxSwift

class DepositPopup: CustomPopup {
    enum PopupType {
        case deposit, withdraw
    }
    
    @IBOutlet fileprivate weak var lbAvailableTitle: UILabel!
    @IBOutlet fileprivate weak var lbAvailableEOS: UILabel!
    @IBOutlet fileprivate weak var tfDepositEOS: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func fillUI(type: PopupType) {
        btnAction?.isEnabled = false
        switch type {
        case .deposit:
            lbTitle?.text = "Deposit REX Fund"
            btnAction?.setTitle("Deposit", for: .normal)
            lbAvailableTitle.text = "EOS Balance"
        case .withdraw:
            lbTitle?.text = "Withdraw REX Fund"
            btnAction?.setTitle("Withdraw", for: .normal)
            lbAvailableTitle.text = "REX Fund"
        }
        
        
    }
    
    func configure(type: PopupType, availableEOS: Currency, observer: AnyObserver<Currency>) {
        
        fillUI(type: type)
        
        lbAvailableEOS.text = availableEOS.balance
        
        actionSubject.bind { [weak self] in
            guard let `self` = self else { return }
            guard let eosString = self.tfDepositEOS.text else { return }
            let eos = Currency(balance: eosString, token: .eos)
            observer.onNext(eos)
        }
        .disposed(by: bag)
        
        tfDepositEOS.rx.text
            .bind { [weak self](text) in
                if let eosString = text?.plainFormatted {
                    let eos = Currency(balance: eosString, token: .eos)
                    if eos.quantity > availableEOS.quantity {
                        self?.tfDepositEOS.text = availableEOS.balance
                    }
                    self?.btnAction?.isEnabled = eos.quantity > 0
                } else {
                    self?.btnAction?.isEnabled = false
                }
            }
            .disposed(by: bag)
        
    }
    
    static func present(type: PopupType, availableEOS: Currency, actionObserver: AnyObserver<Currency>) {
        guard let popup = Bundle.main.loadNibNamed("DepositPopup", owner: nil, options: nil)?.first as? DepositPopup else { preconditionFailure() }
        popup.configure(type: type, availableEOS: availableEOS, observer: actionObserver)
        popup.show()
    }
}
