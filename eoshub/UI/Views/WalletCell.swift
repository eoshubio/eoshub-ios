//
//  WalletCell.swift
//  eoshub
//
//  Created by kein on 2018. 7. 9..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class WalletCell: UITableViewCell {
    
    @IBOutlet fileprivate weak var account: UILabel!
    
    @IBOutlet fileprivate weak var total: UILabel!
    
    @IBOutlet fileprivate weak var estimatedPrice: UILabel!
    
    @IBOutlet fileprivate weak var progress: MultiProgressBar!
    
    @IBOutlet fileprivate weak var lbAvailable: UILabel!
    
    @IBOutlet fileprivate weak var availableEOS: UILabel!
    
    @IBOutlet fileprivate weak var lbStake: UILabel!
    
    @IBOutlet fileprivate weak var stakedEOS: UILabel!
    
    @IBOutlet fileprivate weak var lbRefunding: UILabel!
    
    @IBOutlet fileprivate weak var refundingEOS: UILabel!
    
    @IBOutlet fileprivate weak var remainTimeView: UIView!
    
    @IBOutlet fileprivate weak var remainTime: UILabel!
    
    @IBOutlet fileprivate weak var layoutContainerY: NSLayoutConstraint!
    
    @IBOutlet fileprivate weak var buttonContainer: UIView!
    
    @IBOutlet fileprivate weak var btnSend: UIButton!
    
    @IBOutlet fileprivate weak var btnReceive: UIButton!
    
    private var bag: DisposeBag? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = nil
    }
    
    deinit {
        bag = nil
        NSLog("deinit")
    }
    
    private func setupUI() {
        remainTimeView.layer.cornerRadius = remainTimeView.bounds.height * 0.5
        remainTimeView.layer.masksToBounds = true
        remainTimeView.layer.borderWidth = 1.0
        remainTimeView.layer.borderColor = Color.red.uiColor.cgColor
        
        lbAvailable.text = LocalizedString.Wallet.available
        lbStake.text = LocalizedString.Wallet.staked
        lbRefunding.text = LocalizedString.Wallet.refunding
        btnSend.setTitle(LocalizedString.Wallet.send, for: .normal)
        btnReceive.setTitle(LocalizedString.Wallet.receive, for: .normal)
        
        let eosStates: [EOSState] = [.available, .staked, .refunding]
        
        progress.configure(items: eosStates)
    }
    
    
    func configure(viewModel: EOSWalletViewModel,
                   sendObserver: PublishSubject<EOSWalletViewModel>,
                   receiveObserver: PublishSubject<EOSWalletViewModel>) {
        
        let bag = DisposeBag()
        
        account.text = viewModel.account
        total.text = viewModel.totalEOS.dot4String
        estimatedPrice.text = "= " + viewModel.estimatedPrice
        availableEOS.text = viewModel.availableEOS.dot4String
        stakedEOS.text = viewModel.stakedEOS.dot4String
        refundingEOS.text = viewModel.refundingEOS.dot4String
        remainTime.text = viewModel.refundingRemainTime
        
        if viewModel.showSendButton == false {
            buttonContainer.isHidden = true
            layoutContainerY.constant = -buttonContainer.bounds.height
            layoutIfNeeded()
        }
        
        let staked = EOSAmount(id: EOSState.staked.id, value: viewModel.stakedEOS.f)
        let refunding = EOSAmount(id: EOSState.refunding.id, value: viewModel.refundingEOS.f)
        let available = EOSAmount(id: EOSState.available.id, value: viewModel.availableEOS.f)
        
        progress.setProgressValues(values: [available, staked, refunding])
        
        btnSend.rx.singleTap
            .bind {
                sendObserver.onNext(viewModel)
            }
            .disposed(by: bag)
        
        btnReceive.rx.singleTap
            .bind {
                receiveObserver.onNext(viewModel)
            }
            .disposed(by: bag)
        
        self.bag = bag
        
    }

}
