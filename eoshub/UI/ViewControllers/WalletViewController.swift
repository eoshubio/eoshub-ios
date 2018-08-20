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
import SDWebImage

class WalletViewController: BaseViewController {
    
    var flowDelegate: WalletFlowEventDelegate?
    
    @IBOutlet fileprivate var btnNotice: UIButton!
    @IBOutlet fileprivate var btnSetting: UIButton!
    @IBOutlet fileprivate var btnProfile: RoundedButton!
    
    @IBOutlet fileprivate var walletList: UITableView!
    
//    @IBOutlet fileprivate var btnRefresh: RoundedShadowButton!
    
    @IBOutlet fileprivate var topBar: UIView!
    
    @IBOutlet fileprivate var topBarHeight: NSLayoutConstraint!
    
    fileprivate var items: [[CellType]] = []
    
    fileprivate var rx_send = PublishSubject<AccountInfo>()
    fileprivate var rx_receive = PublishSubject<AccountInfo>()
    fileprivate var rx_menuClicked = PublishSubject<AccountInfo>()
    
    //refresh control
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(self.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        refreshControl.tintColor = Color.basePurple.uiColor
        
        return refreshControl
    }()
    
    private var initialized = false
    
    lazy var eoshubAccounts: Results<EHAccount> = {
        return DB.shared.getAccounts(userId : UserManager.shared.userId).sorted(byKeyPath: "created", ascending: true)
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if initialized == false {
            navigationController?.navigationBar.barStyle = .black
            initialized = true
            view.layoutIfNeeded()
            setupUI()
            bindActions()
            reloadUI()
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = ExchangeManager.shared
    }
    
    func show() {
       setNeedsStatusBarAppearanceUpdate()
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    private func setupUI() {
        
        let profileURL = UserManager.shared.profileURL
        btnProfile.imageView?.contentMode = .scaleAspectFill
        btnProfile.sd_setImage(with: profileURL, for: .normal, placeholderImage: #imageLiteral(resourceName: "profileDefault"),
                               options: [], completed: nil)
       
        walletList.contentInset = UIEdgeInsetsMake(Const.navBarHeightLargeState - Const.navBarHeightSmallState, 0, 100, 0)
        
        setupTableView()
    }
    
    private func setupTableView() {
        walletList.dataSource = self
        walletList.delegate = self
        walletList.rowHeight = UITableViewAutomaticDimension
        walletList.estimatedRowHeight = 60
    
        walletList.register(UINib(nibName: "WalletAddCell", bundle: nil), forCellReuseIdentifier: "WalletAddCell")
        
        walletList.register(UINib(nibName: "WalletCell", bundle: nil), forCellReuseIdentifier: "WalletCell")
        
        walletList.register(UINib(nibName: "TokenCell", bundle: nil), forCellReuseIdentifier: "TokenCell")
        
        walletList.register(UINib(nibName: "WalletGuideCell", bundle: nil), forCellReuseIdentifier: "WalletGuideCell")
        
        walletList.register(UINib(nibName: "WalletLockedCell", bundle: nil), forCellReuseIdentifier: "WalletLockedCell")
        
        walletList.addSubview(refreshControl)
    }
    
    private func reloadUI() {
        items.removeAll()
        
        if eoshubAccounts.count == 0 {
            items.append([WalletAddCellType.guide])
            items.append([WalletAddCellType.add])
        } else {
            AccountManager.shared.infos
                .forEach { (info) in
                    let TokenBalanceInfos = info.tokens
                        .map { TokenBalanceInfo(owner: info, token: $0.token) }
//                        .filter({$0.quantity > 0})
                    
                    let sectionItem: [CellType] = [info] + TokenBalanceInfos
                    items.append(sectionItem)
                }
                        
            eoshubAccounts.filter("account = ''")
                .forEach { (ehaccount) in
                    items.append([InactiveWallet(account: ehaccount)])
                }
            
            items.append([WalletAddCellType.add])
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
                guard let nc = self?.navigationController else { return }
                self?.flowDelegate?.goToSetting(from: nc)
            }
            .disposed(by: bag)
        
        rx_send
            .subscribe(onNext: { [weak self](account) in
                guard let nc = self?.navigationController else { return }
                self?.flowDelegate?.goToSend(from: nc, with: account)
            })
            .disposed(by: bag)
        
        rx_receive
            .subscribe(onNext: { [weak self](account) in
                guard let nc = self?.navigationController else { return }
                self?.flowDelegate?.goToReceive(from: nc, with: account)
            })
            .disposed(by: bag)
        
        rx_menuClicked
            .subscribe(onNext: { [weak self] (account) in
                self?.addTokens(account: account)
            })
            .disposed(by: bag)
        
//        btnRefresh.rx.singleTap
//            .flatMap({ (_) -> Observable<Void> in
//                return AccountManager.shared.loadAccounts()
//            })
//            .subscribe()
//            .disposed(by: bag)
        
        
        AccountManager.shared.loadAccounts()
            .subscribe()
            .disposed(by: bag)
        
    }
    
    fileprivate func addTokens(account: AccountInfo) {
        guard let ehaccount = AccountManager.shared.getAccount(accountName: account.account),
        let nc = navigationController else { return }
        
        flowDelegate?.goToAddToken(from: nc, with: ehaccount)

    }
    
    fileprivate func openMenu(account: AccountInfo) {
        
//        let sheet = UIAlertController(title: account.account, message: "", preferredStyle: .actionSheet)
//
//        let addToken = UIAlertAction(title: LocalizedString.Wallet.Option.addToken, style: .default) { [weak self](_) in
//            guard let ehaccount = AccountManager.shared.getAccount(accountName: account.account),
//                let nc = self?.navigationController else { return }
//
//            self?.flowDelegate?.goToAddToken(from: nc, with: ehaccount)
//        }
//        sheet.addAction(addToken)
//
//        if account.ownerMode == false {
//            let delete = UIAlertAction(title: LocalizedString.Wallet.Option.delete, style: .destructive) { [weak self] (_) in
//                self?.deleteWallet(account: account.account)
//            }
//
//            sheet.addAction(delete)
//        }
//
//
//
//        sheet.addAction(UIAlertAction(title: LocalizedString.Common.cancel, style: .cancel, handler: nil))
//
//        present(sheet, animated: true, completion: nil)
    }
    
    fileprivate func deleteWallet(account: String) {
        DB.shared.deleteAccount(account: account, userId: UserManager.shared.userId)
        
        AccountManager.shared.doLoadAccount()
    }
    
    @objc fileprivate func handleRefresh(_ refreshControl: UIRefreshControl) {
        
        let minWaitTime: TimeInterval = 5
        let curTime = Date().timeIntervalSince1970
        if fabs(curTime - Preferences.shared.lastRefreshTime) > minWaitTime {
            Preferences.shared.lastRefreshTime = curTime
            AccountManager.shared.loadAccounts()
                .subscribe {
                    refreshControl.endRefreshing()
                }
                .disposed(by: bag)
        } else {
            Log.i("ignore")
            refreshControl.endRefreshing()
        }
        
        
    }
}


extension WalletViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = items[indexPath.section][indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: item.nibName) else {
            preconditionFailure()
        }
        
        if item is AccountInfo {
            guard let cell = cell as? WalletCell, let item = item as? AccountInfo else { preconditionFailure() }
            cell.configure(viewModel: item, sendObserver: rx_send, receiveObserver: rx_receive, menuObserver: rx_menuClicked)
            cell.selectionStyle = .none
            return cell
        } else if item is TokenBalanceInfo {
            guard let cell = cell as? TokenCell, let item = item as? TokenBalanceInfo else { preconditionFailure() }
            let ownerMode = item.owner.ownerMode
            cell.configure(currency: item.currency, ownerMode: ownerMode)
            cell.selectionStyle = .none
            return cell
        } else {
            cell.selectionStyle = .none
        }
        
        return cell
    }
    
}


