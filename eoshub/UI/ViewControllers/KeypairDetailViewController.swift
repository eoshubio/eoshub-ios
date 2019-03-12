//
//  KeypairDetailViewController.swift
//  eoshub
//
//  Created by kein on 2018. 9. 15..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import RxSwift

class KeypairDetailViewController: BaseTableViewController {
    
    fileprivate var account: AccountInfo!
    fileprivate var permission: Permission!
    fileprivate var btnApplyItem: UIBarButtonItem?
    fileprivate let form = KeypairGenerateForm()
    
    //TODO: It would be better to integrate and manage the definition of the key used in EOSHub.
    fileprivate struct Key: Equatable {
        let key: String
        let permission: String
        let stored: Bool
        let repo: KeyRepository
    }
    
    fileprivate var storedKeys: [Key] = []
    fileprivate var keys: [Key] = [] {
        didSet {
            updateApplyItem()
        }
    }
    fileprivate var repos: [KeyRepository] = [.secureEnclave, .iCloudKeychain]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        bindActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar(with: .basePurple, animated: animated, largeTitle: true)
        switch permission! {
        case .owner:
            title = "Onwer Keys"
        case .active:
            title = "Active Keys"
        default:
            break
        }
        
        btnApplyItem = UIBarButtonItem(title: LocalizedString.Common.apply, style: .done, target: self, action: #selector(self.applyUpdateAuth))
        btnApplyItem?.isEnabled = false
        navigationItem.rightBarButtonItem = btnApplyItem
    }
    
    func configure(account: AccountInfo, permission: Permission) {
        self.account = account
        self.permission = permission
    }
    
    private func setupUI() {
        
    }
    
    private func setupData() {
        loadData()
        keys = storedKeys
    }
    
    private func loadData() {
        if permission == .owner {
            let ownerKeys = account.storedKeys.filter({ $0.permission == .owner })
                .map { (storedKey) -> Key in
                    return Key(key: storedKey.eosioKey.key, permission: Permission.owner.value, stored: true, repo: storedKey.repo)
                }
            storedKeys = ownerKeys
            
        } else if permission == .active {
            let activeKeys = account.storedKeys.filter({ $0.permission == .active })
                .map { (storedKey) -> Key in
                    return Key(key: storedKey.eosioKey.key, permission: Permission.owner.value, stored: true, repo: storedKey.repo)
            }
            storedKeys = activeKeys
        }
    }
    
    private func bindActions() {
        form.delete
            .bind(onNext: deleteKey)
            .disposed(by: bag)
        
        form.generate
            .bind(onNext: generateKey)
            .disposed(by: bag)
        
        AccountManager.shared.accountInfoRefreshed
            .bind { [weak self] in
                guard let `self` = self, let info = AccountManager.shared.queryAccountInfo(by: self.account.account) else { return }
                self.configure(account: info, permission: self.permission)
                self.setupData()
                self.tableView.reloadData()
                self.updateApplyItem()
            }
            .disposed(by: bag)
    }
    
    @objc private func applyUpdateAuth() {
        
        WaitingView.shared.start()
        guard let permission = self.permission else { return }
        let keys = self.keys.map { $0.key }
        let auth = Authority(keys: keys, perm: permission)
        
        guard let highestPriorityKey = account.highestPriorityKey else { return }
        
        let wallet = Wallet(key: highestPriorityKey.eosioKey.key, parent: self)
        
        WaitingView.shared.start()
        RxEOSAPI.updateAuth(account: account.account,
                            permission: permission,
                            auth: auth, wallet: wallet,
                            authorization: Authorization(actor: account.account, permission: highestPriorityKey.permission))
            .flatMap({ (_) -> Observable<Void> in
                return AccountManager.shared.loadAccounts()
            })
            .subscribe(onNext: { (_) in
               
            }, onError: { (error) in
                if error is PrettyPrintedPopup {
                    (error as! PrettyPrintedPopup).showPopup()
                }
            }, onCompleted: {
                Log.i("completed")
                 Popup.present(style: .success, description: LocalizedString.Tx.success)
            }) {
                Log.i("disposed")
                WaitingView.shared.stop()
        }
        .disposed(by: bag)
        
    }
    
