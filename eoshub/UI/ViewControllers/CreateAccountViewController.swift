//
//  CreateAccountViewController.swift
//  eoshub
//
//  Created by kein on 2018. 8. 10..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RealmSwift
import FirebaseAuth

class CreateAccountViewController: BaseTableViewController {
    
    var flowDelegate: CreateAccountFlowEventDelegate?
    
    var requestForm = CreateAccountForm()
    
    var userId: String {
        return UserManager.shared.userId
    }
    
    fileprivate var request: CreateAccountRequest!
    
    enum CellType {
        case accountName, ownerKey, activeKey, next
    }
    var items: [CellType] = [.accountName, .next]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar(with: .basePurple, animated: animated, largeTitle: true)
        title = LocalizedString.Create.Account.title + " (1/3)"
        addBackButton()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.refresh))
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
    }
    
    func configure(request: CreateAccountRequest) {
        self.request = request
    }
    
    @objc func refresh() {
        request.clearAccountInfo()
        reloadFromCurrentRequest()
        tableView.reloadData()
        
    }
    
    private func setupUI() {
        EHAnalytics.trackEvent(event: .try_create_account1)
        reloadFromCurrentRequest()
    }
    
    private func reloadFromCurrentRequest() {
        
        requestForm.validatedAccount.value = request.name
        
        if request.currentStage.rawValue >= CreateAccountRequest.Stage.accountCheck.rawValue {
            requestForm.validatedOwnerKey.value = request.ownerKey
            requestForm.validatedActiveKey.value = request.activeKey
            
            switch request.ownerKeyFrom {
            case .secureEnclave:
                requestForm.createOwnerKeyMode.value = .secureEnclave
            case .iCloudKeychain:
                requestForm.createOwnerKeyMode.value = .iCloudKeychain
            case .imported:
                requestForm.createOwnerKeyMode.value = .imported
            default:
                break
            }
            
            switch request.activeKeyFrom {
            case .secureEnclave:
                requestForm.createActiveKeyMode.value = .secureEnclave
            case .iCloudKeychain:
                requestForm.createActiveKeyMode.value = .iCloudKeychain
            case .imported:
                requestForm.createActiveKeyMode.value = .imported
            default:
                break
            }
            
            items = [.accountName, .ownerKey, .activeKey, .next]
            
        } else {
            requestForm.clear()
            items = [.accountName, .next]
        }
    }
    
    private func bindActions() {
        requestForm.accountCheck
            .bind { [weak self] (name) in
                self?.checkAccount(name: name)
            }
            .disposed(by: bag)
        
        requestForm.createOwnerKeyMode.asObservable()
            .bind { [weak self] (mode) in

                let contentOffset = self?.tableView.contentOffset ?? .zero
                self?.tableView.reloadData()
                self?.tableView.layoutIfNeeded()
                self?.tableView.setContentOffset(contentOffset, animated: false)
            }
            .disposed(by: bag)
        
        requestForm.createActiveKeyMode.asObservable()
            .bind { [weak self] (mode) in
                let contentOffset = self?.tableView.contentOffset ?? .zero
                self?.tableView.reloadData()
                self?.tableView.layoutIfNeeded()
                self?.tableView.setContentOffset(contentOffset, animated: false)
            }
            .disposed(by: bag)
        
        requestForm.next.asObservable()
            .bind { [weak self] in
                self?.goToCheck()
                
            }
            .disposed(by: bag)
        
    }
    
    private func goToCheck() {
        
        let accountName = requestForm.validatedAccount.value
        var ownerKey: String
        var activeKey: String
        let ownerKeyFrom = requestForm.createOwnerKeyMode.value
        let activeKeyFrom = requestForm.createActiveKeyMode.value
        
        switch requestForm.createOwnerKeyMode.value {
        case .iCloudKeychain:
            if request.ownerKeyFrom == .iCloudKeychain , request.activeKey.count > 0 {
                //skip
                ownerKey = request.ownerKey
            } else {
                guard let key = Security.shared.generatePrivateKey(in: .iCloudKeychain) else {
                    Popup.present(style: .failed, description: "generatePrivateKey")
                    return
                }
                ownerKey = key
            }
        case .imported:
            ownerKey = requestForm.validatedOwnerKey.value
        default:
            preconditionFailure("not implemented")
        }
        
        
        switch requestForm.createActiveKeyMode.value {
        case .secureEnclave:
            
            if request.activeKeyFrom == .secureEnclave, request.activeKey.count > 0 {
                //skip
                activeKey = request.activeKey
            } else {
                    guard let pubkeyFromSecureEnclave = Security.shared.generatePrivateKey(in: .secureEnclave) else {
                        Popup.present(style: .failed, description: "Cannot generate key from Secure enclave")
                        return
                }
                activeKey = pubkeyFromSecureEnclave
            }
            
        case .imported:
            activeKey = requestForm.validatedActiveKey.value
        default:
            preconditionFailure("Not implemented")
        }
        
        
        request.changeAccountInfo(accountName: accountName,
                                  ownerKey: ownerKey, ownerKeyFrom: ownerKeyFrom,
                                  activeKey: activeKey, activeKeyFrom: activeKeyFrom)
 
        guard let nc = navigationController else { return }
        flowDelegate?.goInfo(from: nc, request: request)
    }
    
    private func checkAccount(name: String) {
        WaitingView.shared.start()
        RxEOSAPI.getAccount(name: name)
            .subscribe(onNext: { [weak self](_) in
                //failed
                self?.requestForm.validatedAccount.value = ""
                let text = String(format: LocalizedString.Create.Check.failed, name)
                Popup.present(style: .failed, description: text)
                
            }, onError: { [weak self](error) in
                guard let error = error as? EOSResponseError else { return }
                if error.isUnkonwKey {
                    self?.requestForm.validatedAccount.value = name
                    let text = String(format: LocalizedString.Create.Check.success, name)
                    Popup.present(style: .success, description: text)
                    //Add create key cell
                    let prvItemCount = self?.items.count ?? 0
                    if prvItemCount == 2 {
                        self?.items = [.accountName, .ownerKey, .activeKey, .next]
                        self?.tableView.insertRows(at: [IndexPath(row: 1, section: 0), IndexPath(row: 2, section: 0)], with: .fade)
                    }
                } else {
                    //exception
                    self?.requestForm.validatedAccount.value = ""
                    error.showErrorPopup()
                    //Add create key cell
                    let prvItemCount = self?.items.count ?? 0
                    if prvItemCount == 2 {
                        self?.items = [.accountName, .ownerKey, .activeKey, .next]
                        self?.tableView.insertRows(at: [IndexPath(row: 1, section: 0), IndexPath(row: 2, section: 0)], with: .fade)
                    }
                }
            }) {
                WaitingView.shared.stop()
            }
            .disposed(by: bag)
        
    }
    
}

