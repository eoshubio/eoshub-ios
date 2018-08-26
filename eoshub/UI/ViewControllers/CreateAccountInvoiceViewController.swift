//
//  CreateAccountInvoiceViewController.swift
//  eoshub
//
//  Created by kein on 2018. 8. 11..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class CreateAccountInvoiceViewController: BaseTableViewController {
    
    var flowDelegate: FlowEventDelegate?
    
    fileprivate let invoiceForm = InvoiceForm()
    
    private var invoice: Invoice? = nil
    
    fileprivate var request: CreateAccountRequest!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar(with: .basePurple, animated: animated, largeTitle: true)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.refresh))
        
        title = LocalizedString.Create.Account.title + " (3/3)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
        bindActions()
    }
    
    func configure(request: CreateAccountRequest) {
        self.request = request
    }
    
    @objc fileprivate func refresh() {
        //get new invoice
        if request.isExpired == false {
            let alert = UIAlertController(title: LocalizedString.Common.caution, message: LocalizedString.Create.Invoice.refreshWarning,
                                          preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: LocalizedString.Common.confirmShort, style: .default, handler: { [weak self](_) in
                self?.refreshData()
            }))
            
            alert.addAction(UIAlertAction(title: LocalizedString.Common.cancelShort, style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
        } else {
            refreshData()
        }
    }
    
    private func setupUI() {
        EHAnalytics.trackEvent(event: .try_create_account3)
    }
    
    private func setupData() {
        if  request.currentStage.rawValue >= CreateAccountRequest.Stage.invoice.rawValue {
            //If a valid invoice is in the DB
            invoiceForm.update(from: request)
            invoice = request.invoice
        } else {
            //get new invoice
            refreshData()
        }
    }
    
    
    private func bindActions() {
        invoiceForm.txSearch
            .bind { [weak self] in
                self?.findRequestInTxs()
            }
            .disposed(by: bag)
        
        invoiceForm.tapString
            .bind { [weak self] (text) in
                switch text {
                case LocalizedString.Create.Invoice.term:
                    guard let nc = self?.navigationController else { return }
                    self?.flowDelegate?.goToWebView(from: nc, with: Config.termForBuyers,
                                                    title: LocalizedString.Create.Invoice.term)
                case LocalizedString.Common.constitusion:
                    guard let nc = self?.navigationController else { return }
                    self?.flowDelegate?.goToWebView(from: nc, with: Config.eosConstitution,
                                                    title: LocalizedString.Common.constitusion)
                default:
                    break
                }
            }
            .disposed(by: bag)
    }
    
    private func findRequestInTxs() {
        
        WaitingView.shared.start()
        getTx()
            .flatMap(createAccount)
            .subscribe(onNext: { [weak self] (json) in
                guard let `self` = self else { return }
                if let resultType = json.string(for: "resultType"), resultType == "SUCCESS" {
                    let ehaccount = EHAccount(userId: UserManager.shared.userId,
                                                account: self.request.name,
                                              publicKey: self.request.activeKey,
                                              owner: true)
                    
                    DB.shared.addAccount(account: ehaccount)
                    
                    AccountManager.shared.doLoadAccount()
                    
                    EHAnalytics.trackEvent(event: .create_account(self.request.ownerKeyFrom , self.request.activeKeyFrom))
                    
                    Popup.present(style: .success, description: "")
                    
                    DB.shared.safeWrite {
                        self.request.completed = true
                    }
                    
                    guard let nc = self.navigationController else { return }
                    
                    self.flowDelegate?.finish(viewControllerToFinish: nc, animated: true, completion: nil)
                    
                } else {
                    Popup.present(style: .failed, description: "\(json)")
                }
                
                
            }, onError: { (error) in
                if let error = error as? PrettyPrintedPopup {
                    error.showPopup()
                }
            }) {
                WaitingView.shared.stop()
        }
        .disposed(by: bag)
    }
    
    private func getTx() -> Observable<Tx> {
        
        let account = request.creator
        
        return RxEOSAPI.getTxHistory(account: account)
                        .flatMap(getRequestedTx)
    }
    
    private func getRequestedTx(txs: [Tx]) -> Observable<Tx> {
        guard let invoice = invoice else { return Observable.error(EOSErrorType.emptyData) }
        if let tx = txs.filter({checkHasRequestedTx(tx: $0, invoice: invoice)}).first {
            return Observable.just(tx)
        } else {
            return Observable.error(EOSHubError.txNotFound)
        }
    }
    
    private func checkHasRequestedTx(tx: Tx, invoice: Invoice) -> Bool {
        guard let data = JSON.createJSON(from: tx.data) else { return false }
        
        guard let from = data.string(for: Contract.Args.transfer.from),
            let to = data.string(for: Contract.Args.transfer.to),
            let currencyString = data.string(for: Contract.Args.transfer.quantity),
            let currency = Currency.create(stringValue: currencyString, contract: .eos),
            let memo = data.string(for: Contract.Args.transfer.memo) else { return  false }
        
        if to == invoice.creator || from == invoice.creator,
            currency.quantity >= invoice.totalEOS.quantity,
            memo == invoice.memo {
            return true
        } else {
            return false
        }
        
    }
    

    private func refreshData() {
        let userId = UserManager.shared.userId
        WaitingView.shared.start()
            
        EOSHubAPI.refreshMemo(userId: userId)
            .flatMap { (json) -> Observable<Invoice> in
                if let invoice = Invoice(json: json) {
                    return Observable.just(invoice)
                } else {
                    return Observable.error(EOSErrorType.emptyData)
                }
            }
            .subscribe(onNext: { [weak self] (invoice) in
                self?.request.addInvoice(invoice: invoice)
                self?.invoice = invoice
                self?.invoiceForm.update(from: invoice)
                }, onError: { (error) in
                    if let error = error as? PrettyPrintedPopup {
                        error.showPopup()
                    } else {
                        Popup.present(style: .failed, description: "\(error)")
                    }
            }) {
                WaitingView.shared.stop()
            }
            .disposed(by: bag)

    }
    
    private func createAccount(tx: Tx) -> Observable<JSON> {
        let userId = UserManager.shared.userId
        
        return EOSHubAPI.createAccount(userId: userId,
                                txId: tx.txid,
                                accountName: request.name,
                                ownerKey: request.ownerKey,
                                activeKey: request.activeKey)
        
    }
    
}

