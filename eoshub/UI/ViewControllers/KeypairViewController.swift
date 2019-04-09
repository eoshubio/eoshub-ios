//
//  KeypairViewController.swift
//  eoshub
//
//  Created by kein on 2018. 8. 20..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class KeypairViewController: BaseTableViewController {
    
    var flowDelegate: KeypairFlowEventDelegate?
    
    fileprivate var account: AccountInfo!
    
    fileprivate struct Key {
        let key: String
        let permission: String
        let stored: Bool
        let repo: KeyRepository
    }
    
    fileprivate var items: [[Key]] = []
    
    fileprivate var rx_onOwnerKey = PublishSubject<Void>()
    fileprivate var rx_onActiveKey = PublishSubject<Void>()
    
    deinit {
        Log.i("deinit")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar(with: .basePurple, animated: animated, largeTitle: true)
        title = LocalizedString.Wallet.Detail.keypairs
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        setupUI()
        bindActions()
    }
    
    func configure(account: AccountInfo) {
        self.account = account
    }
    
    private func loadData() {
        
        items.removeAll()
        
        let secure = Security.shared
        let ownerKeys = account.ownerKeys.map { (key) -> KeypairViewController.Key in
            let repo = secure.getKeyRepository(pub: key)
            let stored = repo != .none
            return Key(key: key, permission: Permission.owner.value, stored: stored, repo: repo)
        }
        items.append(ownerKeys)
        let activeKeys = account.activeKeys.map { (key) -> KeypairViewController.Key in
            let repo = secure.getKeyRepository(pub: key)
            let stored = repo != .none
            return Key(key: key, permission: Permission.active.value, stored: stored, repo: repo)
        }
        items.append(activeKeys)
        
    }
    
    private func setupUI() {
        tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 20, right: 0)
        
        let headerNib = UINib(nibName: "KeyHeader", bundle: nil)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: "KeyHeader")
    }
    
    private func bindActions() {
        rx_onOwnerKey
            .bind { [weak self] in
                guard let nc = self?.navigationController else { return }
                self?.flowDelegate?.goToDetail(from: nc, permission: .owner)
            }
            .disposed(by: bag)
        
        rx_onActiveKey
            .bind { [weak self] in
                guard let nc = self?.navigationController else { return }
                self?.flowDelegate?.goToDetail(from: nc, permission: .active)
            }
            .disposed(by: bag)
        
        AccountManager.shared.accountInfoRefreshed
            .bind { [weak self] in
                guard let `self` = self, let info = AccountManager.shared.queryAccountInfo(by: self.account.account) else { return }
                self.configure(account: info)
                self.loadData()
                self.tableView.reloadData()
            }
            .disposed(by: bag)
    }
    
    @objc private func toggleEditMode(sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    

    
}


extension KeypairViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].count
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as? KeyHeader
        let editable = items[0].filter({ $0.stored }).count > 0
        switch section {
        case 0:
            headerView?.configure(permission: .owner, editable: editable, observer: rx_onOwnerKey.asObserver())
        case 1:
            headerView?.configure(permission: .active, editable: editable, observer: rx_onActiveKey.asObserver())
        default:
            break
        }
    }

    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: "KeyHeader")
    }
  
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "KeyCell", for: indexPath) as? KeyCell else {
            preconditionFailure()
        }
        
        let key = items[indexPath.section][indexPath.row]
        
        cell.configure(pubKey: key.key, owner: key.stored, repo: key.repo)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key = items[indexPath.section][indexPath.row]
        showActionSheet(for: key)
    }
    
    fileprivate func showActionSheet(for key: KeypairViewController.Key) {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        switch key.repo {
        case .iCloudKeychain:
            sheet.title = LocalizedString.Keypair.Export.title
            sheet.message = LocalizedString.Keypair.Export.text
            
            sheet.addAction(UIAlertAction(title: LocalizedString.Keypair.Export.action,
                                          style: .default, handler: { [weak self] (action) in
                //go to pin check
                guard let self = self else { return }
                self.authentication(showAt: self)
                      .subscribe(onNext: { [weak self] (confirmed) in
                        if confirmed {
                            //1. export private key
                            let pubKey = key.key
                            if let priKey = Security.shared.getEncryptedPrivateKey(pub: pubKey) {
                                let shareText = "Public Key:\n\(pubKey)\n\nPrivate Key:\n\(priKey)"
                                self?.shareText(text: shareText)
                            } else {
                                //cannot export private key
                                Popup.present(style: .failed, description: "Failed to decrypt private key")
                            }
                        }
                    }, onError: { (error) in
                        Log.e(error)
                    }, onCompleted: {
                        Log.i("onCompleted")
                    }) {
                        Log.i("disposed")
                    }
                    .disposed(by: self.bag)
                
            }))
            sheet.addAction(UIAlertAction(title: LocalizedString.Common.cancel, style: .cancel, handler: nil))
            
            
        case .secureEnclave:
            sheet.title = LocalizedString.Keypair.SE.title
            sheet.message = LocalizedString.Keypair.SE.text
            sheet.addAction(UIAlertAction(title: LocalizedString.Common.ok, style: .cancel, handler: nil))
        case .none:
            sheet.title = LocalizedString.Keypair.Import.title
            sheet.message = LocalizedString.Keypair.Import.text
            sheet.addAction(UIAlertAction(title: LocalizedString.Keypair.Import.action, style: .default, handler: { [weak self] (action) in
                //go to import key
                guard let nc = self?.navigationController else { return }
                self?.flowDelegate?.goImportPrivateKey(from: nc)
            }))
            sheet.addAction(UIAlertAction(title: LocalizedString.Common.cancel, style: .cancel, handler: nil))
        }
        
        
        present(sheet, animated: true, completion: nil)
    }
    
    fileprivate func authentication(showAt vc: UIViewController) -> Observable<Bool> {
        let config = FlowConfigure(container: vc, parent: nil, flowType: .modal)
        let fc = ValidatePinFlowController(configure: config)
        fc.start(animated: true)
        
        return fc.validated.asObservable()
    }
    
    fileprivate func shareText(text: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let self = self else { return }
            let textShare = [ text ]
            let activityViewController = UIActivityViewController(activityItems: textShare , applicationActivities: nil)
            self.present(activityViewController, animated: true, completion: nil)
        }
        
    }

}


