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
import RxSwift
import FirebaseAuth

class SettingViewController: FormViewController {
    
    var flowDelegate: SettingFlowEventDelegate?
    
    private let bag = DisposeBag()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        navigationController?.view.backgroundColor = UIColor.clear
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.shadowImage = UIImage()
        
        navigationController?.navigationBar.tintColor = Color.basePurple.uiColor
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: Color.basePurple.uiColor]
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: Color.basePurple.uiColor]
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationController?.navigationBar.barStyle = .default
        
        title = LocalizedString.Setting.title
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        form +++ securitySettings()
        form +++ EOSSettings()
        form +++ walletSettings()
        form +++ appSettings()
        
        let email = Auth.auth().currentUser?.identifierString ?? ""
        
        form
            
            +++ Section(email)
            <<< LabelRow(){
                $0.title = LocalizedString.Setting.logout
                $0.cellStyle = .default
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textAlignment = .center
                    cell.textLabel?.textColor = .red
                    cell.selectionStyle = .gray
                }).onCellSelection({ [weak self](_, row) in
                    print("logout")
                    let firebaseAuth = Auth.auth()
                    do {
                        try firebaseAuth.signOut()
                        if let vc = self {
                            self?.flowDelegate?.goToRoot(viewControllerToFinish: vc, animated: true, completion: nil)
                        }
                    } catch let signOutError as NSError {
                        Log.e("Error signing out: \(signOutError)")
                    }
                    row.deselect()
                })
        
        
    }
    
    
    private func securitySettings() -> Section{
        
        var section = Section(LocalizedString.Setting.security)
        
        let changePin = LabelRow(){
            $0.title = LocalizedString.Setting.Security.changePIN
            $0.cellStyle = .default
            }.cellUpdate({ (cell, row) in
                cell.selectionStyle = .gray
                cell.textLabel?.textColor = Color.darkGray.uiColor
                cell.height = { 50 }
                cell.accessoryType = .disclosureIndicator
            }).onCellSelection({ [weak self] (_, row) in
                row.deselect()
                guard let nc = self?.navigationController else { return }
                self?.flowDelegate?.goToChangePin(from: nc)
            })
        
        
        section += [changePin]
        
        let type = Security.shared.biometryType()
        var title: String = ""
        if type != .none {
            switch type {
            case .faceID:
                title = LocalizedString.Secure.Pin.useFaceId
            case .touchID:
                title = LocalizedString.Secure.Pin.useTouchId
            default:
                break
            }
            
            let changeBio = SwitchRow("changeBio") { row in
                row.title = title
                row.value = Security.shared.enableBioAuth
                }.cellUpdate { (cell, row) in
                    cell.textLabel?.textColor = Color.darkGray.uiColor
                    cell.height = { 50 }
                    cell.switchControl.onTintColor = Color.lightPurple.uiColor
                }.onChange { (row) in
                    let enabled = row.value == true
                    Security.shared.setEnableBioAuth(on: enabled)
                }
            
            section += [changeBio]
        }
        
        return section
    }
    
    private func EOSSettings() -> Section {

        var section = Section("EOS")
        let host =  PushRow<String>() {
            $0.title = LocalizedString.Setting.Host.title
            //TODO: get from server
            $0.options = ["https://api.main-net.eosnodeone.io", "https://eos.greymass.com", "https://api.cypherglass.com", "https://publicapi-mainnet.eosauthority.com", "https://mainnet.eoscanada.com"]
            $0.value = Preferences.shared.preferHost
            
            }.cellUpdate { (cell, row) in
                cell.textLabel?.textColor = Color.darkGray.uiColor
                cell.height = { 50 }
            }.onChange({ [weak self](row) in
                guard let `self` = self else { return }
                guard let host = row.value else { return }
                EOSHost.shared.host = host
                
                RxEOSAPI.getInfo()
                    .subscribe(onNext: { (_) in
                        Preferences.shared.preferHost = host
                        Popup.present(style: .success, description: LocalizedString.Setting.Host.success)
                    }, onError: { (error) in
                        //TODO: check https_plugin
                        Popup.present(style: .failed, description: LocalizedString.Setting.Host.failed)
                        EOSHost.shared.host = Preferences.shared.preferHost
                    })
                    .disposed(by: self.bag)
                
            })
        
        section += [host]
        
        return section
    }
    
    private func walletSettings() -> Section {
        var section = Section(LocalizedString.Setting.wallet)
        
        let showDetailInfo = SwitchRow("showDetailInfo") { row in
            row.title = LocalizedString.Setting.Wallet.showDetail
            row.value = true
            }.cellUpdate { (cell, row) in
                cell.textLabel?.textColor = Color.darkGray.uiColor
                cell.height = { 50 }
                cell.switchControl.onTintColor = Color.lightPurple.uiColor
            }.onChange { (row) in
                let enabled = row.value == true
                
        }
        
        let hideTokens = SwitchRow("hideTokens") { row in
            row.title = LocalizedString.Setting.Wallet.hideTokens
            row.value = false
            }.cellUpdate { (cell, row) in
                cell.textLabel?.textColor = Color.darkGray.uiColor
                cell.height = { 50 }
                cell.switchControl.onTintColor = Color.lightPurple.uiColor
            }.onChange { (row) in
                let enabled = row.value == true
                
        }
        
        section += [showDetailInfo, hideTokens]
        
        
        return section
    }
    
    private func appSettings() -> Section {
        var section = Section(LocalizedString.Setting.app)
        
        let version = LabelRow() {
            $0.title = LocalizedString.Setting.App.version
            $0.value = Config.versionString
            $0.cellStyle = .value1
            }.cellUpdate { (cell, row) in
                cell.textLabel?.textColor = Color.darkGray.uiColor
                cell.detailTextLabel?.textColor = Color.lightGray.uiColor
                cell.height = { 50 }
                cell.isUserInteractionEnabled = false
        }
        
        let github = LabelRow() {
            $0.title = "Github"
            $0.value = "https://github.com/eoshubio/eoshub-ios"
            $0.cellStyle = .value1
            }.cellUpdate { (cell, row) in
                cell.textLabel?.textColor = Color.darkGray.uiColor
                cell.detailTextLabel?.textColor = Color.blue.uiColor
                cell.detailTextLabel?.font = Font.appleSDGothicNeo(.regular).uiFont(14)
                cell.height = { 50 }
            }.onCellSelection({ [weak self](_, row) in
                self?.goToURL(urlString: row.value!)
                row.deselect()
            })
        
        
        
        let openSource = LabelRow() {
            $0.title = LocalizedString.Setting.App.license
            $0.cellStyle = .default
            }.cellUpdate { (cell, row) in
                cell.textLabel?.textColor = Color.darkGray.uiColor
                cell.height = { 50 }
                cell.accessoryType = .disclosureIndicator
            }.onCellSelection({ [weak self](_, row) in
                guard let nc = self?.navigationController else { return }
                self?.flowDelegate?.goToLicense(from: nc)
                row.deselect()
            })
        
        let term = LabelRow() {
            $0.title = LocalizedString.Term.term.capitalized
            $0.cellStyle = .default
            }.cellUpdate { (cell, row) in
                cell.textLabel?.textColor = Color.darkGray.uiColor
                cell.height = { 50 }
                cell.accessoryType = .disclosureIndicator
            }.onCellSelection({ (_, row) in
                row.deselect()
                let url = EOSHubAPI.URL.term.getHtml()
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            })
        
        let privacyPolicy = LabelRow() {
            $0.title = LocalizedString.Term.goPrivacy.capitalized
            $0.cellStyle = .default
            }.cellUpdate { (cell, row) in
                cell.textLabel?.textColor = Color.darkGray.uiColor
                cell.height = { 50 }
                cell.accessoryType = .disclosureIndicator
            }.onCellSelection({ (_, row) in
                row.deselect()
                let url = EOSHubAPI.URL.privacy_policy.getHtml()
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            })
        
        let telegram = LabelRow() {
            $0.title = LocalizedString.Setting.App.telegram
            $0.value = "EOSHub official community"
            $0.cellStyle = .value1
            }.cellUpdate { (cell, row) in
                cell.textLabel?.textColor = Color.darkGray.uiColor
                cell.detailTextLabel?.textColor = Color.blue.uiColor
                cell.height = { 50 }
            }.onCellSelection({ (_, row) in
                row.deselect()
                if let url = URL(string: "https://t.me/joinchat/IIRAOk205MY9QrHxL0n4Lw"), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
                
            })
        
        section += [version, github, openSource, term, privacyPolicy, telegram]
        
        return section
    }
    
    
    
    
}

extension SettingViewController {
    func goToURL(urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
