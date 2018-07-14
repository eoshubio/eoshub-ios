//
//  WalletDetailViewController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 12..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

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
    @IBOutlet fileprivate weak var resCPUEOS: UILabel!
    @IBOutlet fileprivate weak var resNet: UILabel!
    @IBOutlet fileprivate weak var resNetEOS: UILabel!
    
    @IBOutlet fileprivate weak var ramView: UIView!
    @IBOutlet fileprivate weak var resRam: UILabel!
    
    @IBOutlet fileprivate weak var btnDelegate: UIButton!
    @IBOutlet fileprivate weak var btnUndelegate: UIButton!

    @IBOutlet fileprivate weak var btnBuyRam: UIButton!
    @IBOutlet fileprivate weak var btnSellRam: UIButton!
    
    private var accountInfo: EOSAccountViewModel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showNavigationBar(with: .white)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = accountInfo.account
        
        resourceView.layer.borderColor = Color.seperator.cgColor
        resourceView.layer.borderWidth = 1
        
        ramView.layer.borderColor = Color.seperator.cgColor
        ramView.layer.borderWidth = 1
        
        updateAccount(with: accountInfo)
    }
    
    fileprivate func updateAccount(with viewModel: EOSAccountViewModel) {
        account.text = viewModel.account
        total.text = viewModel.totalEOS.dot4String
        estimatedPrice.text = "= " + viewModel.estimatedPrice
        availableEOS.text = viewModel.availableEOS.dot4String
        stakedEOS.text = viewModel.stakedEOS.dot4String
        refundingEOS.text = viewModel.refundingEOS.dot4String
        remainTime.text = viewModel.refundingDateString
        
        
        let staked = EOSAmount(id: EOSState.staked.id, value: viewModel.stakedEOS.f)
        let refunding = EOSAmount(id: EOSState.refunding.id, value: viewModel.refundingEOS.f)
        let available = EOSAmount(id: EOSState.available.id, value: viewModel.availableEOS.f)
        
        progress.setProgressValues(values: [available, staked, refunding])
    }
    
    func configure(viewModel: EOSAccountViewModel) {
        accountInfo = viewModel
    }
    
}


extension WalletDetailViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
