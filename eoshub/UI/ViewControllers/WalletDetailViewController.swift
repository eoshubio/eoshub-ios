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
    
    @IBOutlet fileprivate weak var scrollView: UIScrollView!
    
    
    @IBOutlet fileprivate weak var resourceView: UIView!

    @IBOutlet fileprivate weak var resCPU: UILabel!
    @IBOutlet fileprivate weak var resUsedCPU: UILabel!
    @IBOutlet fileprivate weak var resUsedCPUPercent: UILabel!
    @IBOutlet fileprivate weak var progCPU: UIProgressView!
    
    @IBOutlet fileprivate weak var resNet: UILabel!
    @IBOutlet fileprivate weak var resUsedNet: UILabel!
    @IBOutlet fileprivate weak var resUsedNetPercent: UILabel!
    @IBOutlet fileprivate weak var progNet: UIProgressView!

    @IBOutlet fileprivate weak var ramView: UIView!
    @IBOutlet fileprivate weak var resRam: UILabel!
    @IBOutlet fileprivate weak var resUsedRamPercent: UILabel!
    @IBOutlet fileprivate weak var progRam: UIProgressView!
    
    @IBOutlet fileprivate weak var btnDelegate: UIButton!
    @IBOutlet fileprivate weak var btnUndelegate: UIButton!

    @IBOutlet fileprivate weak var btnBuyRam: UIButton!
    @IBOutlet fileprivate weak var btnSellRam: UIButton!
    
    @IBOutlet fileprivate weak var layoutResY: NSLayoutConstraint!
    @IBOutlet fileprivate weak var layoutRAMY: NSLayoutConstraint!
    
    @IBOutlet fileprivate weak var deleteView: UIView!
    @IBOutlet fileprivate weak var btnDelete: UIButton!
    
    private var accountInfo: AccountInfo!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        showNavigationBar(with: .basePurple, animated: false, largeTitle: true)
        
        title = LocalizedString.Wallet.resources
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
    }
    
    private func setupUI() {
        
        scrollView.delegate = self
        
        remainTimeView.layer.cornerRadius = remainTimeView.bounds.height * 0.5
        remainTimeView.layer.masksToBounds = true
        remainTimeView.layer.borderWidth = 1.0
        remainTimeView.layer.borderColor = Color.red.uiColor.cgColor
        
     
        
        lbAvailable.text = LocalizedString.Wallet.available
        lbStake.text = LocalizedString.Wallet.staked
        lbRefunding.text = LocalizedString.Wallet.refunding
        
        btnDelegate.setTitle(LocalizedString.Wallet.Delegate.delegate, for: .normal)
        btnUndelegate.setTitle(LocalizedString.Wallet.Delegate.undelegate, for: .normal)
        btnBuyRam.setTitle(LocalizedString.Wallet.Ram.buyram, for: .normal)
        btnSellRam.setTitle(LocalizedString.Wallet.Ram.sellram, for: .normal)
        btnDelete.setTitle(LocalizedString.Wallet.Option.delete, for: .normal)
        
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
        
        btnDelete.rx.singleTap
            .bind { [weak self] in
                guard let account = self?.accountInfo else { return }
                self?.deleteWallet(account: account)
            }
            .disposed(by: bag)
        
    }
    
    fileprivate func deleteWallet(account: AccountInfo) {
        DB.shared.deleteAccount(account: account)
        
        AccountManager.shared.refreshUI()
        
        flowDelegate?.finish(viewControllerToFinish: self, animated: true, completion: {
            
        })
        
    }
    
    
    fileprivate func updateAccount(with viewModel: AccountInfo) {
        if viewModel.isInvalidated { return }
        
        account.text = viewModel.account
        total.text = viewModel.totalEOS.dot4String
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
        resUsedCPU.text = "\(viewModel.usedCPU.prettyPrinted) / \(viewModel.maxCPU.prettyPrinted) us"
        resUsedCPUPercent.text =  "( \(Int(viewModel.usedCPURatio * 100)) % )"
        progCPU.setProgress(viewModel.usedCPURatio, animated: true)
        if viewModel.maxCPU - viewModel.usedCPU < Config.limitResCPU {
            progCPU.progressTintColor = Color.progressMagenta.uiColor
            resUsedCPUPercent.textColor = Color.progressMagenta.uiColor
        } else {
            progCPU.progressTintColor = Color.progressGreen.uiColor
            resUsedCPUPercent.textColor = Color.gray.uiColor
        }
        
        resNet.text = viewModel.netStakedEOS.dot4String + " " + .eos
        resUsedNet.text = "\(viewModel.usedNet.prettyPrinted) / \(viewModel.maxNet.prettyPrinted) Bytes"
        resUsedNetPercent.text =  "( \(Int(viewModel.usedNetRatio * 100)) % )"
        progNet.setProgress(viewModel.usedNetRatio, animated: true)
        if viewModel.maxNet - viewModel.usedNet < Config.limitResNet {
            progNet.progressTintColor = Color.progressMagenta.uiColor
            resUsedNetPercent.textColor = Color.progressMagenta.uiColor
        } else {
            progNet.progressTintColor = Color.progressGreen.uiColor
            resUsedNetPercent.textColor = Color.gray.uiColor
        }
        
        resRam.text = "\(viewModel.usedRam.prettyPrinted) / \(viewModel.maxRam.prettyPrinted) Bytes"
        resUsedRamPercent.text = "( \(Int(viewModel.usedRAMRatio * 100)) % )"
        progRam.setProgress(viewModel.usedRAMRatio, animated: true)
        if viewModel.maxRam - viewModel.usedRam < Config.limitResRAM {
            progRam.progressTintColor = Color.progressMagenta.uiColor
            resUsedRamPercent.textColor = Color.progressMagenta.uiColor
        } else {
            progRam.progressTintColor = Color.progressGreen.uiColor
            resUsedRamPercent.textColor = Color.gray.uiColor
        }
        
        //owner mode
        if viewModel.ownerMode == false {
            layoutResY.constant = -15
            layoutRAMY.constant = -15
            view.layoutIfNeeded()
            
            btnDelegate.isHidden = true
            btnUndelegate.isHidden = true
            btnBuyRam.isHidden = true
            btnSellRam.isHidden = true
        }
        
        deleteView.isHidden = viewModel.ownerMode
        
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
                    if viewModel.isInvalidated { return }
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

extension WalletDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            self.navigationItem.largeTitleDisplayMode = .always
        } else {
            self.navigationItem.largeTitleDisplayMode = .never
        }
        self.navigationController?.navigationBar.setNeedsLayout()
        self.view.setNeedsLayout()
        UIView.animate(withDuration: 0.25, animations: {
            self.navigationController?.navigationBar.layoutIfNeeded()
            self.view.layoutIfNeeded()
        })
    }
}
