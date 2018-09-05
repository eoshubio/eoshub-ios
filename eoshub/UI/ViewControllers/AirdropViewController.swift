//
//  AirdropViewController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 9..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import SDWebImage

class AirdropViewController: BaseViewController {
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    fileprivate let event = AirdropUIEvent()
    
    var items = [Airdrop]()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        makeDummy()
    }
    
    private func setupUI() {
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 100, 0)
        
        
    }

    private func makeDummy() {
        
        
        let ono = Airdrop(title: "ONO", tag: "Airdrop",
                          text0: "Total supply", textSub0: "10,000,000,000 ONO",
                          text1: "Expire date", textSub1: "16/08/2018",
                          expireAt: Date().timeIntervalSince1970 + 96000,
                          iconURL: nil, bannerURL: Bundle.main.url(forResource: "banner_ono", withExtension: "png"),
                          linkURL: nil)
        
        let eosdac = Airdrop(title: "EosDAQ (EOSDAC)", tag: "Airdrop",
                          text0: "Total supply", textSub0: "1,200,000,000 EOSDAC",
                          text1: "Expire date", textSub1: "03/06/2018",
                          expireAt: Date().timeIntervalSince1970 - 3000,
                          iconURL: Bundle.main.url(forResource: "icon_eosdac", withExtension: "png"),
                          bannerURL: Bundle.main.url(forResource: "banner_eosdac", withExtension: "png"),
                          linkURL: nil)
        
        let add = Airdrop(title: "ADD (ADD)", tag: "Airdrop",
                              text0: "Total supply", textSub0: "100,000,000,000 ADD",
                              text1: "Expire date", textSub1: "03/06/2018",
                              expireAt: Date().timeIntervalSince1970 - 3000,
                              iconURL: nil, bannerURL: nil,
                              linkURL: nil)
        
        let pandora = Airdrop(title: "Pandora (PDR)", tag: "Airgrap",
                             text0: "Total supply", textSub0: "10,000,000,000 PDR",
                             text1: "Expire date", textSub1: "02/09/2018",
                             expireAt: Date().timeIntervalSince1970 + 206000,
                             iconURL: nil, bannerURL: Bundle.main.url(forResource: "banner_pandora", withExtension: "png"),
                             linkURL: nil)
        
        items = [ono, eosdac, add, pandora]
    }
    
}


extension AirdropViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AirdropCell", for: indexPath) as? AirdropCell else { preconditionFailure() }
        
        let item = items[indexPath.row]
        
        cell.configure(model: item, event: event)
        
        return cell
    }
    
    
}


class AirdropCell: UITableViewCell {
    @IBOutlet fileprivate weak var tokenTitle: UILabel!
    @IBOutlet fileprivate weak var tokenIcon: UIImageView!
    @IBOutlet fileprivate weak var tagView: BorderColorButton!
    @IBOutlet fileprivate weak var expireView: BorderColorButton!
    @IBOutlet fileprivate weak var banner: UIImageView!
    @IBOutlet fileprivate weak var text0: UILabel!
    @IBOutlet fileprivate weak var textSub0: UILabel!
    @IBOutlet fileprivate weak var text1: UILabel!
    @IBOutlet fileprivate weak var textSub1: UILabel!
    @IBOutlet fileprivate weak var btnMore: UIButton!
    @IBOutlet fileprivate weak var layoutBannerRatio: NSLayoutConstraint!
    
    private var bag: DisposeBag? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = nil
    }
    
    private func setupUI() {
        tagView.setThemeColor(fgColor: tagView.titleColor(for: .normal)!, bgColor: .clear, state: .normal, border: true)
        expireView.setThemeColor(fgColor: expireView.titleColor(for: .normal)!, bgColor: .clear, state: .normal, border: true)
        tokenIcon.layer.cornerRadius = tokenIcon.bounds.height * 0.5
        tokenIcon.layer.masksToBounds = true
    }
    
    func configure(model: Airdrop, event: AirdropUIEvent) {
        let bag = DisposeBag()
        self.bag = bag
        
        tokenTitle.text = model.title
        tokenIcon.sd_setImage(with: model.iconURL, completed: nil)
        tagView.setTitle(model.tag, for: .normal)
        
        
        if model.bannerURL != nil {
            let ratio: CGFloat = 0.25
            self.layoutBannerRatio.constant = self.banner.bounds.width * ratio
            self.banner.isHidden = false
        } else {
            self.layoutBannerRatio.constant = 1
            self.banner.isHidden = true
        }
        layoutIfNeeded()
        
        banner.sd_setImage(with: model.bannerURL)
        
        text0.text = model.text0
        textSub0.text = model.textSub0
        text1.text = model.text1
        textSub1.text = model.textSub1
        
        let remainTime = (model.expireAt ?? 0) - Date().timeIntervalSince1970
        let remain = remainTime > 0 ? remainTime.stringTime : "Expired"
        
        expireView.setTitle(remain, for: .normal)
    }
    
}

struct AirdropUIEvent {
    
}