extension CreateAccountInvoiceViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CreateAccountInvoiceCell", for: indexPath) as? CreateAccountInvoiceCell else { preconditionFailure() }
            cell.configure(form: invoiceForm)
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CreateAccountRequestCell", for: indexPath) as? CreateAccountRequestCell else { preconditionFailure() }
            cell.configure(form: invoiceForm)
            return cell
        default:
            preconditionFailure()
        }
    }
}


class CreateAccountInvoiceCell: UITableViewCell {
    @IBOutlet fileprivate weak var lbTitle: UILabel!
    @IBOutlet fileprivate weak var timerCount: BorderColorButton!
    @IBOutlet fileprivate weak var lbTextDeposit: UILabel!
    @IBOutlet fileprivate weak var lbTextTimeLimit: UILabel!
    @IBOutlet fileprivate weak var lbNameTitle: UILabel!
    @IBOutlet fileprivate weak var lbName: UILabel!
    @IBOutlet fileprivate weak var btnCopyAccount: UIButton!
    @IBOutlet fileprivate weak var lbMemoTitle: UILabel!
    @IBOutlet fileprivate weak var lbMemo: UILabel!
    @IBOutlet fileprivate weak var btnCopyMemo: UIButton!
    @IBOutlet fileprivate weak var lbQuantityCPU: UILabel!
    @IBOutlet fileprivate weak var lbQuantityNet: UILabel!
    @IBOutlet fileprivate weak var lbQuantityRAM: UILabel!
    @IBOutlet fileprivate weak var lbQuantityTotal: UILabel!
    
