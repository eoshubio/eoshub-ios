//
//  WalletGuideCell.swift
//  eoshub
//
//  Created by kein on 2018. 7. 10..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class WalletGuideCell: UITableViewCell {
    @IBOutlet fileprivate weak var guide: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        guide.text = "첫번째 EOS 지갑을 추가하려면, 이 버튼을 누르세요."
    }
}


