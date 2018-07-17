//
//  WalletDetailViewController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 12..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class WalletDetailViewController: BaseViewController {
    var flowDelegate: WalletDetailFlowEventDelegate?
    //--account
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
    //--account.e
    @IBOutlet fileprivate weak var resourceView: UIView!
    @IBOutlet fileprivate weak var resCPU: UILabel!
    @IBOutlet fileprivate weak var resNet: UILabel!
    
    @IBOutlet fileprivate weak var ramView: UIView!
    @IBOutlet fileprivate weak var resRam: UILabel!
    
    @IBOutlet fileprivate weak var btnDelegate: UIButton!
    @IBOutlet fileprivate weak var btnUndelegate: UIButton!

    @IBOutlet fileprivate weak var btnBuyRam: UIButton!
    @IBOutlet fileprivate weak var btnSellRam: UIButton!
    
    private var accountInfo: AccountInfo!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showNavigationBar(with: .white)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
    }
    
    private func setupUI() {
        title = accountInfo.account
        
        remainTimeView.layer.cornerRadius = remainTimeView.bounds.height * 0.5
        remainTimeView.layer.masksToBounds = true
        remainTimeView.layer.borderWidth = 1.0
        remainTimeView.layer.borderColor = Color.red.uiColor.cgColor
        
        resourceView.layer.borderColor = Color.seperator.cgColor
        resourceView.layer.borderWidth = 1
        
        ramView.layer.borderColor = Color.seperator.cgColor
        ramView.layer.borderWidth = 1
        
        lbAvailable.text = LocalizedString.Wallet.available
        lbStake.text = LocalizedString.Wallet.staked
        lbRefunding.text = LocalizedString.Wallet.refunding
        
        btnDelegate.setTitle(LocalizedString.Wallet.Delegate.delegate, for: .normal)
        btnUndelegate.setTitle(LocalizedString.Wallet.Delegate.undelegate, for: .normal)
        btnBuyRam.setTitle(LocalizedString.Wallet.Ram.buyram, for: .normal)
        btnSellRam.setTitle(LocalizedString.Wallet.Ram.sellram, for: .normal)
        
        updateAccount(with: accountInfo)
    }
    
    private func bindActions() {
        btnDelegate.rx.singleTap
            .bind { [weak self] in
                guard let nc = self?.navigationController else { return }
                self?.flowDelegate?.goToDelegateBW(from: nc)
            }
            .disposed(by: bag)
        
        btnUndelegate.rx.singleTap
            .bind { [weak self] in
                guard let nc = self?.navigationController else { return }
                self?.flowDelegate?.goToUndelegateBW(from: nc)
            }
            .disposed(by: bag)
        
        btnBuyRam.rx.singleTap
            .bind { [weak self] in
                guard let nc = self?.navigationController else { return }
                self?.flowDelegate?.goToBuyRam(from: nc)
            }
            .disposed(by: bag)
        
        btnSellRam.rx.singleTap
            .bind { [weak self] in
                guard let nc = self?.navigationController else { return }
                self?.flowDelegate?.goToSellRam(from: nc)
            }
            .disposed(by: bag)
        
        AccountManager.shared.accountInfoRefreshed
            .subscribe(onNext: { [weak self](_) in
                guard let account = self?.accountInfo else { return }
                self?.updateAccount(with: account)
            })
            .disposed(by: bag)
        
    }
    
    
    fileprivate func updateAccount(with viewModel: AccountInfo) {
        account.text = viewModel.account
        total.text = viewModel.totalEOS.dot4String
        estimatedPrice.text = ""
        availableEOS.text = viewModel.availableEOS.dot4String
        stakedEOS.text = viewModel.stakedEOS.dot4String
        
        let eosStates: [EOSState] = [.available, .staked, .refunding]
        progress.configure(items: eosStates)
        
        let staked = EOSAmount(id: EOSState.staked.id, value: viewModel.stakedEOS.f)
        let refunding = EOSAmount(id: EOSState.refunding.id, value: viewModel.refundingEOS.f)
        let available = EOSAmount(id: EOSState.available.id, value: viewModel.availableEOS.f)
        
        progress.setProgressValues(values: [available, staked, refunding])
        
        //resources
        resCPU.text = viewModel.cpuStakedEOS.dot4String + " " + .eos
        resNet.text = viewModel.netStakedEOS.dot4String + " " + .eos
        resRam.text = viewModel.ramBytes.prettyPrinted + " Bytes"
        
        //refund
        remainTimeView.isHidden = (viewModel.refundingEOS == 0)
        
        refundingEOS.text = viewModel.refundingEOS.dot4String
        if viewModel.refundRequestTime > 0 {
            refundingEOS.text = viewModel.refundingEOS.dot4String
            
            let remain = viewModel.refundingTime - Date().timeIntervalSince1970
            remainTime.text = remain.stringTime
            
            let _ = Observable<Int>
                .interval(1, scheduler: MainScheduler.instance)
                .subscribe(onNext: { [weak self] (_) in
                    let remain = viewModel.refundingTime - Date().timeIntervalSince1970
                    self?.remainTime.text = remain.stringTime
                })
                .disposed(by: bag)
            
        }
        
    }
    
    func configure(viewModel: AccountInfo) {
        accountInfo = viewModel
    }
    
}


extension WalletDetailViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