extension CreateAccountViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        switch item {
        case .accountName:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CreateAccountNameCell", for: indexPath) as? CreateAccountNameCell else { preconditionFailure() }
            cell.configure(form: requestForm)
            return cell
        case .ownerKey:
            if requestForm.createOwnerKeyMode.value == .iCloudKeychain {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "CreateOwnerKeyCell", for: indexPath) as? CreateOwnerKeyCell else { preconditionFailure() }
                cell.configure(form: requestForm)
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "InsertOwnerKeyCell", for: indexPath) as? InsertOwnerKeyCell else { preconditionFailure() }
                cell.configure(form: requestForm)
                return cell
            }
        case .activeKey:
            if requestForm.createActiveKeyMode.value == .secureEnclave {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "CreateActiveKeysCell", for: indexPath) as? CreateActiveKeysCell else { preconditionFailure() }
                cell.configure(form: requestForm)
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "InsertActiveKeyCell", for: indexPath) as? InsertActiveKeyCell else { preconditionFailure() }
                cell.configure(form: requestForm)
                return cell
            }
            
        case .next:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CreateAccountNextCell", for: indexPath) as? CreateAccountNextCell else { preconditionFailure() }
            cell.configure(form: requestForm)
            return cell
        }
      
    }
}

//MARK: Cells
class CreateAccountNameCell: UITableViewCell {
    @IBOutlet fileprivate weak var lbTitle:UILabel!
    @IBOutlet fileprivate weak var txtAccountName: WhiteAccountTextField!
    @IBOutlet fileprivate weak var lbAccountLength: UILabel!
    @IBOutlet fileprivate weak var lbAccountRule: UILabel!
    @IBOutlet fileprivate weak var seqCheck: BorderColorButton!
    @IBOutlet fileprivate weak var btnDuplicateCheck: BorderColorButton!
    
