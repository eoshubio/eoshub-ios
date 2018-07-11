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
//        tableView.contentInset = UIEdgeInsetsMake(0, 0, 150, 0)
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
    @IBOutlet fileprivate var btnCreate: UIButton!
    private let bag = DisposeBag()
    
    deinit {
        print("deinit")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
    
    }
    
    override func configure(subject: PublishSubject<Void>) {
        btnCreate.rx.singleTap
            .bind {
                subject.onNext(())
            }
            .disposed(by: bag)
    }
}


class ImportAccountCell: CreateViewCell {
    @IBOutlet fileprivate var btnImport: UIButton!
    private let bag = DisposeBag()
    
    deinit {
        print("deinit")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        
    }
    
    override func configure(subject: PublishSubject<Void>) {
        btnImport.rx.singleTap
            .bind {
                subject.onNext(())
            }
            .disposed(by: bag)
    }
}


class ImportPubAccountCell: CreateViewCell {
    @IBOutlet fileprivate var btnImport: UIButton!
    private let bag = DisposeBag()
    
    deinit {
        print("deinit")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        
    }
    
    override func configure(subject: PublishSubject<Void>) {
        btnImport.rx.singleTap
            .bind {
                subject.onNext(())
            }
            .disposed(by: bag)
    }
}
