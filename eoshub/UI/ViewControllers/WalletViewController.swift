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
import RealmSwift


class WalletViewController: BaseViewController {
    
    var flowDelegate: WalletFlowEventDelegate?
    
    @IBOutlet fileprivate var btnNotice: UIButton!
    @IBOutlet fileprivate var btnSetting: UIButton!
    @IBOutlet fileprivate var btnProfile: RoundedButton!
    
    @IBOutlet fileprivate var walletList: UITableView!
    
    @IBOutlet fileprivate var botContainer: UIView!
    
    fileprivate var items: [CellType] = []
    
    fileprivate var rx_send = PublishSubject<EOSAccountViewModel>()
    fileprivate var rx_receive = PublishSubject<EOSAccountViewModel>()
    
    lazy var eoshubAccounts: Results<EHAccount> = {
        return DB.shared.getAccounts().sorted(byKeyPath: "created", ascending: true)
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindActions()
        reloadUI()
        
    }
    
    private func setupUI() {
        btnProfile.setCornerRadius(radius: btnProfile.bounds.height * 0.5)
        btnProfile.imageView?.contentMode = .scaleAspectFill
        btnProfile.layer.shadowColor = UIColor.black.cgColor
        btnProfile.layer.shadowOffset = .zero
        btnProfile.layer.shadowRadius = 1.0
        
        walletList.contentInset = UIEdgeInsetsMake(0, 0, 100, 0)
        
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
    
    private func reloadUI() {
        items = [WalletAddCellType.add]
        
        if eoshubAccounts.count == 0 {
            items.insert(WalletAddCellType.guide, at: 0)
        } else {
            let accountInfos: [AccountInfo] = AccountManager.shared.infos
            
            items.insert(contentsOf: accountInfos, at: 0)
            
            walletList.reloadData()
        }
    }
    
   
    private func bindActions() {
        AccountManager.shared.accountInfoRefreshed
            .subscribe(onNext: { [weak self](_) in
                self?.reloadUI()
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
                self?.flowDelegate?.goToSend(from: nc, with: account, symbol: "EOS")
            })
            .disposed(by: bag)
        
        rx_receive
            .subscribe(onNext: { [weak self](account) in
                guard let nc = self?.parent?.navigationController else { return }
                self?.flowDelegate?.goToReceive(from: nc, with: account)
            })
            .disposed(by: bag)
        
        AccountManager.shared.loadAccounts()
            .subscribe()
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
        
        if item is EOSAccountViewModel {
            guard let cell = cell as? WalletCell, let item = item as? EOSAccountViewModel else { preconditionFailure() }
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
        if let item = item as? EOSAccountViewModel {
            //go to wallet detail
            flowDelegate?.goToWalletDetail(from: nc, with: item)
        } else if item is WalletAddCellType {
            //go to create wallet
            
            flowDelegate?.goToCreate(from: nc)
        }
    }
}
