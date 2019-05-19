//
//  RexRemainTimeViewController.swift
//  eoshub
//
//  Created by kein on 19/05/2019.
//  Copyright © 2019 EOS Hub. All rights reserved.
//

import Foundation

class RexRemainTimeViewController: BaseTableViewController {
    
    
    fileprivate var maturities: [RexMaturity]!
    
    func configure(rexInfo: RexInfo) {
        maturities = rexInfo.balance.maturities
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar(with: .basePurple, animated: animated, largeTitle: true)
        title = "Maturities"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        
    }
}

extension RexRemainTimeViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return maturities.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RexMaturityCell", for: indexPath)
        let item = maturities[indexPath.row]
        cell.textLabel?.text = item.rex.stringValue
        cell.detailTextLabel?.text = Date(timeIntervalSince1970: item.timestamp).dataToLocalTime()
        return cell
    }
}
