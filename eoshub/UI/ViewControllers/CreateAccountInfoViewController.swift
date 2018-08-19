//
//  CreateAccountInfoViewController.swift
//  eoshub
//
//  Created by kein on 2018. 8. 11..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import RxSwift

class CreateAccountInfoViewController: BaseTableViewController {
    
    var flowDelegate: CreateAccountInfoFlowEventDelegate?
    
    fileprivate var request: CreateAccountRequest!
    
    let infoForm = CreateAccountInfoForm()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar(with: .basePurple, animated: animated, largeTitle: true)
        title = LocalizedString.Create.Account.title + " (2/3)"
        addBackButton()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
        
    }
    
    func configure(request: CreateAccountRequest) {
        self.request = request
    }
    
    private func setupUI() {
        let userId = UserManager.shared.userId
        if let request = DB.shared.realm.objects(CreateAccountRequest.self).filter("id BEGINSWITH '\(userId)' AND completed = false").first {
            infoForm.name.value = request.name
            infoForm.ownerKey.value = request.ownerKey
            infoForm.activeKey.value = request.activeKey
        } else {
            Log.e("Invalid state: not exist request")
            flowDelegate?.finish(viewControllerToFinish: self, animated: true, completion: nil)
        }
    }
    
    private func bindActions() {
        infoForm.onNext
            .bind { [weak self] in
                guard let nc = self?.navigationController else { return }
                self?.flowDelegate?.goGetCode(from: nc)
            }
            .disposed(by: bag)
    }
    
    
}

extension CreateAccountInfoViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CreateAccountInfoCell", for: indexPath) as? CreateAccountInfoCell else { preconditionFailure() }
            cell.configure(form: infoForm)
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CreateAccountInfoNextCell", for: indexPath) as? CreateAccountInfoNextCell else { preconditionFailure() }
            cell.configure(form: infoForm)
            return cell
        default:
            preconditionFailure()
        }
    }
}

class CreateAccountInfoCell: UITableViewCell {
    @IBOutlet fileprivate weak var lbTitle: UILabel!
    @IBOutlet fileprivate weak var lbtext: UILabel!
    @IBOutlet fileprivate weak var lbNameTitle: UILabel!
    @IBOutlet fileprivate weak var lbName: UILabel!
    @IBOutlet fileprivate weak var lbOwnerKey: UILabel!
    @IBOutlet fileprivate weak var lbActiveKey: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        lbTitle.text = LocalizedString.Create.Check.title
        lbtext.text = LocalizedString.Create.Check.text
        lbNameTitle.text = LocalizedString.Create.Check.name
    }
    
    func configure(form: CreateAccountInfoForm) {
        lbName.text = form.name.value
        lbOwnerKey.text = form.ownerKey.value
        lbActiveKey.text = form.activeKey.value
    }
}

class CreateAccountInfoNextCell: UITableViewCell {
    @IBOutlet fileprivate weak var btnNext: UIButton!
    
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
        btnNext.setTitle(LocalizedString.Create.Account.next, for: .normal)
    }
    
    func configure(form: CreateAccountInfoForm) {
        let bag = DisposeBag()
        self.bag = bag
        btnNext.rx.singleTap
            .bind(to: form.onNext)
            .disposed(by: bag)
    }
    
}


struct CreateAccountInfoForm {
    let name = Variable<String>("")
    let ownerKey = Variable<String>("")
    let activeKey = Variable<String>("")
    let onNext = PublishSubject<Void>()
}





