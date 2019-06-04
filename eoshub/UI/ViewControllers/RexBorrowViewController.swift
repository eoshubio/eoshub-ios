//
//  RexBorrowViewController.swift
//  eoshub
//
//  Created by kein on 06/05/2019.
//  Copyright © 2019 EOS Hub. All rights reserved.
//

import Foundation
import RxSwift

class RexBorrowViewController: BaseTableViewController {
    
    var flowDelegate: RexFlowEventDelegate?
    
    enum CellType: Int, CaseIterable {
        case fund
        case cpu
        case net
        case res
    }
    
    fileprivate let items = [CellType.fund, .res, .cpu, .net]
    
    fileprivate var account: AccountInfo!
    fileprivate var rexInfo: RexInfo!
    fileprivate var rexInfoSubject: RexInfoSubject!
    
    fileprivate var depositSubject = PublishSubject<Void>()
    fileprivate var depositToRex = PublishSubject<Currency>()
    fileprivate var withdrawSubject = PublishSubject<Void>()
    fileprivate var withdrawFromRex = PublishSubject<Currency>()
    
    fileprivate let cpuSubject = PublishSubject<(payment: Currency, fund: Currency)>()
    fileprivate let netSubject = PublishSubject<(payment: Currency, fund: Currency)>()
    
    private let disposeBag = DisposeBag()
    
    func configure(account: AccountInfo, rexInfo: RexInfoSubject) {
        self.account = account
        self.rexInfoSubject = rexInfo
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar(with: .basePurple, animated: animated, largeTitle: true)
        title = "Borrow CPU/NET"
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
        tableView.register(UINib(nibName: "RexFundCell", bundle: nil), forCellReuseIdentifier: "RexFundCell")
        
    }
    
    private func bindActions() {
        depositSubject
            .bind { [weak self] in
                self?.deposit()
            }
            .disposed(by: disposeBag)
        
        withdrawSubject
            .bind { [weak self] in
                self?.withdraw()
            }
            .disposed(by: disposeBag)
        
        guard let highestPriorityKey = account.highestPriorityKey else { return }
        
        let wallet = Wallet(key: highestPriorityKey.eosioKey.key, parent: self)
        let accountName = account.account
        
        depositToRex
            .bind { [weak self](amount) in
                guard let `self` = self else { return }
                WaitingView.shared.start()
                RxEOSAPI.depositToRex(owner: accountName,
                                      wallet: wallet,
                                      authorization: Authorization(actor: accountName, permission: highestPriorityKey.permission))(amount)
                    .subscribe(onNext: { [weak self](_) in
                        self?.loadData(useActivityIndicator: false)
                        }, onError: { (error) in
                            WaitingView.shared.stop()
                            if let error = error as? PrettyPrintedPopup {
                                error.showPopup()
                            } else {
                                Log.e(error)
                            }
                    })
                    .disposed(by: self.disposeBag)
            }
            .disposed(by: disposeBag)
        
        
        withdrawFromRex
            .bind { [weak self](amount) in
                guard let `self` = self else { return }
                WaitingView.shared.start()
                RxEOSAPI.withdrawFromRex(owner: accountName,
                                         wallet: wallet,
                                         authorization: Authorization(actor: accountName, permission: highestPriorityKey.permission))(amount)
                    .subscribe(onNext: { [weak self](_) in
                        self?.loadData(useActivityIndicator: false)
                        }, onError: { (error) in
                            WaitingView.shared.stop()
                            if let error = error as? PrettyPrintedPopup {
                                error.showPopup()
                            } else {
                                Log.e(error)
                            }
                    })
                    .disposed(by: self.disposeBag)
            }
            .disposed(by: disposeBag)
        
        cpuSubject
            .bind { [weak self](amount) in
                guard let `self` = self else { return }
                WaitingView.shared.start()
                RxEOSAPI.rentCPU(owner: accountName,
                                         wallet: wallet,
                                         authorization: Authorization(actor: accountName, permission: highestPriorityKey.permission))(amount)
                    .subscribe(onNext: { [weak self](_) in
                        self?.loadData(useActivityIndicator: false)
                        }, onError: { (error) in
                            WaitingView.shared.stop()
                            if let error = error as? PrettyPrintedPopup {
                                error.showPopup()
                            } else {
                                Log.e(error)
                            }
                    })
                    .disposed(by: self.disposeBag)
            }
            .disposed(by: disposeBag)
        
        netSubject
            .bind { [weak self](amount) in
                guard let `self` = self else { return }
                WaitingView.shared.start()
                RxEOSAPI.rentNET(owner: accountName,
                                 wallet: wallet,
                                 authorization: Authorization(actor: accountName, permission: highestPriorityKey.permission))(amount)
                    .subscribe(onNext: { [weak self](_) in
                        self?.loadData(useActivityIndicator: false)
                        }, onError: { (error) in
                            WaitingView.shared.stop()
                            if let error = error as? PrettyPrintedPopup {
                                error.showPopup()
                            } else {
                                Log.e(error)
                            }
                    })
                    .disposed(by: self.disposeBag)
            }
            .disposed(by: disposeBag)
        
        rexInfoSubject
            .bind { [weak self](info) in
                guard let info = info else { return }
                self?.rexInfo = info
                self?.tableView.reloadData()
            }
            .disposed(by: disposeBag)
    }
    
