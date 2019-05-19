//
//  RexLendViewController.swift
//  eoshub
//
//  Created by kein on 06/05/2019.
//  Copyright © 2019 EOS Hub. All rights reserved.
//

import Foundation
import RxSwift

class RexLendViewController: BaseTableViewController {
    
    var flowDelegate: RexFlowEventDelegate?
    
    enum CellType: Int, CaseIterable {
        case fund, buy, sell, unstake
    }
    
    fileprivate let items = [CellType.buy, .sell, .unstake]
    
    fileprivate var account: AccountInfo!
    fileprivate var rexInfo: RexInfo!
    
    fileprivate var buyPopupSubject = PublishSubject<Void>()
    fileprivate var sellPopupSubject = PublishSubject<Void>()
    fileprivate var maturitiesSubject = PublishSubject<Void>()
    fileprivate var unstakePopupSubject = PublishSubject<Void>()
    
    fileprivate var buySubject = PublishSubject<Currency>()
    fileprivate var sellSubject = PublishSubject<Currency>()
    fileprivate var unstakeSubject = PublishSubject<(cpu: Currency, net: Currency)>()
    
    deinit {
        Log.i("deinit")
    }
    
    func configure(account: AccountInfo, rexInfo: RexInfo) {
        self.account = account
        self.rexInfo = rexInfo
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar(with: .basePurple, animated: animated, largeTitle: true)
        title = "Buy / Sell REX"
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
        buyPopupSubject
            .bind { [weak self] in
                self?.buy()
            }
            .disposed(by: bag)
        
        sellPopupSubject
            .bind { [weak self] in
                self?.sell()
            }
            .disposed(by: bag)
        
        maturitiesSubject
            .bind { [weak self] in
                self?.goToMaturities()
            }
            .disposed(by: bag)
        
        unstakePopupSubject
            .bind { [weak self] in
                self?.unstake()
            }
            .disposed(by: bag)
        
        guard let highestPriorityKey = account.highestPriorityKey else { return }
        
        let wallet = Wallet(key: highestPriorityKey.eosioKey.key, parent: self)
        let accountName = account.account
        
        buySubject
            .bind { [weak self](amount) in
                guard let `self` = self else { return }
                WaitingView.shared.start()
                RxEOSAPI.buyRex(owner: accountName,
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
                    .disposed(by: self.bag)
            }
            .disposed(by: bag)
        
        sellSubject
            .bind { [weak self](amount) in
                guard let `self` = self else { return }
                WaitingView.shared.start()
                RxEOSAPI.sellRex(owner: accountName,
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
                    .disposed(by: self.bag)
            }
            .disposed(by: bag)
            
        unstakeSubject
            .bind { [weak self](amount) in
                guard let `self` = self else { return }
                WaitingView.shared.start()
                RxEOSAPI.unstakeToRex(owner: accountName,
                                      wallet: wallet,
                                      authorization: Authorization(actor: accountName, permission: highestPriorityKey.permission))(amount)
                    .subscribe(onNext: { [weak self](json) in
                        self?.loadData(useActivityIndicator: false)
                        }, onError: { (error) in
                            WaitingView.shared.stop()
                            if let error = error as? PrettyPrintedPopup {
                                error.showPopup()
                            } else {
                                Log.e(error)
                            }
                    })
                    .disposed(by: self.bag)
            }
            .disposed(by: bag)
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
                    self?.rexInfo = rexInfo
                    self?.tableView.reloadData()
                    return Observable.just(rexInfo)
                })
    }
}

extension RexLendViewController {
    fileprivate func buy() {
        RexBuySellPopup.present(type: .buy, available: rexInfo.fund.balance, actionObserver: buySubject.asObserver())
    }
    
    fileprivate func sell() {
        RexBuySellPopup.present(type: .sell, available: rexInfo.balance.maturedRex, actionObserver: sellSubject.asObserver())
    }
    
    fileprivate func goToMaturities() {
        let vc = UIStoryboard(name: "Rex", bundle: nil).instantiateViewController(withIdentifier: "RexRemainTimeViewController") as! RexRemainTimeViewController
        vc.configure(rexInfo: rexInfo)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    fileprivate func unstake() {
        RexUnstakeResPopup.present(account: account, observer: unstakeSubject.asObserver())
    }
}

//MARK: UITableViewDataSource

extension RexLendViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellType = items[indexPath.row]
        
