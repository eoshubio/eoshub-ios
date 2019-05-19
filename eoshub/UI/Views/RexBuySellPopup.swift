//
//  RexBuySellPopup.swift
//  eoshub
//
//  Created by kein on 19/05/2019.
//  Copyright © 2019 EOS Hub. All rights reserved.
//

import Foundation
import RxSwift

class RexBuySellPopup: CustomPopup {
    enum PopupType {
        case buy, sell
    }
    
    @IBOutlet fileprivate weak var lbAvailableTitle: UILabel!
    @IBOutlet fileprivate weak var lbAvailable: UILabel!
    @IBOutlet fileprivate weak var tfQuantity: UITextField!
    @IBOutlet fileprivate weak var lbSymbol0: UILabel!
    @IBOutlet fileprivate weak var lbSymbol1: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func fillUI(type: PopupType) {
        btnAction?.isEnabled = false
        switch type {
        case .buy:
            lbTitle?.text = "Buy REX"
            btnAction?.setTitle("Buy", for: .normal)
            lbAvailableTitle.text = "EOS Balance"
            lbSymbol0.text = "EOS"
            lbSymbol1.text = "EOS"
        case .sell:
            lbTitle?.text = "Sell REX"
            btnAction?.setTitle("Sell", for: .normal)
            lbAvailableTitle.text = "REX Balance"
            lbSymbol0.text = "REX"
            lbSymbol1.text = "REX"
        }
        
        
    }
    
    func configure(type: PopupType, available: Currency, observer: AnyObserver<Currency>) {
        
        fillUI(type: type)
        
        lbAvailable.text = available.balance
        lbSymbol0.text = available.symbol
        lbSymbol1.text = available.symbol
        
        actionSubject.bind { [weak self] in
            guard let `self` = self else { return }
            guard let eosString = self.tfQuantity.text else { return }
            let eos = Currency(balance: eosString, token: available.token)
            observer.onNext(eos)
            }
            .disposed(by: bag)
        
        tfQuantity.rx.text
            .bind { [weak self](text) in
                if let eosString = text?.plainFormatted {
                    let eos = Currency(balance: eosString, token: available.token)
                    if eos.quantity > available.quantity {
                        self?.tfQuantity.text = available.balance
                    }
                    self?.btnAction?.isEnabled = eos.quantity > 0
                } else {
                    self?.btnAction?.isEnabled = false
                }
            }
            .disposed(by: bag)
        
    }
    
    static func present(type: PopupType, available: Currency, actionObserver: AnyObserver<Currency>) {
        guard let popup = Bundle.main.loadNibNamed("RexBuySellPopup", owner: nil, options: nil)?.first as? RexBuySellPopup else { preconditionFailure() }
        popup.configure(type: type, available: available, observer: actionObserver)
        popup.show()
    }
}
