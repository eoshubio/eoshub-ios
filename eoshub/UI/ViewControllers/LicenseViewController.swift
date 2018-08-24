//
//  LicenseViewController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 28..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import Eureka
import RxSwift


class LicenseViewController: FormViewController {
    
    var flowDelegate: FlowEventDelegate?

    private let bag = DisposeBag()
    
    var licenses: [License] = []
    var licenseDescriptions: [LicenseDescription] = []
    
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
        
        
        title = LocalizedString.Setting.App.license
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        setupUI()
    }
    
    private func loadData() {
        licenses = [.Alamofire, .Chainkit, .Eureka, .KeychainSwift, .QRCode, .Realm, .RNCryptor, .RxSwift, .Firebase, .SDWebImage]
        if let jsonURL = Bundle.main.url(forResource: "LicenseDescriptions", withExtension: "json"),
            let jsonData = try? Data(contentsOf: jsonURL),
            let json = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? JSON,
            let list = json?.arrayJson(for: "list") {
            
            licenseDescriptions = list.compactMap(LicenseDescription.init)
            
        }

    }
    
    private func setupUI() {
        form +++ addLicensesSection()
        form +++ addLicenseDescriptions()
    }
    
    private func addLicensesSection() -> Section {
        var section = Section("Licenses")
        
        licenses.forEach { (license) in
            
            let telegram = LabelRow() {
                $0.title = license.title
                $0.cellStyle = .subtitle
                }.cellUpdate { (cell, row) in
                    cell.textLabel?.textColor = Color.darkGray.uiColor
                    cell.detailTextLabel?.textColor = Color.lightGray.uiColor
                    cell.detailTextLabel?.numberOfLines = 5
                    let text = license.link + "\n" + license.description
                    let attrText = NSMutableAttributedString(string: text)
                    if let linkRange = text.range(of: license.link) {
                        attrText.addAttribute(NSAttributedStringKey.link, value: license.link, range: linkRange.nsRange)
                        attrText.addAttribute(NSAttributedStringKey.foregroundColor, value: Color.blue.uiColor, range: linkRange.nsRange)
                    }
                    
                    cell.detailTextLabel?.attributedText = attrText
                    
                    cell.height = { UITableViewAutomaticDimension }
                }.onCellSelection({ (_, row) in
                    row.deselect()
                })
            
            section += [telegram]
            
        }
        
        return section
    }
    
    private func addLicenseDescriptions() -> Section {
        var section = Section("")
        
        licenseDescriptions.forEach { (license) in
            
            let telegram = LabelRow() {
                $0.title = license.title
                $0.cellStyle = .subtitle
                $0.value = license.description
                }.cellUpdate { (cell, row) in
                    cell.textLabel?.textColor = Color.darkGray.uiColor
                    cell.detailTextLabel?.textColor = Color.lightGray.uiColor
                    cell.detailTextLabel?.numberOfLines = -1
                    
                    cell.height = { UITableViewAutomaticDimension }
                }.onCellSelection({ (_, row) in
                    row.deselect()
                })
            
            section += [telegram]
            
        }
        
        return section
    }
}

struct License {
    let title: String
    let link: String
    let description: String
}

extension License {
    static var Alamofire: License {
        let link = "https://github.com/Alamofire/Alamofire"
        let description = "Copyright (c) 2014-2018 Alamofire Software Foundation (http://alamofire.org/)\nMIT License (MIT)"
        
        return License(title: "Alamofire", link: link, description: description)
    }

    static var Chainkit: License {
        let link = "https://github.com/OracleChain/chainkit"
        let description = "Copyright (c) OracleChain\nGNU/LGPL Version 3"
        
        return License(title: "Chainkit", link: link, description: description)
    }
    
    static var Eureka: License {
        let link = "https://github.com/xmartlabs/Eureka"
        let description = "Copyright (c) 2015 XMARTLABS\nMIT License (MIT)"
        
        return License(title: "Eureka", link: link, description: description)
    }
    
    static var KeychainSwift: License {
        let link = "https://github.com/evgenyneu/keychain-swift"
        let description = "Copyright (c) 2015 Marketplacer\nMIT License (MIT)"
        
        return License(title: "Keychain-swift", link: link, description: description)
    }
    
    static var QRCode: License {
        let link = "https://github.com/aschuch/QRCode"
        let description = "Copyright (c) 2015 Alexander Schuch (http://schuch.me)\nMIT License (MIT)"
        
        return License(title: "QRCode", link: link, description: description)
    }
    
    static var Realm: License {
        let link = "https://github.com/realm/realm-cocoa"
        let description = "Copyright (c) 2016 Realm Inc.\nApache License 2.0"
        
        return License(title: "Realm-cocoa", link: link, description: description)
    }
    
    static var RxSwift: License {
        let link = "https://github.com/ReactiveX/RxSwift"
        let description = "Copyright © 2015 Krunoslav Zaher\nMIT License (MIT)"
        
        return License(title: "RxSwift", link: link, description: description)
    }
    
    static var RNCryptor: License {
        let link = "https://github.com/RNCryptor/RNCryptor"
        let description = "Copyright (c) 2015 Rob Napier\nMIT License (MIT)"
        
        return License(title: "RNCryptor", link: link, description: description)
    }
    
    static var SDWebImage: License {
        let link = "https://github.com/rs/SDWebImage"
        let description = "Copyright (c) 2009-2017 Olivier Poitrey rs@dailymotion.com\nMIT License (MIT)"
        
        return License(title: "SDWebImage", link: link, description: description)
    }
    
    static var Firebase: License {
        let link = "https://github.com/firebase/firebase-ios-sdk"
        let description = "Apache License 2.0"
        
        return License(title: "Firebase", link: link, description: description)
    }
    
  
}


struct LicenseDescription: JSONInitializable {
    let title: String
    let description: String
    
    init?(json: JSON) {
        
        guard let title = json.string(for: "title"), let text = json.string(for: "text") else { return nil }
        self.title = title
        self.description = text
    }
}