    private var lastValidatedAccount = ""
    private let rx_seqState = BehaviorSubject<SeqState>(value: .editing)
    
    private var bag: DisposeBag? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        bindActions()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = nil
    }
    
    deinit {
        Log.i("deinit")
    }
    
    private func setupUI() {
        
        lbTitle.text = LocalizedString.Create.Account.name
        txtAccountName.placeholder = LocalizedString.Create.Account.enter
        lbAccountRule.text = LocalizedString.Create.Account.rules
        btnDuplicateCheck.setTitle(LocalizedString.Create.Account.check, for: .normal)
        btnDuplicateCheck.setTitle(LocalizedString.Create.Account.checked, for: .selected)
        
        lbAccountLength.textColor = Color.lightGray.uiColor
        
        seqCheck.isUserInteractionEnabled = false
        seqCheck.setThemeColor(fgColor: Color.lightGray.uiColor, bgColor: .clear, state: .normal, border: true)
        seqCheck.setThemeColor(fgColor: Color.green.uiColor, bgColor: .clear, state: .selected, border: true)
        seqCheck.setThemeColor(fgColor: Color.red.uiColor, bgColor: .clear, state: .disabled, border: true)
        
        btnDuplicateCheck.setThemeColor(fgColor: Color.lightPurple.uiColor, bgColor: .clear, state: .normal, border: true)
        btnDuplicateCheck.setThemeColor(fgColor: Color.lightGray.uiColor, bgColor: .clear, state: .disabled, border: true)
        btnDuplicateCheck.setThemeColor(fgColor: Color.green.uiColor, bgColor: .clear, state: .selected, border: true)
        
        btnDuplicateCheck.isEnabled = false

        txtAccountName.padding.right = lbAccountLength.bounds.width + 20
    }
    
    private func bindActions() {
        _ = txtAccountName.rx.text.orEmpty
                .bind { [weak self](name) in
                    self?.setAccountLength(name: name)
                }
        
        _ = rx_seqState
                .bind { [weak self] (state) in
                    self?.changeSeqState(state: state)
                }
    }
    
    func configure(form: CreateAccountForm) {
        let bag = DisposeBag()
        self.bag = bag
        txtAccountName.text = form.validatedAccount.value
        
        lastValidatedAccount = form.validatedAccount.value
        
        
        form.validatedAccount.asObservable()
            .bind { [weak self] (validatedAccount) in
                self?.setAccountLength(name: validatedAccount)
                let state: SeqState = validatedAccount.count > 0 ? .pass : .editing
                self?.lastValidatedAccount = validatedAccount
                self?.rx_seqState.onNext(state)
                self?.btnDuplicateCheck.isSelected = (state == .pass)
                if validatedAccount.count > 0 {
                    self?.btnDuplicateCheck.isEnabled = true
                }
            }
            .disposed(by: bag)
        
        
        btnDuplicateCheck.rx.singleTap
            .bind { [weak self] in
                self?.txtAccountName.resignFirstResponder()
                let accountName = self?.txtAccountName.text ?? ""
                if form.validatedAccount.value != accountName {
                    form.accountCheck.onNext(accountName)
                }
            }
            .disposed(by: bag)
    }
    
    private func setAccountLength(name: String) {
        lbAccountLength.text = "\(name.count)/12"
        
        btnDuplicateCheck.isEnabled = false
        btnDuplicateCheck.isSelected = false
        
        if txtAccountName.hasWrongChar {
            seqCheck.isEnabled = false
            rx_seqState.onNext(.fail)
            lbAccountLength.textColor = Color.red.uiColor
        } else {
            seqCheck.isEnabled = true
            rx_seqState.onNext(.editing)
            lbAccountLength.textColor = Color.lightGray.uiColor
            
            if name.count == 12 {
                lbAccountLength.textColor = Color.green.uiColor
                btnDuplicateCheck.isEnabled = true
                if name == lastValidatedAccount {
                    btnDuplicateCheck.isSelected = true
                }
            } else {
                lbAccountLength.textColor = Color.lightGray.uiColor
            }
        }
    }
    
    private func changeSeqState(state: SeqState) {
        switch state {
        case .pass:
            seqCheck.isEnabled = true
            seqCheck.isSelected = true
        case .fail:
            seqCheck.isEnabled = false
            seqCheck.isSelected = false
        case .editing:
            seqCheck.isEnabled = true
            seqCheck.isSelected = false
        }
    }
    
    
}