    private func loadData(useActivityIndicator: Bool = true) {
        
        if useActivityIndicator {
            WaitingView.shared.start()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let `self` = self else { return }
            self.refreshData()
                .subscribe() {
                    WaitingView.shared.stop()
                }
                .disposed(by: self.bag)
        }
        
    }
    
    private func refreshData() -> Observable<RexInfo> {
        return AccountManager.shared.refreshAccount(account: account.account)
            .flatMap { [unowned self](account) -> Observable<RexInfo> in
                self.account = account
                return RxEOSAPI.getRexInfo(account: self.account.account)
            }
            .flatMap({ [weak self](rexInfo) -> Observable<RexInfo> in
                self?.rexInfoSubject.onNext(rexInfo)
                return Observable.just(rexInfo)
            })
    }
    
}

extension RexBorrowViewController {
    
    func deposit() {
        DepositPopup.present(type: .deposit, availableEOS: Currency(balance: account.availableEOS), actionObserver: depositToRex.asObserver())
    }
    
    func withdraw() {
        DepositPopup.present(type: .withdraw, availableEOS: rexInfo.fund.balance, actionObserver: withdrawFromRex.asObserver())
    }
    
    fileprivate func borrowCPU() {
        RexBorrowPopup.present(type: .cpu, rexInfo: rexInfo, actionObserver: cpuSubject.asObserver())
    }
    
    fileprivate func borrowNET() {
        RexBorrowPopup.present(type: .net, rexInfo: rexInfo, actionObserver: netSubject.asObserver())
    }
}


//MARK: UITableViewDataSource

extension RexBorrowViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        
        switch item {
        case .fund:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RexFundCell", for: indexPath) as! RexFundCell
            cell.configure(fund: rexInfo.fund, depositObserver: depositSubject.asObserver(), withdrawObserver: withdrawSubject.asObserver())
            return cell
        case .cpu:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath) as? TitleCell else { preconditionFailure() }
            cell.configure(title: "Borrow CPU", color: .lightPurple)
            return cell
        case .net:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath) as? TitleCell else { preconditionFailure() }
            cell.configure(title: "Borrow Network", color: .lightPurple)
            return cell
        case .res:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "RexResourceCell", for: indexPath) as? RexResourceCell else { preconditionFailure() }
            cell.configure(account: account)
            return cell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        
        switch item {
        case .cpu:
           borrowCPU()
        case .net:
           borrowNET()
        default:
            break
        }
    }
}

class RexResourceCell: UITableViewCell {
    @IBOutlet fileprivate weak var resUsedCPU: UILabel!
    @IBOutlet fileprivate weak var resUsedCPUPercent: UILabel!
    @IBOutlet fileprivate weak var progCPU: UIProgressView!
    
    @IBOutlet fileprivate weak var resUsedNet: UILabel!
    @IBOutlet fileprivate weak var resUsedNetPercent: UILabel!
    @IBOutlet fileprivate weak var progNet: UIProgressView!
    
    func configure(account: AccountInfo) {
        //resources
        resUsedCPU.text = "\(account.usedCPU.prettyPrinted) / \(account.maxCPU.prettyPrinted) us"
        resUsedCPUPercent.text =  "\(Int(account.usedCPURatio * 100)) %"
        progCPU.setProgress(account.usedCPURatio, animated: true)
        if account.maxCPU - account.usedCPU < Config.limitResCPU {
            progCPU.progressTintColor = Color.progressMagenta.uiColor
            resUsedCPUPercent.textColor = Color.progressMagenta.uiColor
        } else {
            progCPU.progressTintColor = Color.progressGreen.uiColor
            resUsedCPUPercent.textColor = Color.gray.uiColor
        }
        
        resUsedNet.text = "\(account.usedNet.prettyPrinted) / \(account.maxNet.prettyPrinted) Bytes"
        resUsedNetPercent.text =  "\(Int(account.usedNetRatio * 100)) %"
        progNet.setProgress(account.usedNetRatio, animated: true)
        if account.maxNet - account.usedNet < Config.limitResNet {
            progNet.progressTintColor = Color.progressMagenta.uiColor
            resUsedNetPercent.textColor = Color.progressMagenta.uiColor
        } else {
            progNet.progressTintColor = Color.progressGreen.uiColor
            resUsedNetPercent.textColor = Color.gray.uiColor
        }
       
        
    }
}