    var bag: DisposeBag? = nil
    
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
        
        lbTitle.text = LocalizedString.Create.Invoice.title
        lbTextDeposit.text = LocalizedString.Create.Invoice.textDeposit
        
        lbNameTitle.text = LocalizedString.Create.Check.name
        lbMemoTitle.text = LocalizedString.Create.Invoice.memo
        
        btnCopyMemo.setTitle(LocalizedString.Common.copy, for: .normal)
        btnCopyAccount.setTitle(LocalizedString.Common.copy, for: .normal)
        
        timerCount.setThemeColor(fgColor: Color.red.uiColor, bgColor: .clear, state: .normal)
        
        timerCount.isHidden = true
    }
    
    private func bindActions() {
        _ = btnCopyAccount.rx.tap
            .bind { [weak self] in
                guard let account = self?.lbName.text else { return }
                UIPasteboard.general.string = account
                Popup.present(style: .success, description: LocalizedString.Common.copied)
            }
        
        _ = btnCopyMemo.rx.tap
            .bind { [weak self] in
                guard let memo = self?.lbMemo.text else { return }
                UIPasteboard.general.string = memo
                Popup.present(style: .success, description: LocalizedString.Common.copied)
        }
    }
    
    func configure(form: InvoiceForm) {
        let bag = DisposeBag()
        self.bag = bag
        
        form.expireHour.asObservable()
            .bind { [weak self] (hour) in
                let timeLimit = String(format: LocalizedString.Create.Invoice.timelimit, "\(hour)")
                let txtTimeLimit = String(format: LocalizedString.Create.Invoice.textTimelimit, timeLimit)
                let attrTimeLimit = NSMutableAttributedString(string: txtTimeLimit)
                attrTimeLimit.addAttributeColor(text: timeLimit, color: Color.red.uiColor)
                self?.lbTextTimeLimit.attributedText = attrTimeLimit
            }
            .disposed(by: bag)
        
        form.creatorName.asObservable()
            .bind(to: lbName.rx.text)
            .disposed(by: bag)
     
        form.memo.asObservable()
            .bind(to: lbMemo.rx.text)
            .disposed(by: bag)

        form.cpu.asObservable()
            .bind(to: lbQuantityCPU.rx.text)
            .disposed(by: bag)

        form.net.asObservable()
            .bind(to: lbQuantityNet.rx.text)
            .disposed(by: bag)

        form.ram.asObservable()
            .bind(to: lbQuantityRAM.rx.text)
            .disposed(by: bag)

        form.total.asObservable()
            .bind(to: lbQuantityTotal.rx.text)
            .disposed(by: bag)
        
    
        let fontSize = lbTextDeposit.font.pointSize
        let boldFont = Font.appleSDGothicNeo(.bold).uiFont(fontSize)
        form.total.asObservable()
            .flatMap({ (total) -> Observable<NSAttributedString> in
                let text = String(format: LocalizedString.Create.Invoice.textDeposit, total)
                let attrText = NSMutableAttributedString(string: text)
                
                attrText.addAttributeFont(text: total, font: boldFont)
                attrText.addAttributeFont(text: LocalizedString.Create.Invoice.account, font: boldFont)
                attrText.addAttributeFont(text: LocalizedString.Create.Invoice.memo, font: boldFont)
                return Observable.just(attrText)
            })
            .bind(to: lbTextDeposit.rx.attributedText)
            .disposed(by: bag)
    
        
        let _ = Observable<Int>
            .interval(1, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (_) in
                let timestamp = form.timestamp.value
                let remain = timestamp + 3600 - Date().timeIntervalSince1970
                let text = remain >= 0 ? remain.stringTime : "Expired"
                self?.timerCount.isHidden = false
                self?.timerCount.setTitle(text, for: .normal)
            })
            .disposed(by: bag)
        
        
    }
    
}