class CreateOwnerKeyCell: CreateActiveKeysCell {
    private var bag: DisposeBag? = nil
    
    override func awakeFromNib() {
        setupUI()
        bindActions()
    }
    
    override func prepareForReuse() {
        bag = nil
    }
    
    private func setupUI() {
        
        lbTitle.text = "Owner Key"
        lbTitleSecureEnclave.text = LocalizedString.Create.Account.genTitle
        lbTextSecureEnclave.text = LocalizedString.Create.Account.genText
        btnGetInfo.setTitle(LocalizedString.Create.Account.seDetail, for: .normal)
        lbTitleInsertKey.text = LocalizedString.Create.Account.insertTitle
        
        seqCheck.isUserInteractionEnabled = false
        seqCheck.setTitle("2", for: .normal)
        seqCheck.setThemeColor(fgColor: Color.lightGray.uiColor, bgColor: .clear, state: .normal, border: true)
        seqCheck.setThemeColor(fgColor: Color.green.uiColor, bgColor: .clear, state: .selected, border: true)
        seqCheck.setThemeColor(fgColor: Color.red.uiColor, bgColor: .clear, state: .disabled, border: true)
        
        btnEnableSecure.isSelected = true
        seqCheck.isSelected = btnEnableSecure.isSelected
        
    }
    
    private func bindActions() {
        
        _ = btnGetInfo.rx.singleTap
            .bind {
                let urlString = URLs.iCloudKeychain
                
                guard let url =  URL(string: urlString) else { return }
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
        }
    }
    
    override func configure(form: CreateAccountForm) {
        let bag = DisposeBag()
        self.bag = bag
        
        btnEnableSecure.rx.singleTap
            .bind {
                form.createOwnerKeyMode.value = .iCloudKeychain
            }
            .disposed(by: bag)
        
        btnEnableInsertKey.rx.singleTap
            .bind {
                form.validatedOwnerKey.value = ""
                form.createOwnerKeyMode.value = .imported
            }
            .disposed(by: bag)
    }
}

class InsertOwnerKeyCell: InsertActiveKeyCell {
    
    private var bag: DisposeBag? = nil
    
    override func awakeFromNib() {
        setupUI()
        bindActions()
    }
    
    override func prepareForReuse() {
        bag = nil
    }
    
