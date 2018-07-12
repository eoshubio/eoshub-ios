//
//  TxViewController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 13..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class TxViewController: BaseTableViewController {
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = LocalizedString.Tx.title
        showNavigationBar(with: .white)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        
    }
    
}

extension TxViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TxCell", for: indexPath) as? TxCell else { preconditionFailure() }
        
        
        return cell
    }
    
}


class TxCell: UITableViewCell {
    @IBOutlet fileprivate weak var lbInOut: UILabel!
    @IBOutlet fileprivate weak var lbQuantity: UILabel!
    @IBOutlet fileprivate weak var lbSymbol: UILabel!
    @IBOutlet fileprivate weak var lbTxDate: UILabel!
    @IBOutlet fileprivate weak var lbTxIdTitle: UILabel!
    @IBOutlet fileprivate weak var btnTxId: UIButton!
    @IBOutlet fileprivate weak var lbStateTitle: UILabel!
    @IBOutlet fileprivate weak var lbState: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        lbTxIdTitle.text = LocalizedString.Tx.id
        lbStateTitle.text = LocalizedString.Tx.state
        btnTxId.titleLabel?.numberOfLines = 2
        btnTxId.titleLabel?.textAlignment = .right
        
        //test
        lbInOut.text = LocalizedString.Tx.sended
        lbQuantity.text = "24153.3453"
        lbSymbol.text = "EOS"
        lbTxDate.text = "18.07.10 23:12:03"
        btnTxId.setTitle("ef2c84969b827ce59ee1274199a390f2b34660d894219e27e03454f6e3511da7", for: .normal)
        
    }
    
}