class CreateAccountRequestCell: UITableViewCell, UITextViewDelegate {
    @IBOutlet fileprivate weak var lbTextConfirm: UILabel!
    @IBOutlet fileprivate weak var btnConfirm: UIButton!
    @IBOutlet fileprivate weak var txtTerms: UITextView!
    @IBOutlet fileprivate weak var btnAgree: UIButton!
    
    fileprivate var rx_tapString = PublishSubject<String>()
    
    var bag: DisposeBag? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = nil
    }
    
    private func setupUI() {
        lbTextConfirm.text = LocalizedString.Create.Invoice.textConfirm
        btnConfirm.setTitle(LocalizedString.Create.Invoice.confirm, for: .normal)

        let textTerms = NSMutableAttributedString(string: LocalizedString.Create.Invoice.agreeTerms)
        
        let termURL = URL(string: Config.termForBuyers)!
        let constitutionURL = URL(string: Config.eosConstitution)!
        textTerms.addAttributeURL(text: LocalizedString.Create.Invoice.term, url: termURL)
        textTerms.addAttributeURL(text: LocalizedString.Common.constitusion, url: constitutionURL)
        txtTerms.attributedText = textTerms

        
    }
    

    
    func configure(form: InvoiceForm) {
        let bag = DisposeBag()
        self.bag = bag
        
        btnAgree.rx.tap
            .bind { [weak self] in
                guard let `self` = self else { return }
                self.btnAgree.isSelected = !self.btnAgree.isSelected
                form.agreed.onNext(self.btnAgree.isSelected)
            }
            .disposed(by: bag)
        
        form.agreed.asObservable()
            .bind(to: btnConfirm.rx.isEnabled)
            .disposed(by: bag)
        
        btnConfirm.rx.singleTap
            .bind {
                form.txSearch.onNext(())
            }
            .disposed(by: bag)
        
        rx_tapString.asObservable()
            .bind(to: form.tapString)
            .disposed(by: bag)
    }
    
}

struct InvoiceForm {
    let creatorName = Variable<String>(" ")
    let memo = Variable<String>(" ")
    let cpu = Variable<String>(" ")
    let net = Variable<String>(" ")
    let ram = Variable<String>(" ")
    let total = Variable<String>(" ")
    let timestamp = Variable<Double>(0)
    let expireHour = Variable<Int>(1)
    
    let agreed = BehaviorSubject<Bool>(value: false)
    
    let tapString = PublishSubject<String>()
    let txSearch = PublishSubject<Void>()
    
    func update(from txMemo: Invoice) {
        creatorName.value = txMemo.creator
        memo.value = txMemo.memo
        cpu.value = txMemo.cpu.stringValue
        net.value = txMemo.net.stringValue
        ram.value = "\(txMemo.ram) Bytes"
        total.value = txMemo.totalEOS.stringValue
        timestamp.value = txMemo.createdAt
        expireHour.value = txMemo.expireHour
    }
    
    func update(from request: CreateAccountRequest) {
        creatorName.value = request.creator
        memo.value = request.memo
        cpu.value = request.cpu
        net.value = request.net
        ram.value = request.ram + "Bytes"
        total.value = request.total
        timestamp.value = request.created
        expireHour.value = request.expireHour
    }
}

extension CreateAccountRequest {
    var invoice: Invoice? {
        
        guard let totalEOS = Currency(eosCurrency: total),
            let cpuEOS = Currency(eosCurrency: cpu),
            let netEOS = Currency(eosCurrency: net) else { return nil }
//            let ramBytes = 6 else { return nil }
        
        return Invoice(completed: completed,
                       totalEOS: totalEOS, memo: memo, createdAt: created, expiredAt: created + expireTime,
                       expireTime: Int(expireTime),
                       creator: creator, cpu: cpuEOS, net: netEOS, ram: 6)
    }
}

