//
//  CreateViewController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 10..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class CreateViewController: BaseViewController {
    
    var flowDelegate: CreateFlowEventDelegate?
    
    @IBOutlet fileprivate var tableView: UITableView!
    @IBOutlet fileprivate var btnClose: UIButton!
    
    fileprivate var createAccount = PublishSubject<Void>()
    fileprivate var importPriAccount = PublishSubject<Void>()
    fileprivate var importPubAccount = PublishSubject<Void>()
    fileprivate var restoreAccount = PublishSubject<Void>()
    
    var items: [CreateViewCellType] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
    }
    
    private func setupUI() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        tableView.allowsSelection = false
    }
    
    private func bindActions() {
        createAccount
            .bind { [weak self] in
                guard let nc = self?.navigationController else { return }
                self?.flowDelegate?.goCreateAccount(from: nc)
            }
            .disposed(by: bag)
        
        importPriAccount
            .bind { [weak self] in
                guard let nc = self?.navigationController else { return }
                self?.flowDelegate?.goImportPrivateKey(from: nc)
            }
            .disposed(by: bag)
        
        importPubAccount
            .bind { [weak self] in
                guard let nc = self?.navigationController else { return }
                self?.flowDelegate?.goImportPublicKey(from: nc)
            }
            .disposed(by: bag)
        
        restoreAccount
            .bind { [weak self] in
                guard let nc = self?.navigationController else { return }
                self?.flowDelegate?.goToRestore(from: nc)
            }
            .disposed(by: bag)
        
        btnClose.rx.tap
            .bind { [weak self] in
                self?.flowDelegate?.finish(viewControllerToFinish: self!, animated: true, completion: nil)
            }
            .disposed(by: bag)
    }
    
    func configure(items: [CreateViewCellType]) {
        self.items = items
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
}

extension CreateViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = items[indexPath.section]
        
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: item.nibName) as? CreateViewCell else { preconditionFailure() }
        
        switch item {
        case .create:
            cell.configure(subject: createAccount)
        case .privateKey:
            cell.configure(subject: importPriAccount)
        case .publicKey:
            cell.configure(subject: importPubAccount)
        case .restore:
            (cell as? ImportPubAccountCell)?.configure(cellType: .restore, subject: restoreAccount)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let v = UIView()
        v.backgroundColor = UIColor.clear
        return v
    }
}


enum CreateViewCellType: Int, CellType {
    
    case create, privateKey, publicKey
    case restore
    
    var id: Int {
        return rawValue
    }
    
    var nibName: String {
        switch self {
        case .create:
            return "CreateAccountCell"
        case .privateKey:
            return "ImportAccountCell"
        case .publicKey:
            return "ImportPubAccountCell"
        case .restore:
            return "ImportPubAccountCell"
        }
    }
    
    
    
    
    
}

protocol ConfigurationableCell {
    func configure(subject: PublishSubject<Void>)
}


class CreateViewCell: UITableViewCell, ConfigurationableCell {
    func configure(subject: PublishSubject<Void>) {
        
    }
}

class CreateAccountCell: CreateViewCell {
    @IBOutlet fileprivate var lbTitle: UILabel!
    @IBOutlet fileprivate var lbText: UILabel!
    @IBOutlet fileprivate var btnCreate: UIButton!
    private var bag: DisposeBag? = nil
    
    deinit {
        print("deinit")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = nil
    }
    
    private func setupUI() {
        lbTitle.text = LocalizedString.Create.New.title
        btnCreate.setTitle(LocalizedString.Create.New.action, for: .normal)
        let text = NSMutableAttributedString(string: LocalizedString.Create.New.text)
        text.addAttributeColor(text: "CPU", color: Color.lightPurple.uiColor)
        text.addAttributeColor(text: "Network", color: Color.lightPurple.uiColor)
        text.addAttributeColor(text: "RAM", color: Color.lightPurple.uiColor)
        lbText.attributedText = text
    }
    
    override func configure(subject: PublishSubject<Void>) {
        let bag = DisposeBag()
        self.bag = bag
        btnCreate.rx.singleTap
            .bind {
                subject.onNext(())
            }
            .disposed(by: bag)
    }
}


class ImportAccountCell: CreateViewCell {
    @IBOutlet fileprivate var lbTitle: UILabel!
    @IBOutlet fileprivate var lbText: UILabel!
    @IBOutlet fileprivate var btnImport: UIButton!
    private var bag: DisposeBag? = nil
    
    deinit {
        print("deinit")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = nil
    }
    
    private func setupUI() {
        lbTitle.text = LocalizedString.Create.Import.title
        btnImport.setTitle(LocalizedString.Create.Import.action, for: .normal)
        let text = NSMutableAttributedString(string: LocalizedString.Create.Import.text)
        text.addAttributeColor(text: "iCloud Keychain", color: Color.lightPurple.uiColor)
        lbText.attributedText = text
    }
    
    override func configure(subject: PublishSubject<Void>) {
        let bag = DisposeBag()
        self.bag = bag
        btnImport.rx.singleTap
            .bind {
                subject.onNext(())
            }
            .disposed(by: bag)
    }
}


class ImportPubAccountCell: CreateViewCell {
    @IBOutlet fileprivate var lbTitle: UILabel!
    @IBOutlet fileprivate var lbText: UILabel!
    @IBOutlet fileprivate var btnImport: UIButton!
    private var bag: DisposeBag? = nil
    
    deinit {
        print("deinit")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = nil
    }
    
    private func setupUI() {
        lbTitle.text = LocalizedString.Create.Interest.title
        lbText.text = LocalizedString.Create.Interest.text
        btnImport.setTitle(LocalizedString.Create.Interest.action, for: .normal)
    }
    
    func configure(cellType: CreateViewCellType, subject: PublishSubject<Void>) {
        let bag = DisposeBag()
        self.bag = bag
        btnImport.rx.singleTap
            .bind {
                subject.onNext(())
            }
            .disposed(by: bag)
        
        if cellType == .publicKey {
            lbTitle.text = LocalizedString.Create.Interest.title
            lbText.text = LocalizedString.Create.Interest.text
            btnImport.setTitle(LocalizedString.Create.Interest.action, for: .normal)
        } else if cellType == .restore {
            lbTitle.text = LocalizedString.Create.Restore.title
            lbText.text = LocalizedString.Create.Restore.text
            btnImport.setTitle(LocalizedString.Create.Restore.action, for: .normal)
        }
        
    }
}