    private func setupUI() {
        lbTitle.text = "Owner Key"
        lbTitleSecureEnclave.text = LocalizedString.Create.Account.genTitle
        lbInsertTitle.text = LocalizedString.Create.Account.insertTitle
        lbInsertText.text = LocalizedString.Create.Account.insertText
        txtPubKey.placeholder = LocalizedString.Wallet.pubKey
        
        seqCheck.isUserInteractionEnabled = false
        seqCheck.setTitle("2", for: .normal)
        seqCheck.setThemeColor(fgColor: Color.lightGray.uiColor, bgColor: .clear, state: .normal, border: true)
        seqCheck.setThemeColor(fgColor: Color.green.uiColor, bgColor: .clear, state: .selected, border: true)
        seqCheck.setThemeColor(fgColor: Color.red.uiColor, bgColor: .clear, state: .disabled, border: true)
        
    }
    
    private func bindActions() {
        
    }
    
    override func configure(form: CreateAccountForm) {
        let bag = DisposeBag()
        self.bag = bag
        
        btnEnableSecure.rx.singleTap
            .bind {
                form.createOwnerKeyMode.value = .iCloudKeychain
            }
            .disposed(by: bag)
        
        btnEnableInsertKey.rx.singleTap
            .bind {
                form.createOwnerKeyMode.value = .imported
            }
            .disposed(by: bag)
        
        txtPubKey.text = form.validatedOwnerKey.value
        
        txtPubKey.rx.text.orEmpty
            .bind { [weak self] (key) in
                let validated = Validator.validatePubkey(pubKey: key)
                form.validatedOwnerKey.value = validated ? key : ""
                let state: SeqState = validated ? .pass : .editing
                self?.changeSeqState(state: state)
            }
            .disposed(by: bag)
        
    }
    
    
    private func changeSeqState(state: SeqState) {
        switch state {
        case .pass:
            seqCheck.isEnabled = true
            seqCheck.isSelected = true
        case .fail:
            seqCheck.isEnabled = false
            seqCheck.isSelected = false
        case .editing:
            seqCheck.isEnabled = true
            seqCheck.isSelected = false
        }
    }
}

class CreateActiveKeysCell: UITableViewCell {
    @IBOutlet fileprivate weak var lbTitle: UILabel!
    @IBOutlet fileprivate weak var seqCheck: BorderColorButton!
    
    @IBOutlet fileprivate weak var btnEnableSecure: UIButton!
    @IBOutlet fileprivate weak var btnEnableInsertKey: UIButton!
    @IBOutlet fileprivate weak var lbTitleSecureEnclave: UILabel!
    @IBOutlet fileprivate weak var lbTextSecureEnclave: UILabel!
    @IBOutlet fileprivate weak var btnGetInfo:UIButton!
    @IBOutlet fileprivate weak var lbTitleInsertKey: UILabel!
    
    
    private var bag: DisposeBag? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        bindActions()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = nil
    }
    
    private func setupUI() {
        
        lbTitle.text = "Active Key"
        lbTitleSecureEnclave.text = LocalizedString.Create.Account.seTitle
        lbTextSecureEnclave.text = LocalizedString.Create.Account.seText
        btnGetInfo.setTitle(LocalizedString.Create.Account.seDetail, for: .normal)
        lbTitleInsertKey.text = LocalizedString.Create.Account.insertTitle
     
        seqCheck.isUserInteractionEnabled = false
        seqCheck.setTitle("3", for: .normal)
        seqCheck.setThemeColor(fgColor: Color.lightGray.uiColor, bgColor: .clear, state: .normal, border: true)
        seqCheck.setThemeColor(fgColor: Color.green.uiColor, bgColor: .clear, state: .selected, border: true)
        seqCheck.setThemeColor(fgColor: Color.red.uiColor, bgColor: .clear, state: .disabled, border: true)
       
        btnEnableSecure.isSelected = true
        seqCheck.isSelected = btnEnableSecure.isSelected
        
    }
    
    private func bindActions() {
        _ = btnGetInfo.rx.singleTap
            .bind {
                let urlString = URLs.secureEnclave
                
                guard let url =  URL(string: urlString) else { return }
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        
    }
    
    func configure(form: CreateAccountForm) {
        let bag = DisposeBag()
        self.bag = bag
        
        btnEnableSecure.rx.singleTap
            .bind {
                form.createActiveKeyMode.value = .secureEnclave
            }
            .disposed(by: bag)

        btnEnableInsertKey.rx.singleTap
            .bind {
                form.validatedActiveKey.value = ""
                form.createActiveKeyMode.value = .imported
            }
            .disposed(by: bag)
    }
    
    private func changeSeqState(state: SeqState) {
        switch state {
        case .pass:
            seqCheck.isEnabled = true
            seqCheck.isSelected = true
        case .fail:
            seqCheck.isEnabled = false
            seqCheck.isSelected = false
        case .editing:
            seqCheck.isEnabled = true
            seqCheck.isSelected = false
        }
    }
    
}