        switch cellType {
        case .fund:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RexFundCell", for: indexPath) as! RexFundCell
            return cell
        case .buy:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RexBuySellCell", for: indexPath) as! RexBuySellCell
            cell.configure(type: cellType, rexInfo: rexInfo, observer: buyPopupSubject.asObserver())
            return cell
        case .sell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RexBuySellCell", for: indexPath) as! RexBuySellCell
            cell.configure(type: cellType, rexInfo: rexInfo, observer: sellPopupSubject.asObserver(), extraObserver: maturitiesSubject.asObserver())
            return cell
        case .unstake:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RexUnstakeCell", for: indexPath) as! RexUnstakeCell
            cell.configure(account: account, observer: unstakePopupSubject.asObserver())
            return cell
        }
        
    }
}

class RexBuySellCell: UITableViewCell {
    @IBOutlet fileprivate weak var lbTitle: UILabel!
    @IBOutlet fileprivate weak var lbBalance: UILabel!
    @IBOutlet fileprivate weak var btnAction: UIButton!
    @IBOutlet fileprivate weak var btnRemainTime: UIButton!
    @IBOutlet fileprivate weak var lbRemainTime: UILabel!
    @IBOutlet fileprivate weak var remainTimeView: UIView!
    
    fileprivate var bag: DisposeBag?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = nil
    }
    
    func configure(type: RexLendViewController.CellType, rexInfo: RexInfo, observer: AnyObserver<Void>, extraObserver: AnyObserver<Void>? = nil) {
        let bag = DisposeBag()
        self.bag = bag
        btnAction.rx.singleTap
            .bind(to: observer)
            .disposed(by: bag)
        
        switch type {
        case .buy:
            lbTitle.text = "EOS Balance"
            lbBalance.text = rexInfo.fund.balance.stringValue
            btnAction.setTitle("Buy REX", for: .normal)
            btnAction.isEnabled = rexInfo.fund.balance.quantity > 0
            btnAction.backgroundColor = Color.green.uiColor
            remainTimeView.isHidden = true
        case .sell:
            lbTitle.text = "REX Balance"
            let balanceText = rexInfo.balance.maturedRex.stringValue + " / " + rexInfo.balance.rexBalance.stringValue
            let attrString = NSMutableAttributedString(string: balanceText)
            attrString.addAttributeColor(text: rexInfo.balance.maturedRex.stringValue, color: Color.green.uiColor)
            lbBalance.attributedText = attrString
            btnAction.setTitle("Sell REX", for: .normal)
            btnAction.isEnabled = rexInfo.balance.maturedRex.quantity > 0
            btnAction.backgroundColor = Color.red.uiColor
            
            if rexInfo.balance.maturities.count > 0 {
                remainTimeView.isHidden = false
                if extraObserver != nil {
                    btnRemainTime.rx.singleTap
                        .bind(to: extraObserver!)
                        .disposed(by: bag)
                }
                
                let lastTimestamp = rexInfo.balance.maturities.last!.timestamp
                lbRemainTime.text = Date(timeIntervalSince1970: lastTimestamp).dataToLocalTime() + " >"
                
            } else {
                remainTimeView.isHidden = true
            }
        default:
            break
        }
    }
}


class RexUnstakeCell: UITableViewCell {
    @IBOutlet fileprivate weak var lbCPU: UILabel!
    @IBOutlet fileprivate weak var progressCPU: UIProgressView!
    @IBOutlet fileprivate weak var lbNET: UILabel!
    @IBOutlet fileprivate weak var progressNET: UIProgressView!
    @IBOutlet fileprivate weak var btnAction: UIButton!
    
    fileprivate var bag: DisposeBag?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = nil
    }
    
    func configure(account: AccountInfo, observer: AnyObserver<Void>) {
        lbCPU.text = account.cpuStakedEOS.dot4String + " EOS"
        progressCPU.setProgress(account.usedCPURatio, animated: true)
        lbNET.text = account.netStakedEOS.dot4String + " EOS"
        progressNET.setProgress(account.usedNetRatio, animated: true)
        
        let bag = DisposeBag()
        self.bag = bag
        btnAction.rx.singleTap
            .bind(to: observer)
            .disposed(by: bag)
        
    }
    
}
