//
//  VoteViewController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 9..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class VoteViewController: BaseViewController {
    private let maxBPList = 400
    
    var flowDelegate: VoteFlowEventDelegate?
    
    @IBOutlet fileprivate weak var naviBar: UINavigationBar!
    @IBOutlet fileprivate weak var lbAccountName: UILabel!
    @IBOutlet fileprivate weak var lbStakedEOSTitle: UILabel!
    @IBOutlet fileprivate weak var lbStakedEOS: UILabel!
    @IBOutlet fileprivate weak var btnChangeStake: UIButton!
    @IBOutlet fileprivate weak var btnChangeAccount: UIButton!
    @IBOutlet fileprivate weak var bpList: UITableView!
    
    fileprivate weak var btnApplyItem: UIBarButtonItem!
    fileprivate weak var btnVotedBPs: UIBarButtonItem!
    
    fileprivate var selectedAccount: AccountInfo? {
        return AccountManager.shared.mainAccount
    }
    fileprivate var items: [BPCellViewModel] = []
    fileprivate var prvVotedBps: [BPCellViewModel] = []
    fileprivate var selectedBps: [BPCellViewModel] {
        return items.filter({$0.selected})
    }
    
    fileprivate var applyControlContainer: UIView? = nil
    fileprivate var btnApply: UIButton? = nil
    
    fileprivate let maxVoteCount = 19 //for JungleNet
    
    fileprivate let menuControlHeight: CGFloat = 90
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Vote"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
    }
    
    private func setupUI() {
        lbStakedEOSTitle.text = LocalizedString.Vote.staked
        btnChangeStake.setTitle(LocalizedString.Vote.changeStake, for: .normal)
        
        naviBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        naviBar.shadowImage = UIImage()
        naviBar.isTranslucent = true
        naviBar.tintColor = .white
        
        bpList.rowHeight = UITableViewAutomaticDimension
        bpList.estimatedRowHeight = 65
        bpList.dataSource = self
        bpList.delegate = self
        
        let applyButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
        applyButton.setTitle("Apply", for: .normal)
        applyButton.titleLabel?.font = Font.appleSDGothicNeo(.medium).uiFont(12)
        applyButton.setTitleColor(UIColor.white, for: .normal)
        let applyItem = UIBarButtonItem(customView: applyButton)
        
        navigationItem.rightBarButtonItems = [applyItem]
        
    }
    
    private func bindActions() {
        btnChangeAccount.rx.tap
            .subscribe(onNext: { [weak self](_) in
                self?.handleChangeAccount()
            })
            .disposed(by: bag)
        
        AccountManager.shared.accountInfoRefreshed
            .subscribe(onNext: { [weak self](_) in
                if let selectedAccount = self?.selectedAccount {
                    self?.layoutVoterInfo(account: selectedAccount)
                }
            })
            .disposed(by: bag)

        btnChangeStake.rx.singleTap
            .bind { [weak self] in
                guard let nc = self?.navigationController, let account = self?.selectedAccount else { return }
                self?.flowDelegate?.goToWalletDetail(from: nc, account: account)
            }
            .disposed(by: bag)
    }
    
    func reload() {
        loadMainAccount()
        loadBPList()
    }
    
    fileprivate func loadMainAccount() {
        let mgr = AccountManager.shared
        if let mainAccount = mgr.mainAccount ?? mgr.infos.first {
            configure(account: mainAccount)
        }
        
        btnChangeAccount.isHidden =  AccountManager.shared.infos.count <= 1
    }
    
    fileprivate func loadBPList() {
        RxEOSAPI.getProducers(limit: maxBPList)
            .subscribe(onNext: { [weak self](bps) in
                Log.i(bps)
                self?.items = bps.produces.compactMap(BPInfo.init)
                self?.bpList.reloadData()
                //get votes info
                if let selectedAccount = self?.selectedAccount {
                    self?.layoutVoterInfo(account: selectedAccount)
                }
            }, onError: { (error) in
                
            }, onCompleted: {
                
            })
            .disposed(by: bag)
    }
    
    
    fileprivate func configure(account: AccountInfo) {
        AccountManager.shared.mainAccount = account
        
        layoutVoterInfo(account: account)
    }
    
    fileprivate func layoutVoterInfo(account: AccountInfo) {
        
        lbAccountName.text = account.account
        lbStakedEOS.text = account.stakedEOS.dot4String
        
        let bps = account.votedProducers
        var bpMap: [String: Bool] = [:]
        bps.forEach({bpMap[$0] = true})
        
        items.forEach { (bp) in
            var bp = bp
            if bpMap[bp.name] == true {
                bp.selected = true
            } else {
                bp.selected = false
            }
        }
        applySelection()
    }
    
    fileprivate func handleChangeAccount() {
        let alert = UIAlertController(title: LocalizedString.Vote.changeAccount, message: LocalizedString.Vote.selectAccount, preferredStyle: .actionSheet)
        
        AccountManager.shared.infos.forEach { (info) in
            
            alert.addAction(UIAlertAction(title: info.account, style: .default, handler: { [weak self](_) in
                AccountManager.shared.mainAccount = info
                self?.configure(account: info)
            }))
        }
        alert.addAction(UIAlertAction(title: LocalizedString.Common.cancel, style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func addApplySectionIfNeeded() {
        if applyControlContainer != nil { return }
        
        guard let window = UIApplication.shared.keyWindow else { return }
        
        let applyView = UIView(frame: CGRect(x: 0, y: window.bounds.height, width: view.bounds.width, height: menuControlHeight))
        applyView.backgroundColor = .white
        
        let hline = UIView(frame: CGRect(x: 0, y: 0, width: applyView.bounds.width, height: 1))
        hline.backgroundColor = Color.seperator.uiColor
        applyView.addSubview(hline)
        
        let halfWidth = (applyView.bounds.width - 30 - 5 ) * 0.5
        
        let applyButton = RoundedButton(frame: CGRect(x: 15, y: 15, width: halfWidth, height: 44))
        applyButton.setTitleColor(UIColor.white, for: .normal)
        applyButton.titleLabel?.font = Font.appleSDGothicNeo(.bold).uiFont(12)
        applyButton.backgroundColor = Color.lightPurple.uiColor
        applyButton.addTarget(self, action: #selector(self.onVoteApplyClicked), for: .touchUpInside)
        
        applyView.addSubview(applyButton)
        
        let cancelButton = PurpleButton(frame: CGRect(x: applyButton.frame.maxX + 5, y: applyButton.frame.minY,
                                                      width: halfWidth, height: 44))
        cancelButton.setTitle(LocalizedString.Common.cancel, for: .normal)
        cancelButton.titleLabel?.font = Font.appleSDGothicNeo(.bold).uiFont(12)
        cancelButton.addTarget(self, action: #selector(self.onVoteCancelled), for: .touchUpInside)
        applyView.addSubview(cancelButton)

        window.addSubview(applyView)
        
        applyControlContainer = applyView
        btnApply = applyButton
        
        updateApplyButton()
    }
    
    fileprivate func updateApplyButton() {
        guard let window = UIApplication.shared.keyWindow else { return }
        UIView.animate(withDuration: 0.25) {
            self.applyControlContainer?.frame.origin.y = window.bounds.height - self.menuControlHeight
        }
        
        let text = LocalizedString.Common.apply + " (\(selectedBps.count)/\(maxVoteCount))"
        btnApply?.setTitle(text, for: .normal)
    }
    
    @objc fileprivate func onVoteApplyClicked() {
        //1. get voter
        guard let selectedAccount = selectedAccount else { return }
        let voter = selectedAccount.account
        let bps = selectedBps.map({$0.name}).sorted()
            
        unlockWallet(pinTarget: self, pubKey: selectedAccount.pubKey)
            .flatMap({ (wallet) -> Observable<JSON> in
                return RxEOSAPI.voteBPs(voter: voter, producers: bps, wallet: wallet)
            })
            .flatMap({ (_) -> Observable<Void> in
                return AccountManager.shared.loadAccounts()
            })
            .subscribe(onNext: { (_) in
                
            }, onError: { (error) in
                Log.e(error)
            }, onCompleted: {
                
            })
            .disposed(by: bag)
        
        
        applySelection()
        dismissApplyView()
    }
    
    @objc fileprivate func onVoteCancelled() {
        restoreSelection()
        dismissApplyView()
    }
    
    fileprivate func dismissApplyView() {
        guard let window = UIApplication.shared.keyWindow else { return }
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.applyControlContainer?.frame.origin.y = window.bounds.height
        }
//        applyControlContainer?.removeFromSuperview()
//        applyControlContainer = nil
//        btnApply = nil
    }
    
    fileprivate func updateSelection() {
        let prv = prvVotedBps.map({"\($0.index)"}).joined(separator: "")
        let cur = selectedBps.sorted { (lhs, rhs) -> Bool in
            return lhs.index < rhs.index
        }.map({"\($0.index)"}).joined(separator: "")
        
        if prv == cur {
            onVoteCancelled()
        } else {
            addApplySectionIfNeeded()
            updateApplyButton()
        }
    }
    
    fileprivate func restoreSelection() {
        items.forEach { (bp) in
            var bp = bp
            bp.selected = false
        }
        prvVotedBps.forEach { (prvSelectedBp) in
            var bp = items[prvSelectedBp.index]
            bp.selected = true
        }
        
        bpList.reloadData()
        selectFromDataSource()
    }
    
    fileprivate func applySelection() {
        prvVotedBps = selectedBps.sorted(by: { (lhs, rhs) -> Bool in
            return lhs.index < rhs.index
        })
        bpList.reloadData()
        selectFromDataSource()
    }
    
    fileprivate func selectFromDataSource() {
        selectedBps.map({IndexPath(row: $0.index, section: 0)})
                    .forEach({bpList.selectRow(at: $0, animated: false, scrollPosition: .none)})
    }
    
}

extension VoteViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BPCell", for: indexPath) as? BPCell else { preconditionFailure() }
        
        let bp = items[indexPath.row]
        cell.configure(viewModel: bp)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var bp = items[indexPath.row]
        bp.selected = true
        updateSelection()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        var bp = items[indexPath.row]
        bp.selected = false
        updateSelection()
    }

}