class KeyCell: UITableViewCell {
    
    @IBOutlet fileprivate weak var stored: BorderColorButton!
    @IBOutlet fileprivate weak var repo: BorderColorButton!
    @IBOutlet fileprivate weak var key: UILabel!
    @IBOutlet fileprivate weak var delete: UIButton?
    @IBOutlet fileprivate weak var btnCopy: UIButton?
    
    private var bag: DisposeBag?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = nil
    }
    
    private func setupUI() {
        stored.setThemeColor(fgColor: Color.green.uiColor, bgColor: .clear, state: .normal, border: true)
        stored.setThemeColor(fgColor: Color.lightGray.uiColor, bgColor: .clear, state: .selected, border: true)
        
        repo.setThemeColor(fgColor: Color.progressOrange.uiColor, bgColor: .clear, state: .normal, border: true)
        repo.setThemeColor(fgColor: Color.progressMagenta.uiColor, bgColor: .clear, state: .selected, border: true)
    }
    
    func configure(pubKey: String, owner: Bool, repo storedAt: KeyRepository, observer: AnyObserver<String>? = nil) {
        let bag = DisposeBag()
        self.bag = bag
        
        key.text = pubKey
        if owner {
            stored.setTitle("Stored", for: .normal)
            stored.isSelected = false
        } else {
            stored.setTitle("Not Stored", for: .normal)
            stored.isSelected = true
        }
        
        switch storedAt {
        case .iCloudKeychain:
            repo.isHidden = false
            repo.isSelected = false
            repo.setTitle("iCloud Keychain", for: .normal)
        case .secureEnclave:
            repo.isHidden = false
            repo.isSelected = true
            repo.setTitle("Secure enclave", for: .normal)
        default:
            repo.isHidden = true
        }
        
        delete?.isHidden = (owner == false)
        delete?.rx.singleTap
            .bind {
                observer?.onNext(pubKey)
        }
        .disposed(by: bag)
        
        btnCopy?.rx.singleTap
            .bind {
                UIPasteboard.general.string = pubKey
                Popup.present(style: .success, description: LocalizedString.Common.copied)
            }
            .disposed(by: bag)
    }
    
    
}


class KeyHeader: UITableViewHeaderFooterView {
    @IBOutlet fileprivate weak var lbTitle: UILabel!
    @IBOutlet fileprivate weak var btnAdd: UIButton!
    @IBOutlet fileprivate weak var lbEdit: UILabel!
    @IBOutlet fileprivate weak var btnHeader: UIButton!
    
    private var bag: DisposeBag?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = nil
    }
    
    private func setupUI() {
        btnAdd.setTitle(LocalizedString.Common.addShort, for: .normal)
        lbEdit.text = LocalizedString.Common.edit
    }
    
    func configure(permission: Permission, editable: Bool, observer: AnyObserver<Void>) {
        let bag = DisposeBag()
        self.bag = bag
        
        lbTitle.text = permission.value.capitalized
        
        btnHeader.isEnabled = editable
        btnAdd.isHidden = !btnHeader.isEnabled
        lbEdit.isHidden = !btnHeader.isEnabled
        
        btnHeader.rx.singleTap
            .bind {
                observer.onNext(())
            }
            .disposed(by: bag)
        
    }
    
}