class InsertActiveKeyCell: UITableViewCell {
    @IBOutlet fileprivate weak var btnEnableSecure: UIButton!
    @IBOutlet fileprivate weak var btnEnableInsertKey: UIButton!
    @IBOutlet fileprivate weak var lbTitleSecureEnclave: UILabel!
    @IBOutlet fileprivate weak var lbTitle: UILabel!
    @IBOutlet fileprivate weak var lbInsertTitle: UILabel!
    @IBOutlet fileprivate weak var lbInsertText: UILabel!
    @IBOutlet fileprivate weak var txtPubKey: UITextField!
    @IBOutlet fileprivate weak var seqCheck: BorderColorButton!
    
    private var bag: DisposeBag? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        bindActions()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = nil
    }
    
    private func setupUI() {
        lbTitle.text = "Active Key"
        lbTitleSecureEnclave.text = LocalizedString.Create.Account.seTitle
        lbInsertTitle.text = LocalizedString.Create.Account.insertTitle
        lbInsertText.text = LocalizedString.Create.Account.insertText
        txtPubKey.placeholder = LocalizedString.Wallet.pubKey
        
        seqCheck.isUserInteractionEnabled = false
        seqCheck.setTitle("3", for: .normal)
        seqCheck.setThemeColor(fgColor: Color.lightGray.uiColor, bgColor: .clear, state: .normal, border: true)
        seqCheck.setThemeColor(fgColor: Color.green.uiColor, bgColor: .clear, state: .selected, border: true)
        seqCheck.setThemeColor(fgColor: Color.red.uiColor, bgColor: .clear, state: .disabled, border: true)
        
    }
    
    private func bindActions() {
        
    }
    
    func configure(form: CreateAccountForm) {
        let bag = DisposeBag()
        self.bag = bag
        
        btnEnableSecure.rx.singleTap
            .bind {
                form.createActiveKeyMode.value = .secureEnclave
            }
            .disposed(by: bag)
        
        btnEnableInsertKey.rx.singleTap
            .bind {
                form.createActiveKeyMode.value = .imported
            }
            .disposed(by: bag)
     
        txtPubKey.text = form.validatedActiveKey.value
        txtPubKey.rx.text.orEmpty
            .bind { [weak self] (key) in
                let validated = Validator.validatePubkey(pubKey: key)
                form.validatedActiveKey.value = validated ? key : ""
                let state: SeqState = validated ? .pass : .editing
                self?.changeSeqState(state: state)
            }
            .disposed(by: bag)
        
        

    }
    

    private func changeSeqState(state: SeqState) {
        switch state {
        case .pass:
            seqCheck.isEnabled = true
            seqCheck.isSelected = true
        case .fail:
            seqCheck.isEnabled = false
            seqCheck.isSelected = false
        case .editing:
            seqCheck.isEnabled = true
            seqCheck.isSelected = false
        }
    }
}


