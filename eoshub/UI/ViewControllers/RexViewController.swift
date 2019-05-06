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
    
    fileprivate var goToLend = PublishSubject<Void>()
    fileprivate var goToBorrow = PublishSubject<Void>()
    
    private let disposeBag = DisposeBag()
    
    enum CellType: Int, CaseIterable {
        case fund, lend, borrow
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar(with: .basePurple, animated: animated, largeTitle: true)
        title = "REX"
    }
    
    deinit {
        Log.d("")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
    }
    
    private func setupUI() {
        let bgView = UIImageView(image: #imageLiteral(resourceName: "bgGrady"))
        bgView.alpha = 0.7
        tableView.backgroundView = bgView
        tableView.register(UINib(nibName: "RexFundCell", bundle: nil), forCellReuseIdentifier: "RexFundCell")
    }
    
    private func bindActions() {
        goToLend.bind { [weak self] in
            guard let nc = self?.navigationController else { return }
            self?.flowDelegate?.goToLend(from: nc)
        }
        .disposed(by: disposeBag)
        
        goToBorrow.bind { [weak self] in
            guard let nc = self?.navigationController else { return }
            self?.flowDelegate?.goToBorrow(from: nc)
        }
        .disposed(by: disposeBag)
    }
}

//MARK: UITableViewDataSource

extension RexViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CellType.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cellType = CellType(rawValue: indexPath.row) else { preconditionFailure() }
        
        switch cellType {
        case .fund:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RexFundCell", for: indexPath) as! RexFundCell
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
            lbTitle.text = "Lend / Unlend EOS"
            lbText.text = "Lend / Unlend EOS through REX"
            btnAction.setTitle("Lend / Unlend EOS (2.7 %)", for: .normal)
        case .borrow:
            lbTitle.text = "Borrow CPU/NET"
            lbText.text = "Borrow CPU and Network resources from REX for 30 days"
            btnAction.setTitle("Borrow CPU/NET (3.0 %)", for: .normal)
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
