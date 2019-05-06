//
//  RexFundCell.swift
//  eoshub
//
//  Created by kein on 06/05/2019.
//  Copyright © 2019 EOS Hub. All rights reserved.
//

import Foundation
import RxSwift

class RexFundCell: UITableViewCell {
    @IBOutlet fileprivate weak var lbEOS: UILabel!
    @IBOutlet fileprivate weak var btnDeposit: UIButton!
    @IBOutlet fileprivate weak var btnWithdraw: UIButton!
    
    private var bag: DisposeBag?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = nil
    }
    
    func configure(fund: RexFund, depositObserver: AnyObserver<Void>, withdrawObserver: AnyObserver<Void>) {
        lbEOS.text = fund.balance.balance
        let bag = DisposeBag()
        self.bag = bag
        btnDeposit.rx.singleTap
            .bind(to: depositObserver)
            .disposed(by: bag)
        
        btnWithdraw.rx.singleTap
            .bind(to: withdrawObserver)
            .disposed(by: bag)
    }
}