class CreateAccountNextCell: UITableViewCell {
    @IBOutlet fileprivate weak var btnNext: BorderColorButton!
    private var bag: DisposeBag? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        bindActions()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = nil
    }
    
    private func setupUI() {
        btnNext.setTitle(LocalizedString.Create.Account.name, for: .normal)
        
        btnNext.isEnabled = false
        
        btnNext.setThemeColor(fgColor: Color.white.uiColor, bgColor: Color.lightPurple.uiColor, state: .normal, border: false)
        btnNext.setThemeColor(fgColor: Color.lightGray.uiColor, bgColor: .clear, state: .disabled, border: false)
    }
    
    private func bindActions() {
        
    }
    
    func configure(form: CreateAccountForm) {
        let bag = DisposeBag()
        self.bag = bag
        
        let validateCheckOwnerKey0 = form.createOwnerKeyMode.asObservable().flatMap { (mode) -> Observable<Bool> in
            return Observable.just(mode == CreateKeyMode.iCloudKeychain)
        }
        
        let validateCheckOwnerKey1 = form.validatedOwnerKey.asObservable().flatMap { (key) -> Observable<Bool> in
            return Observable.just(key.count > 0)
        }
        
        let validateCheckActiveKey0 = form.createActiveKeyMode.asObservable().flatMap { (mode) -> Observable<Bool> in
            return Observable.just(mode == CreateKeyMode.secureEnclave)
        }
        
        let validateCheckActiveKey1 = form.validatedActiveKey.asObservable().flatMap { (key) -> Observable<Bool> in
            return Observable.just(key.count > 0)
        }
        
        
        
        let checkOwnerKey = Observable.combineLatest([validateCheckOwnerKey0, validateCheckOwnerKey1]).flatMap { (results) -> Observable<Bool> in
            let hasTrue = results.filter {$0}.count > 0
            return Observable.just(hasTrue)
        }
        
        let checkActiveKey = Observable.combineLatest([validateCheckActiveKey0, validateCheckActiveKey1]).flatMap { (results) -> Observable<Bool> in
            let hasTrue = results.filter {$0}.count > 0
            return Observable.just(hasTrue)
        }
        
        let checkAccount = form.validatedAccount.asObservable().flatMap { (name) -> Observable<Bool> in
            return Observable.just(name.count == 12)
        }
        
        let maxValidate = 3
        
        Observable.combineLatest([checkAccount, checkOwnerKey, checkActiveKey])
            .subscribe(onNext: { [weak self] (validateResults) in
                let trueCount = validateResults.filter{$0}.count
                let title = LocalizedString.Create.Account.next
                self?.btnNext.setTitle(title, for: .normal)
                self?.btnNext.isEnabled = (trueCount == maxValidate)
            })
            .disposed(by: bag)
        
        btnNext.rx.singleTap
            .bind { [weak self] in
                if self?.btnNext.isEnabled == true {
                    form.next.onNext(())
                }
            }
            .disposed(by: bag)
        
    }
}




struct CreateAccountForm {
    let accountCheck = PublishSubject<String>()
    let createOwnerKeyMode = Variable<CreateKeyMode>(.iCloudKeychain)
    let createActiveKeyMode = Variable<CreateKeyMode>(.secureEnclave)
    let validatedAccount = Variable<String>("")
    let validatedOwnerKey = Variable<String>("")
    let validatedActiveKey = Variable<String>("")
    let next = PublishSubject<Void>()
    
    func clear() {
        createOwnerKeyMode.value = .iCloudKeychain
        createActiveKeyMode.value = .secureEnclave
        validatedAccount.value = ""
        validatedOwnerKey.value = ""
        validatedActiveKey.value = ""
    }
}


enum SeqState: String {
    case fail, pass, editing
}

enum CreateKeyMode: String {
    case secureEnclave, iCloudKeychain, imported, none
}