extension WalletViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let v = UIView()
        v.backgroundColor = UIColor.clear
        return v
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        guard let nc = navigationController else { return }
        
        let item = items[indexPath.section][indexPath.row]
        if let item = item as? AccountInfo {
            //go to wallet detail
            flowDelegate?.goToWalletDetail(from: nc, with: item)
        } else if let item = item as? TokenBalanceInfo {
            if item.owner.ownerMode {
                flowDelegate?.goToTokenDetail(from: nc, with: item)
            }
            
        } else if let item = item as? InactiveWallet {
            let account = item.ehaccount
            let pubKey = account.publicKey
            //Test it
            WaitingView.shared.start()
            RxEOSAPI.getAccountFromPubKey(pubKey: pubKey)
                .flatMap({ (accountName) -> Observable<EHAccount> in
                    DB.shared.safeWrite {
                        account.account = accountName
                    }
                    
                    return AccountManager.shared.loadAccount(account: account)
                        .flatMap({ (_) -> Observable<EHAccount> in
                            return Observable.just(account)
                        })
                })
                .subscribe(onCompleted: {
                    //reload
                    AccountManager.shared.refreshUI()
                }) {
                    Log.i("disposed")
                    WaitingView.shared.stop()
                }
                .disposed(by: bag)

        } else if item is WalletAddCellType {
            //go to create wallet
            flowDelegate?.goToCreate(from: nc)
        }
    }
}

