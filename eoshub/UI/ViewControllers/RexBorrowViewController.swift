//
//  RexBorrowViewController.swift
//  eoshub
//
//  Created by kein on 06/05/2019.
//  Copyright © 2019 EOS Hub. All rights reserved.
//

import Foundation

class RexBorrowViewController: BaseTableViewController {
    
    var flowDelegate: RexFlowEventDelegate?
    
    enum CellType: Int, CaseIterable {
        case fund
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar(with: .basePurple, animated: animated, largeTitle: true)
        title = "Borrow CPU/NET"
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
        
    }
}

//MARK: UITableViewDataSource

extension RexBorrowViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cellType = CellType(rawValue: indexPath.row) else { preconditionFailure() }
        
        switch cellType {
        case .fund:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RexFundCell", for: indexPath) as! RexFundCell
            return cell
        }
        
    }
}
