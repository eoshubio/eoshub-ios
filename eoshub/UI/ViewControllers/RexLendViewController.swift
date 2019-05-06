//
//  RexLendViewController.swift
//  eoshub
//
//  Created by kein on 06/05/2019.
//  Copyright © 2019 EOS Hub. All rights reserved.
//

import Foundation

class RexLendViewController: BaseTableViewController {
    
    var flowDelegate: RexFlowEventDelegate?
    
    enum CellType: Int, CaseIterable {
        case fund, buy, sell, unstake
    }
    
    fileprivate let items = [CellType.buy, .sell, .unstake]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar(with: .basePurple, animated: animated, largeTitle: true)
        title = "Lend / Unlend"
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

extension RexLendViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellType = items[indexPath.row]
        
        switch cellType {
        case .fund:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RexFundCell", for: indexPath) as! RexFundCell
            return cell
        case .buy:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RexBuySellCell", for: indexPath) as! RexBuySellCell
            return cell
        case .sell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RexBuySellCell", for: indexPath) as! RexBuySellCell
            return cell
        case .unstake:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RexUnstakeCell", for: indexPath) as! RexUnstakeCell
            return cell
        }
        
    }
}

class RexBuySellCell: UITableViewCell {
    
}


class RexUnstakeCell: UITableViewCell {
    
}
