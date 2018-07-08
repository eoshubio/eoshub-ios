//
//  SettingViewController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 8..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import Eureka


class SettingViewController: FormViewController {
    
    var flowDelegate: SettingFlowEventDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
//        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.barTintColor = Color.baseGray.uiColor
        navigationController?.navigationBar.tintColor = UIColor.black
        navigationController?.navigationBar.prefersLargeTitles = true
        title = LocalizedString.Setting.title
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        form +++ Section(LocalizedString.Setting.security)
            <<< TextRow(){ row in
                row.title = "Text Row"
                row.placeholder = "Enter text here"
            }
            <<< PhoneRow(){
                $0.title = "Phone Row"
                $0.placeholder = "And numbers here"
            }
            +++ Section(LocalizedString.Setting.wallet)
            <<< DateRow(){
                $0.title = "Date Row"
                $0.value = Date(timeIntervalSinceReferenceDate: 0)
            }
            +++ Section(LocalizedString.Setting.app)
            <<< DateRow(){
                $0.title = "Date Row"
                $0.value = Date(timeIntervalSinceReferenceDate: 0)
            }
            +++ Section("")
            <<< LabelRow(){
                $0.title = LocalizedString.Setting.logout
                $0.cellStyle = .default
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textAlignment = .center
                    cell.textLabel?.textColor = .red
                    cell.selectionStyle = .gray
                }).onCellSelection({ (_, row) in
                    print("logout")
                    row.deselect()
                })
        
        
    }
}
