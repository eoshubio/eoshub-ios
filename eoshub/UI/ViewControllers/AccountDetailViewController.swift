//
//  AccountDetailViewController.swift
//  eoshub
//
//  Created by kein on 2018. 8. 20..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class AccountDetailViewController: BaseTableViewController {
    
    fileprivate enum ItemType {
        case accountInfo, resources, tokens, vote, tx, permissions, donation, delete
    }
    
    var flowDelegate: AccountDetailFlowEventDelegate?
    
    fileprivate var account: AccountInfo!
    
    fileprivate var items: [ItemType] = [.accountInfo, .resources]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar(with: .basePurple, animated: animated, largeTitle: true)
        title = LocalizedString.Wallet.Detail.title
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
    }
    
    private func setupUI() {
        let bgView = UIImageView(image: #imageLiteral(resourceName: "bgGrady"))
        bgView.alpha = 0.7
        tableView.backgroundView = bgView
        
        tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 20, right: 0)
        
        tableView.register(UINib(nibName: "DonationCell", bundle: nil), forCellReuseIdentifier: "DonationCell")
        
    }
    
    private func bindActions() {
        
    }
    
    func configure(account: AccountInfo) {
        self.account = account
        
        if account.ownerMode {
            items.append(contentsOf: [.tokens, .permissions, .vote, .tx, .delete])
            
            if account.account != "forthehorde2" {
                items.append(.donation)
            }
            
        } else {
            items.append(contentsOf: [.tokens, .permissions, .tx, .delete])
        }
        
    }
    
    fileprivate func deleteWallet() {
        DB.shared.deleteAccount(account: account, userId: UserManager.shared.userId)
        
        AccountManager.shared.refreshUI()
        
        flowDelegate?.finish(viewControllerToFinish: self, animated: true, completion: {
            
        })
        
    }
    
    fileprivate func delete() {
        let alert = UIAlertController(title: LocalizedString.Common.caution,
                                      message: LocalizedString.Wallet.Option.deleteWarning,
                                      preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: LocalizedString.Wallet.Option.delete,
                                      style: .destructive, handler: { [weak self] (_) in
                                        self?.deleteWallet()
        }))
        
        alert.addAction(UIAlertAction(title: LocalizedString.Common.cancel,
                                      style: .cancel, handler: nil))
        
        
        present(alert, animated: true, completion: nil)
    }
    
}

extension AccountDetailViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        switch item {
        case .accountInfo:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AccountCell", for: indexPath) as? AccountCell else { preconditionFailure() }
            cell.configure(viewModel: account)
            return cell
        case .resources:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ResourcesCell", for: indexPath) as? ResourcesCell else { preconditionFailure() }
            cell.configure(viewModel: account)
            return cell
        case .tokens:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath) as? TitleCell else { preconditionFailure() }
            cell.configure(title: LocalizedString.Wallet.Option.addToken, color: .lightPurple, marginTop: 25)
            return cell
        case .permissions:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath) as? TitleCell else { preconditionFailure() }
            cell.configure(title: LocalizedString.Wallet.Detail.keypairs, color: .lightPurple)
            return cell
        case .vote:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath) as? TitleCell else { preconditionFailure() }
            cell.configure(title: LocalizedString.Vote.title, color: .lightPurple)
            return cell
        case .tx:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath) as? TitleCell else { preconditionFailure() }
            cell.configure(title: LocalizedString.Wallet.Transfer.history, color: .lightPurple)
            return cell
        case .delete:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath) as? TitleCell else { preconditionFailure() }
            cell.configure(title: LocalizedString.Wallet.Option.delete, color: .red, marginTop: 30)
            return cell
        case .donation:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DonationCell", for: indexPath) as? DonationCell else { preconditionFailure() }
            return cell
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        guard let nc = navigationController else { return }
        switch item {
        case .resources:
            if account.ownerMode {
                flowDelegate?.goToResources(from: nc)
            }
        case .tokens:
            flowDelegate?.goToToken(from: nc)
        case .vote:
            flowDelegate?.goToVote(from: nc)
        case .tx:
            flowDelegate?.goToTx(from: nc)
        case .permissions:
            flowDelegate?.goToKeyPair(from: nc)
        case .delete:
            delete()
        case .donation:
            flowDelegate?.goToDonate(from: nc)
        default:
            break
        }
        
    }
}



class AccountCell: UITableViewCell {
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
    