extension WalletViewController: UIScrollViewDelegate {
    fileprivate struct Const {
        /// Image height/width for Large NavBar state
        static let imageSizeForLargeState: CGFloat = 54
        /// Margin from right anchor of safe area to right anchor of Image
        static let imageSideMargin: CGFloat = 24
        /// Margin from bottom anchor of NavBar to bottom anchor of Image for Large NavBar state
        static let imageBottomMarginForLargeState: CGFloat = 12
        /// Margin from bottom anchor of NavBar to bottom anchor of Image for Small NavBar state
        static let imageBottomMarginForSmallState: CGFloat = 6
        /// Image height/width for Small NavBar state
        static let imageSizeForSmallState: CGFloat = 40
        /// Height of NavBar for Small state. Usually it's just 44
        static let navBarHeightSmallState: CGFloat = 48
        /// Height of NavBar for Large state. Usually it's just 96.5 but if you have a custom font for the title, please make sure to edit this value since it changes the height for Large state of NavBar
        static let navBarHeightLargeState: CGFloat = 96.5
    }
    
    private func moveAndResizeImage(for height: CGFloat) {
        let coeff: CGFloat = {
            let delta = height - Const.navBarHeightSmallState
            let heightDifferenceBetweenStates = (Const.navBarHeightLargeState - Const.navBarHeightSmallState)
            return delta / heightDifferenceBetweenStates
        }()
        
        let factor = Const.imageSizeForSmallState / Const.imageSizeForLargeState
        
        let scale: CGFloat = {
            let sizeAddendumFactor = coeff * (1.0 - factor)
            return min(1.0, sizeAddendumFactor + factor)
        }()
        
        topBarHeight.constant = height
        topBar.superview?.layoutIfNeeded()
        
        // Value of difference between icons for large and small states
//        let sizeDiff = Const.imageSizeForLargeState * (1.0 - factor) // 8.0
        
        btnProfile.transform = CGAffineTransform.identity
            .scaledBy(x: scale, y: scale)
        
        
        
//            .translatedBy(x: xTranslation, y: yTranslation)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y + scrollView.contentInset.top
        
        let height = min(max(Const.navBarHeightLargeState - offset, Const.navBarHeightSmallState), Const.navBarHeightLargeState )

        moveAndResizeImage(for: height)
    }
    
}
