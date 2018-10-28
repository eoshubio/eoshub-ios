//
//  DappViewController.swift
//  eoshub
//
//  Created by kein on 23/10/2018.
//  Copyright © 2018 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

class DappViewController: BaseTableViewController {
    
     var flowDelegate: DappFlowEventDelegate?
    
    fileprivate var items: [Dapp] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar(with: .basePurple, animated: animated, largeTitle: true)
        title = "Dapp list"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        setupUI()
        bindActions()
    }
    
    private func setupUI() {
      
    }
    
    private func bindActions() {
        
    }
    
    private func loadData() {
        items = [Dapps.gameboy]
    }
    
}

extension DappViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == items.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DappContractInfoCell", for: indexPath)
            return cell
        } else {
            let dapp = items[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "DappInfoCell", for: indexPath) as! DappInfoCell
            cell.configure(model: dapp)
            return cell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dapp = items[indexPath.row]
        //go to webview
        guard let nc = navigationController else { return }
        
        let dappAction = DappAction(dapp: dapp)

        flowDelegate?.goToDappWeb(from: nc, dappAction: dappAction)
        
    }
    
}



class DappInfoCell: UITableViewCell {
    @IBOutlet fileprivate weak var icon: UIImageView!
    @IBOutlet fileprivate weak var title: UILabel!
    @IBOutlet fileprivate weak var subTitle: UILabel!
    @IBOutlet fileprivate weak var tagNew: BorderColorButton!
    @IBOutlet fileprivate weak var tagFeatured: BorderColorButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        icon.sd_cancelCurrentImageLoad()
        icon.image = nil
        
    }
    
    private func setupUI() {
        tagNew.setThemeColor(fgColor: Color.progressOrange.uiColor, bgColor: .clear, state: .normal, border: true)
        
        tagFeatured.setThemeColor(fgColor: Color.progressMagenta.uiColor, bgColor: .clear, state: .normal, border: true)
    
    }
    
    func configure(model: Dapp) {
        if let iconUrl = model.iconUrl {
            icon.sd_setImage(with: iconUrl, completed: nil)
        }
        title.text = model.title
        subTitle.text = model.subTitle
        
    }
}
