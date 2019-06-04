//
//  RexViewController.swift
//  eoshub
//
//  Created by kein on 06/05/2019.
//  Copyright © 2019 EOS Hub. All rights reserved.
//

import Foundation
import RxSwift

class RexViewController: BaseTableViewController {
    
    var flowDelegate: RexFlowEventDelegate?
    
    fileprivate var depositSubject = PublishSubject<Void>()
    fileprivate var depositToRex = PublishSubject<Currency>()
    fileprivate var withdrawSubject = PublishSubject<Void>()
    fileprivate var withdrawFromRex = PublishSubject<Currency>()
    fileprivate var goToLend = PublishSubject<Void>()
    fileprivate var goToBorrow = PublishSubject<Void>()
    
    private let disposeBag = DisposeBag()
    
    fileprivate var account: AccountInfo!
    fileprivate var rexInfo: RexInfo!
    fileprivate var rexInfoSubject = RexInfoSubject(value: nil)
    
    enum CellType: Int, CaseIterable {
        case balance, fund, lend, borrow
    }
    
    fileprivate var items: [CellType] = [.fund, .balance, .lend, .borrow]
    
    deinit {
        Log.d("")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar(with: .basePurple, animated: animated, largeTitle: true)
        title = "REX"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
        loadData()
    }
    
    func configure(account: AccountInfo) {
        self.account = account
        rexInfo = RexInfo.empty(account: account.account)
    }
    
    private func setupUI() {
        let bgView = UIImageView(image: #imageLiteral(resourceName: "bgGrady"))
        bgView.alpha = 0.7
        tableView.backgroundView = bgView
        tableView.register(UINib(nibName: "RexFundCell", bundle: nil), forCellReuseIdentifier: "RexFundCell")
        tableView.register(UINib(nibName: "RexBalanceCell", bundle: nil), forCellReuseIdentifier: "RexBalanceCell")
    }
    
    private func bindActions() {
        goToLend.bind { [weak self] in
            guard let `self` = self else { return }
            guard let nc = self.navigationController else { return }
            self.flowDelegate?.goToLend(from: nc, rexInfo: self.rexInfoSubject)
        }
        .disposed(by: disposeBag)
        
        goToBorrow.bind { [weak self] in
            guard let `self` = self else { return }
            guard let nc = self.navigationController else { return }
            self.flowDelegate?.goToBorrow(from: nc, rexInfo: self.rexInfoSubject)
        }
        .disposed(by: disposeBag)
        
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
        return RxEOSAPI.getRexInfo(account: account.account)
            .flatMap({ [weak self](rexInfo) -> Observable<RexInfo> in
                self?.rexInfoSubject.onNext(rexInfo)
                return Observable.just(rexInfo)
            })
    }
}

extension RexViewController {
    func deposit() {
        DepositPopup.present(type: .deposit, availableEOS: Currency(balance: account.availableEOS), actionObserver: depositToRex.asObserver())
    }
    
    func withdraw() {
        DepositPopup.present(type: .withdraw, availableEOS: rexInfo.fund.balance, actionObserver: withdrawFromRex.asObserver())
    }
    
}

//MARK: UITableViewDataSource

extension RexViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellType = items[indexPath.row]
        
        switch cellType {
        case .balance:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RexBalanceCell", for: indexPath) as! RexBalanceCell
            if let balance = rexInfo?.balance {
                cell.configure(balance: balance)
            }
            return cell
        case .fund:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RexFundCell", for: indexPath) as! RexFundCell
            if let fund = rexInfo?.fund {
                cell.configure(fund: fund, depositObserver: depositSubject.asObserver(), withdrawObserver: withdrawSubject.asObserver())
            }
            
            return cell
        case .lend:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RexLendBorrowCell", for: indexPath) as! RexLendBorrowCell
            cell.configure(type: cellType, action: goToLend.asObserver())
            return cell
        case .borrow:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RexLendBorrowCell", for: indexPath) as! RexLendBorrowCell
            cell.configure(type: cellType, action: goToBorrow.asObserver())
            return cell
        }
        
    }
}



class RexLendBorrowCell: UITableViewCell {
    @IBOutlet fileprivate weak var lbTitle: UILabel!
    @IBOutlet fileprivate weak var lbText: UILabel!
    @IBOutlet fileprivate weak var btnAction: UIButton!
    
    private var bag: DisposeBag?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = nil
    }
    
    func configure(type: RexViewController.CellType, action: AnyObserver<Void>) {
        switch type {
        case .lend:
            lbTitle.text = "Buy / Sell REX"
            lbText.text = "Lend / Unlend EOS through REX"
            btnAction.setTitle("Lend / Unlend EOS", for: .normal)
        case .borrow:
            lbTitle.text = "Borrow CPU/NET"
            lbText.text = "Borrow CPU and Network resources from REX for 30 days"
            btnAction.setTitle("Borrow CPU/NET", for: .normal)
        default:
            break
        }
        
        let bag = DisposeBag()
        self.bag = bag
        btnAction.rx.singleTap
            .bind(to: action)
            .disposed(by: bag)
    }
}
