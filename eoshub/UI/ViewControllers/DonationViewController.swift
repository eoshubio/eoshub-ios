//
//  DonationViewController.swift
//  eoshub
//
//  Created by kein on 2018. 8. 26..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import RxSwift


class DonationViewController: BaseTableViewController {
    
    var flowDelegate: DonateFlowEventDelegate?
    
    fileprivate var account: AccountInfo?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar(with: .basePurple, animated: animated, largeTitle: true)
        title = "Donate"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func configure(account: AccountInfo?) {
        if account == nil {
            let accounts = Array(AccountManager.shared.ownerInfos).sorted { (lhs, rhs) -> Bool in
                            return lhs.availableEOS > rhs.availableEOS
                            }
            
            let firstAccount = accounts.first
            self.account = firstAccount
        } else {
            self.account = account!
        }
    }
    
    private func setupUI() {
        
    }
    
   
}

extension DonationViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DonateInfoCell") as! DonateInfoCell
            cell.selectionStyle = .none
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DonateToCell") as! DonateToCell
            cell.selectionStyle = .none
            return cell
        default:
            preconditionFailure()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            //goToSend
            guard let nc = navigationController, let account = account else { return }
            flowDelegate?.goToSend(from: nc, account: account, to: Config.donationAccount)
        }
    }
}


class DonateInfoCell: UITableViewCell {
    @IBOutlet fileprivate weak var lbText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        
    }
}

class DonateToCell: UITableViewCell {
    
    @IBOutlet fileprivate weak var lbDonate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        let donationAccount = Config.donationAccount
        let text = NSMutableAttributedString(string: "Donate EOS to EOSHub: eoshuborigin")
        text.addAttributeFont(text: donationAccount, font: Font.appleSDGothicNeo(.semiBold).uiFont(14))
        text.addAttributeColor(text: donationAccount, color: Color.basePurple.uiColor)
        lbDonate.attributedText = text
    }
}
