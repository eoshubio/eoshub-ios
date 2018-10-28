//
//  Dapp.swift
//  eoshub
//
//  Created by kein on 23/10/2018.
//  Copyright © 2018 EOS Hub. All rights reserved.
//

import Foundation

class Dapp {
    let id: String
    let iconUrl: URL?
    let title: String
    let subTitle: String
    let url: URL
    
    init(id: String, title: String, subTitle: String, url:URL, iconUrl: URL? = nil) {
        self.id = id
        self.title = title
        self.subTitle = subTitle
        self.url = url
        self.iconUrl = nil
    }
}

