//
//  WalletViewController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 8..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import RxSwift


class WalletViewController: BaseViewController {
    
    var flowDelegate: WalletFlowEventDelegate?
    
    @IBOutlet fileprivate var btnNotice: UIButton!
    @IBOutlet fileprivate var btnSetting: UIButton!
    @IBOutlet fileprivate var btnProfile: RoundedButton!
    
    @IBOutlet fileprivate var walletList: UITableView!
    
    @IBOutlet fileprivate var botContainer: UIView!
    
    fileprivate var items: [CellType] = []
    
    fileprivate var rx_send = PublishSubject<EOSWalletViewModel>()
    fileprivate var rx_receive = PublishSubject<EOSWalletViewModel>()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
        
    }
    
    func configure(data: [CellType]) {
        items = data
        walletList.reloadData()
    }
    
    private func setupUI() {
        btnProfile.setCornerRadius(radius: btnProfile.bounds.height * 0.5)
        btnProfile.imageView?.contentMode = .scaleAspectFill
        btnProfile.layer.shadowColor = UIColor.black.cgColor
        btnProfile.layer.shadowOffset = .zero
        btnProfile.layer.shadowRadius = 1.0
        
        setupTableView()
    }
    
    private func setupTableView() {
        walletList.dataSource = self
        walletList.delegate = self
        walletList.rowHeight = UITableViewAutomaticDimension
        walletList.estimatedRowHeight = 60
    
        walletList.register(UINib(nibName: "WalletAddCell", bundle: nil), forCellReuseIdentifier: "WalletAddCell")
        
        walletList.register(UINib(nibName: "WalletCell", bundle: nil), forCellReuseIdentifier: "WalletCell")
        
        walletList.register(UINib(nibName: "WalletGuideCell", bundle: nil), forCellReuseIdentifier: "WalletGuideCell")
        
    }
    
   
    private func bindActions() {
        AccountManager.shared.accountInfoRefreshed
            .subscribe(onNext: { [weak self](_) in
                let dummyEOSModel = EOSWalletViewModel(account: "eoshubalpha1",
                                                       totalEOS: 100000.2423,
                                                       estimatedPrice: "102,342,342,424 KRW",
                                                       stakedEOS: 23423.02324123,
                                                       refundingEOS: 45323,
                                                       refundingRemainTime: "2일 23시간 23분",
                                                       showSendButton: true)
                self?.items = [dummyEOSModel, WalletAddCellType.add]
                self?.walletList.reloadData()
            })
            .disposed(by: bag)
        
        
        
        btnSetting.rx.singleTap
            .bind { [weak self](_) in
                guard let nc = self?.parent?.navigationController else { return }
                self?.flowDelegate?.goToSetting(from: nc)
            }
            .disposed(by: bag)
        
        rx_send
            .subscribe(onNext: { [weak self](account) in
                guard let nc = self?.parent?.navigationController else { return }
                self?.flowDelegate?.goToSend(from: nc, with: account)
            })
            .disposed(by: bag)
        
        rx_receive
            .subscribe(onNext: { (account) in
                
            })
            .disposed(by: bag)
    }
    
    
}


extension WalletViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = items[indexPath.section]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: item.nibName) else {
            preconditionFailure()
        }
        
        if item is EOSWalletViewModel {
            guard let cell = cell as? WalletCell, let item = item as? EOSWalletViewModel else { preconditionFailure() }
            cell.configure(viewModel: item, sendObserver: rx_send, receiveObserver: rx_receive)
            cell.selectionStyle = .none
            return cell
        } else {
            cell.selectionStyle = .gray
        }
        
        return cell
    }
    
}


extension WalletViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let v = UIView()
        v.backgroundColor = UIColor.clear
        return v
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        guard let nc = parent?.navigationController else { return }
        
        let item = items[indexPath.section]
        if let item = item as? EOSWalletViewModel {
            //go to wallet detail
            flowDelegate?.goToWalletDetail(from: nc, with: item)
        } else if item is WalletAddCellType {
            //go to create wallet
            
            flowDelegate?.goToCreate(from: nc)
        }
    }
}
