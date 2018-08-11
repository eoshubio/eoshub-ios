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

class CreateAccountViewController: BaseTableViewController {
    
    var flowDelegate: CreateAccountFlowEventDelegate?
    
    var requestForm = CreateAccountForm()
    
    enum CellType {
        case accountName, key, next
    }
    var items: [CellType] = [.accountName, .next]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar(with: .basePurple, animated: animated, largeTitle: true)
        title = LocalizedString.Create.Account.title + " (1/3)"
        addBackButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
    }
    
    private func setupUI() {
        
    }
    
    private func bindActions() {
        requestForm.accountCheck
            .bind { [weak self] (name) in
                self?.checkAccount(name: name)
            }
            .disposed(by: bag)
        
        requestForm.createKeyMode.asObservable()
            .bind { [weak self] (mode) in
                self?.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
            }
            .disposed(by: bag)
        
        requestForm.next.asObservable()
            .bind { [weak self] in
                guard let nc = self?.navigationController else { return }
                self?.flowDelegate?.goInfo(from: nc)
            }
            .disposed(by: bag)
        
    }
    
    private func checkAccount(name: String) {
        RxEOSAPI.getAccount(name: name)
            .subscribe(onNext: { [weak self](_) in
                //failed
                self?.requestForm.validatedAccount.value = ""
                let text = String(format: LocalizedString.Create.Check.failed, name)
                Popup.present(style: .failed, description: text)
                
            }, onError: { [weak self](error) in
                if case EOSResponseError.unknownKey = error {
                    self?.requestForm.validatedAccount.value = name
                    let text = String(format: LocalizedString.Create.Check.success, name)
                    Popup.present(style: .success, description: text)
                    //Add create key cell
                    let prvItemCount = self?.items.count ?? 0
                    if prvItemCount == 2 {
                        self?.items = [.accountName, .key, .next]
                        self?.tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
                    }
                } else {
                    //exception
                    self?.requestForm.validatedAccount.value = ""
                    Popup.present(style: .failed, description: error.localizedDescription)
                }
            })
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
        case .key:
            if requestForm.createKeyMode.value == .secureEnclave {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "CreateAccountKeysCell", for: indexPath) as? CreateAccountKeysCell else { preconditionFailure() }
                cell.configure(form: requestForm)
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "CreateAccountInsertKeyCell", for: indexPath) as? CreateAccountInsertKeyCell else { preconditionFailure() }
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
                let state: SeqState = validatedAccount.count > 0 ? .pass : .editing
                self?.lastValidatedAccount = validatedAccount
                self?.rx_seqState.onNext(state)
                self?.btnDuplicateCheck.isSelected = (state == .pass)
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

class CreateAccountKeysCell: UITableViewCell {
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
        
        lbTitle.text = LocalizedString.Create.Account.keys
        lbTitleSecureEnclave.text = LocalizedString.Create.Account.seTitle
        lbTextSecureEnclave.text = LocalizedString.Create.Account.seText
        btnGetInfo.setTitle(LocalizedString.Create.Account.seDetail, for: .normal)
        lbTitleInsertKey.text = LocalizedString.Create.Account.insertTitle
     
        seqCheck.isUserInteractionEnabled = false
        seqCheck.setThemeColor(fgColor: Color.lightGray.uiColor, bgColor: .clear, state: .normal, border: true)
        seqCheck.setThemeColor(fgColor: Color.green.uiColor, bgColor: .clear, state: .selected, border: true)
        seqCheck.setThemeColor(fgColor: Color.red.uiColor, bgColor: .clear, state: .disabled, border: true)
       
        btnEnableSecure.isSelected = true
        seqCheck.isSelected = btnEnableSecure.isSelected
        
    }
    
    private func bindActions() {
        _ = btnGetInfo.rx.singleTap
            .bind {
                let urlString = "https://developer.apple.com/documentation/security/certificate_key_and_trust_services/keys/storing_keys_in_the_secure_enclave"
                
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
                form.createKeyMode.value = .secureEnclave
            }
            .disposed(by: bag)
        
        btnEnableInsertKey.rx.singleTap
            .bind {
                form.createKeyMode.value = .insert
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

class CreateAccountInsertKeyCell: UITableViewCell {
    @IBOutlet fileprivate weak var btnEnableSecure: UIButton!
    @IBOutlet fileprivate weak var btnEnableInsertKey: UIButton!
    @IBOutlet fileprivate weak var lbTitleSecureEnclave: UILabel!
    @IBOutlet fileprivate weak var lbTitle: UILabel!
    @IBOutlet fileprivate weak var lbText: UILabel!
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
        lbTitleSecureEnclave.text = LocalizedString.Create.Account.seTitle
        lbTitle.text = LocalizedString.Create.Account.insertTitle
        lbText.text = LocalizedString.Create.Account.insertText
        txtPubKey.placeholder = LocalizedString.Wallet.pubKey
        
        seqCheck.isUserInteractionEnabled = false
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
                form.createKeyMode.value = .secureEnclave
            }
            .disposed(by: bag)
        
        btnEnableInsertKey.rx.singleTap
            .bind {
                form.createKeyMode.value = .insert
            }
            .disposed(by: bag)
     
        txtPubKey.text = form.validatedKey.value
        txtPubKey.rx.text.orEmpty
            .bind { [weak self] (key) in
                let validated = Validator.validatePubkey(pubKey: key)
                form.validatedKey.value = validated ? key : ""
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
        
        let validateCheck0 = form.createKeyMode.asObservable().flatMap { (mode) -> Observable<Bool> in
            return Observable.just(mode == CreateKeyMode.secureEnclave)
        }
        
        let validateCheck1 = form.validatedKey.asObservable().flatMap { (key) -> Observable<Bool> in
            return Observable.just(key.count > 0)
        }
        
        let checkKey = Observable.combineLatest([validateCheck0, validateCheck1]).flatMap { (results) -> Observable<Bool> in
            let hasTrue = results.filter {$0}.count > 0
            return Observable.just(hasTrue)
        }
        
        let checkAccount = form.validatedAccount.asObservable().flatMap { (name) -> Observable<Bool> in
            return Observable.just(name.count == 12)
        }
        
        let maxValidate = 2
        
        Observable.combineLatest([checkAccount, checkKey])
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
    let createKeyMode = Variable<CreateKeyMode>(.secureEnclave)
    let validatedAccount = Variable<String>("")
    let validatedKey = Variable<String>("")
    let next = PublishSubject<Void>()
}


enum SeqState: String {
    case fail, pass, editing
}

enum CreateKeyMode: String {
    case secureEnclave
    case generate
    case insert
}