    var bag: DisposeBag?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = nil
    }
    
    private func setupUI() {
        lbAvailable.text = LocalizedString.Wallet.available
        lbStake.text = LocalizedString.Wallet.staked
        lbRefunding.text = LocalizedString.Wallet.refunding
        remainTimeView.layer.cornerRadius = remainTimeView.bounds.height * 0.5
        remainTimeView.layer.masksToBounds = true
        remainTimeView.layer.borderWidth = 1.0
        remainTimeView.layer.borderColor = Color.red.uiColor.cgColor
    }
    
    func configure(viewModel: AccountInfo) {
        let bag = DisposeBag()
        self.bag = bag
        
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
}


class ResourcesCell: UITableViewCell {
    @IBOutlet fileprivate weak var lbTitle: UILabel!
    
    @IBOutlet fileprivate weak var resUsedCPU: UILabel!
    @IBOutlet fileprivate weak var resUsedCPUPercent: UILabel!
    @IBOutlet fileprivate weak var progCPU: UIProgressView!
    
    @IBOutlet fileprivate weak var resUsedNet: UILabel!
    @IBOutlet fileprivate weak var resUsedNetPercent: UILabel!
    @IBOutlet fileprivate weak var progNet: UIProgressView!
    
    @IBOutlet fileprivate weak var resUsedRam: UILabel!
    @IBOutlet fileprivate weak var resUsedRamPercent: UILabel!
    @IBOutlet fileprivate weak var progRam: UIProgressView!
    
    @IBOutlet fileprivate weak var detailIndicator: UIView!
    @IBOutlet fileprivate weak var layoutDetail: NSLayoutConstraint!
    
    var bag: DisposeBag?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = nil
    }
    
    private func setupUI() {
        
    }
    
    func configure(viewModel: AccountInfo) {
        //resources
        
        lbTitle.text = LocalizedString.Wallet.resources
        
        resUsedCPU.text = "\(viewModel.usedCPU.prettyPrinted) / \(viewModel.maxCPU.prettyPrinted) us"
        resUsedCPUPercent.text =  "\(Int(viewModel.usedCPURatio * 100)) %"
        progCPU.setProgress(viewModel.usedCPURatio, animated: true)
        if viewModel.maxCPU - viewModel.usedCPU < Config.limitResCPU {
            progCPU.progressTintColor = Color.progressMagenta.uiColor
            resUsedCPUPercent.textColor = Color.progressMagenta.uiColor
        } else {
            progCPU.progressTintColor = Color.progressGreen.uiColor
            resUsedCPUPercent.textColor = Color.gray.uiColor
        }
        
        resUsedNet.text = "\(viewModel.usedNet.prettyPrinted) / \(viewModel.maxNet.prettyPrinted) Bytes"
        resUsedNetPercent.text =  "\(Int(viewModel.usedNetRatio * 100)) %"
        progNet.setProgress(viewModel.usedNetRatio, animated: true)
        if viewModel.maxNet - viewModel.usedNet < Config.limitResNet {
            progNet.progressTintColor = Color.progressMagenta.uiColor
            resUsedNetPercent.textColor = Color.progressMagenta.uiColor
        } else {
            progNet.progressTintColor = Color.progressGreen.uiColor
            resUsedNetPercent.textColor = Color.gray.uiColor
        }
        
        resUsedRam.text = "\(viewModel.usedRam.prettyPrinted) / \(viewModel.maxRam.prettyPrinted) Bytes"
        resUsedRamPercent.text = "\(Int(viewModel.usedRAMRatio * 100)) %"
        progRam.setProgress(viewModel.usedRAMRatio, animated: true)
        if viewModel.maxRam - viewModel.usedRam < Config.limitResRAM {
            progRam.progressTintColor = Color.progressMagenta.uiColor
            resUsedRamPercent.textColor = Color.progressMagenta.uiColor
        } else {
            progRam.progressTintColor = Color.progressGreen.uiColor
            resUsedRamPercent.textColor = Color.gray.uiColor
        }
        
        detailIndicator.isHidden = (viewModel.ownerMode == false)
        
        if viewModel.ownerMode {
            layoutDetail.constant = 15
        } else {
            layoutDetail.constant = -25
        }
        layoutIfNeeded()
        
    }
}

class TitleCell: UITableViewCell {
    @IBOutlet fileprivate weak var lbTitle: BorderColorButton!
    @IBOutlet fileprivate weak var layoutTop: NSLayoutConstraint!
    
    func configure(title: String, color: Color, marginTop: CGFloat = 10) {
        lbTitle.setTitle(title, for: .normal)
        lbTitle.setTitleColor(color.uiColor, for: .normal)
        layoutTop.constant = marginTop
        superview?.layoutIfNeeded()
    }
    
}





