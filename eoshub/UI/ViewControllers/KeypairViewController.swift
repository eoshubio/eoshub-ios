//
//  KeypairViewController.swift
//  eoshub
//
//  Created by kein on 2018. 8. 20..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class KeypairViewController: BaseTableViewController {
    
    fileprivate var account: AccountInfo!
    
    fileprivate var items: [[Key]] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar(with: .basePurple, animated: animated, largeTitle: true)
        title = LocalizedString.Wallet.Detail.keypairs
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        setupUI()
        bindActions()
    }
    
    func configure(account: AccountInfo) {
        self.account = account
        
    }
    
    private func loadData() {
        let secure = Security.shared
        let ownerKeys = account.ownerKeys.map { (key) -> KeypairViewController.Key in
            let repo = secure.getKeyRepository(pub: key)
            let stored = repo != .none
            return Key(key: key, permission: Permission.owner.value, stored: stored, repo: repo)
        }
        items.append(ownerKeys)
        let activeKeys = account.activeKeys.map { (key) -> KeypairViewController.Key in
            let repo = secure.getKeyRepository(pub: key)
            let stored = repo != .none
            return Key(key: key, permission: Permission.active.value, stored: stored, repo: repo)
        }
        items.append(activeKeys)
        
    }
    
    private func setupUI() {
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 20, 0)
    }
    
    private func bindActions() {
        
    }
    
    
    fileprivate struct Key {
        let key: String
        let permission: String
        let stored: Bool
        let repo: KeyRepository
    }
    
}


extension KeypairViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return  section == 0 ? "Onwer key" : "Active Key"
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as? UITableViewHeaderFooterView
        
        headerView?.textLabel?.text = section == 0 ? "Onwer key" : "Active Key"
        headerView?.textLabel?.font = Font.appleSDGothicNeo(.semiBold).uiFont(20)
        headerView?.textLabel?.textColor = Color.basePurple.uiColor
    }

  
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "KeyCell", for: indexPath) as? KeyCell else {
            preconditionFailure()
        }
        
        let key = items[indexPath.section][indexPath.row]
        
        cell.configure(pubKey: key.key, owner: key.stored, repo: key.repo)
        
        return cell
    }
}


class KeyCell: UITableViewCell {
    
    @IBOutlet fileprivate weak var stored: BorderColorButton!
    @IBOutlet fileprivate weak var repo: BorderColorButton!
    @IBOutlet fileprivate weak var key: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        stored.setThemeColor(fgColor: Color.green.uiColor, bgColor: .clear, state: .normal, border: true)
        stored.setThemeColor(fgColor: Color.lightGray.uiColor, bgColor: .clear, state: .selected, border: true)
        
        repo.setThemeColor(fgColor: Color.progressOrange.uiColor, bgColor: .clear, state: .normal, border: true)
        repo.setThemeColor(fgColor: Color.progressMagenta.uiColor, bgColor: .clear, state: .selected, border: true)
    }
    
    func configure(pubKey: String, owner: Bool, repo storedAt: KeyRepository) {
        key.text = pubKey
        if owner {
            stored.setTitle("Stored", for: .normal)
            stored.isSelected = false
        } else {
            stored.setTitle("Not Stored", for: .normal)
            stored.isSelected = true
        }
        
        switch storedAt {
        case .iCloudKeychain:
            repo.isHidden = false
            repo.isSelected = false
            repo.setTitle("iCloud Keychain", for: .normal)
        case .secureEnclave:
            repo.isHidden = false
            repo.isSelected = true
            repo.setTitle("Secure enclave", for: .normal)
        default:
            repo.isHidden = true
        }
        
    }
    
    
}



