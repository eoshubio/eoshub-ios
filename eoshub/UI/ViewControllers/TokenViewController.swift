//
//  TokenViewController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 26..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class TokenViewController: BaseTableViewController {
    
    var flowDelegate: FlowEventDelegate?
    
    let knownTokens = TokenManager.shared.knownTokens
    
    var tokens: [[TokenInfo]] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.tintColor = Color.basePurple.uiColor
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: Color.basePurple.uiColor]
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: Color.basePurple.uiColor]
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.barStyle = .default
        
        
        //search bar
        let search = UISearchController(searchResultsController: nil)
        search.obscuresBackgroundDuringPresentation = false
        search.searchResultsUpdater = self
        search.searchBar.tintColor = Color.lightPurple.uiColor
        search.searchBar.keyboardType = .asciiCapable
        search.searchBar.autocapitalizationType = .none
        navigationItem.searchController = search
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.add))
        
        title = LocalizedString.Token.add
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        
    }
    
    @objc fileprivate func add() {
        TokenAddPopup.show()
            .subscribe(onNext: { (info) in
                Log.i(info.id)
                
                
            })
            .disposed(by: bag)
        
    }
    
    func loadData(filter: String? = nil) {
        
        var list = knownTokens
        
        if let filter = filter, filter.count > 0 {
            list = list.filter("id CONTAINS '\(filter)'")
        }
        
        tokens.removeAll()
        //TODO: 1. 가지고있는 토큰을 첫번째 section 에 insert
        let hasTokens = [Token.eos, Token.pandora]
        
        let addedTokens = Array(list.filter("id IN %@", hasTokens.map({$0.stringValue})))
        tokens.append(addedTokens)
        
        let notAddedTokens = list.filter("NOT id IN %@",addedTokens.map({$0.id}))
        tokens.append(Array(notAddedTokens))
        
        tableView.reloadData()
    }
    
}

extension TokenViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchController.searchBar.rx.text
            .debounce(0.3, scheduler: MainScheduler.instance)
            .bind { [weak self](text) in
                self?.loadData(filter: text)
            }
            .disposed(by: bag)
        
    }
    
}

extension TokenViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tokens.count
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tokens[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TokenAddCell", for: indexPath) as? TokenAddCell else { preconditionFailure() }
        let token = tokens[indexPath.section][indexPath.row]
        cell.configure(token: token.token, added: indexPath.section == 0)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        //TODO: PDR 삭제금지
        return indexPath.section == 0
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let token = tokens[sourceIndexPath.section][sourceIndexPath.row]
        tokens[sourceIndexPath.section].remove(at: sourceIndexPath.row)
        tokens[destinationIndexPath.section].insert(token, at: destinationIndexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
      
        let header = UIView(frame: CGRect(origin: .zero, size: CGSize(width: tableView.bounds.width, height: 44)))
        header.backgroundColor = Color.baseGray.uiColor
        
        let title = UILabel(frame: CGRect(x: 15, y: 0, width: 250, height: header.bounds.height))
        title.font = Font.appleSDGothicNeo(.semiBold).uiFont(14)
        title.textColor = Color.darkGray.uiColor
        header.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 15),
            title.centerYAnchor.constraint(equalTo: header.centerYAnchor, constant: 0)
        ])
        
        if section == 0 {
            title.text = LocalizedString.Token.added
            let btnEdit = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 30))
            btnEdit.titleLabel?.font = Font.appleSDGothicNeo(.semiBold).uiFont(15)
            btnEdit.contentHorizontalAlignment = .right
            btnEdit.setTitle(LocalizedString.Common.edit, for: .normal)
            btnEdit.setTitle(LocalizedString.Common.done, for: .selected)
            btnEdit.setTitleColor(Color.lightPurple.uiColor, for: .normal)
            btnEdit.addTarget(self, action: #selector(self.editAddedTokenSection(sender:)), for: .touchUpInside)
            header.addSubview(btnEdit)
            btnEdit.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                btnEdit.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -15),
                btnEdit.centerYAnchor.constraint(equalTo: header.centerYAnchor, constant: 0),
                btnEdit.widthAnchor.constraint(equalToConstant: 50),
                btnEdit.heightAnchor.constraint(equalToConstant: 30)
                ])
        } else {
            title.text = LocalizedString.Token.howToAdd
        }
        
        
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    @objc func editAddedTokenSection(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        tableView.setEditing(sender.isSelected, animated: true)
    }
    
}

class TokenAddCell: UITableViewCell {
    
    weak var btnAdd: UIButton!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        let add = UIButton(type: .contactAdd)
        add.isUserInteractionEnabled = false
        add.isHidden = true
        add.tintColor = Color.lightPurple.uiColor
        accessoryView = add
        btnAdd = add
        
        textLabel?.font = Font.appleSDGothicNeo(.bold).uiFont(14)
        textLabel?.textColor = Color.darkGray.uiColor
        
        detailTextLabel?.font = Font.appleSDGothicNeo(.medium).uiFont(12)
        detailTextLabel?.textColor = Color.lightGray.uiColor
        
    }
    
    func configure(token: Token, added: Bool) {
        textLabel?.text = token.symbol
        detailTextLabel?.text = "@" + token.contract
        
        btnAdd.isHidden = added
    }
}




