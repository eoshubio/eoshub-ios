//
//  RexBorrowPopup.swift
//  eoshub
//
//  Created by kein on 20/05/2019.
//  Copyright © 2019 EOS Hub. All rights reserved.
//

import Foundation
import RxSwift

class RexBorrowPopup: CustomPopup {
    enum PopupType {
        case cpu, net
    }
    
    @IBOutlet fileprivate weak var lbAvailable: UILabel!
    @IBOutlet fileprivate weak var icon: UIImageView!
    @IBOutlet fileprivate weak var tfPayment: UITextField!
    @IBOutlet fileprivate weak var tfFund: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func fillUI(type: PopupType) {
        btnAction?.setTitle("Borrow", for: .normal)
        switch type {
        case .cpu:
            lbTitle?.text = "Borrow CPU"
            icon.image = UIImage(named: "cpu")
        case .net:
            lbTitle?.text = "Borrow NET"
            icon.image = UIImage(named: "net")
        }
        
        
    }
    
    func configure(type: PopupType, rexInfo: RexInfo, observer: AnyObserver<(payment: Currency, fund: Currency)>) {
        
        fillUI(type: type)
        
        lbAvailable.text = rexInfo.fund.balance.stringValue
        
        actionSubject.bind { [weak self] in
                guard let `self` = self else { return }
                guard let eosString = self.tfPayment.text else { return }
                let fundString = self.tfFund.text ?? "0.0000"
                let eos = Currency(balance: eosString, token: .eos)
                let fund = Currency(balance: fundString, token: .eos)
                observer.onNext((payment: eos, fund: fund))
            }
            .disposed(by: bag)
        
    }
    
    static func present(type: PopupType, rexInfo: RexInfo, actionObserver: AnyObserver<(payment: Currency, fund: Currency)>) {
        guard let popup = Bundle.main.loadNibNamed("RexBorrowPopup", owner: nil, options: nil)?.first as? RexBorrowPopup else { preconditionFailure() }
        popup.configure(type: type, rexInfo: rexInfo, observer: actionObserver)
        popup.show()
    }
}