    /// This is a function that changes the state of the apply button by checking whether the authority needs to be updated. A way to check if an update is needed is by comparing it with stored keys.
    private func updateApplyItem() {
        btnApplyItem?.isEnabled = checkHasUpdate()
    }
    
    private func checkHasUpdate() -> Bool {
        
        if keys.count == storedKeys.count {
            let compareFunc: (Key,Key) -> Bool = { (lhs, rhs) in
                return lhs.key < rhs.key
            }
            
            let lhs = storedKeys.sorted(by: compareFunc)
            let rhs = keys.sorted(by: compareFunc)
            
            for i in 0..<lhs.count {
                if lhs[i] != rhs[i] {
                    return true
                }
            }
            
            return false
        } else {
            return true
        }
        
    }
}

extension KeypairDetailViewController {
    fileprivate func generateKey(repo: KeyRepository) {
        if let pubKey = Security.shared.generatePrivateKey(in: repo) {
            let key = Key(key: pubKey, permission: permission.value, stored: false, repo: repo)
            keys = keys + [key]
        } else {
            EOSHubError.failedToSignature.showPopup()
        }
        tableView.reloadData()
    }
    
    fileprivate func deleteKey(key: String) {
        keys = keys.filter({$0.key != key})
        tableView.reloadData()
    }
}

extension KeypairDetailViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return keys.count
        } else {
            return repos.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "KeyCell", for: indexPath) as? KeyCell else {
                preconditionFailure()
            }
            
            let key = keys[indexPath.row]
            
            cell.configure(pubKey: key.key, owner: key.stored, repo: key.repo, observer: form.delete.asObserver())
            return cell
            
        } else if indexPath.section == 1 {
            
            let repo = repos[indexPath.row]
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "KeypairAddCell", for: indexPath) as? KeypairAddCell else { preconditionFailure() }
            
            cell.configure(repo: repo, observer: form.generate.asObserver())
            
            return cell
        } else {
            preconditionFailure()
        }
    }
}

class KeypairAddCell: UITableViewCell {
    @IBOutlet fileprivate weak var lbTitle: UILabel!
    @IBOutlet fileprivate weak var lbDescription: UILabel!
    @IBOutlet fileprivate weak var btnIcon: UIButton!
    @IBOutlet fileprivate weak var btnMore: UIButton!
    @IBOutlet fileprivate weak var btnGenerate: UIButton!
    
    private var bag: DisposeBag? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = nil
    }
    
    private func setupUI() {
        btnMore.setTitle(LocalizedString.Create.Account.seDetail, for: .normal)
        btnGenerate.setTitle(LocalizedString.Common.generate, for: .normal)
    }
    
    func configure(repo: KeyRepository, observer: AnyObserver<KeyRepository>) {
        let bag = DisposeBag()
        self.bag = bag
        
        let detailURLString: String
        
        switch repo {
        case .secureEnclave:
            lbTitle.text = LocalizedString.Create.Account.seTitle
            lbDescription.text = LocalizedString.Create.Account.seText
            detailURLString = URLs.secureEnclave
            btnIcon.setImage(#imageLiteral(resourceName: "shield"), for: .normal)
            btnIcon.tintColor = Color.progressMagenta.uiColor
        case .iCloudKeychain:
            lbTitle.text = LocalizedString.Create.Account.genTitle
            lbDescription.text = LocalizedString.Create.Account.genText
            detailURLString = URLs.iCloudKeychain
            btnIcon.setImage(#imageLiteral(resourceName: "keychain"), for: .normal)
            btnIcon.tintColor = Color.progressOrange.uiColor
        default:
            preconditionFailure()
        }
        
        btnGenerate.rx.singleTap
            .bind {
                observer.onNext(repo)
            }
            .disposed(by: bag)
        
        btnMore.rx.singleTap
            .bind {
                guard let url =  URL(string: detailURLString) else { return }
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            .disposed(by: bag)
    }
    
}

struct KeypairGenerateForm {
    let generate = PublishSubject<KeyRepository>()
    let delete = PublishSubject<String>()
}









