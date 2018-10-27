//
//  Dapps.swift
//  eoshub
//
//  Created by kein on 23/10/2018.
//  Copyright © 2018 EOS Hub. All rights reserved.
//

import Foundation

struct Dapps {
    static var gameboy: Dapp {
        let id = "eosgameboy"
        let url =  URL(string: "https://m.rps.eosgameboy.io")!
        let title = "EOSGameboy - Rock Scissors Paper"
        let subTitle = "rps.eosgameboy.io"
        let icon = Bundle.main.url(forResource: "icon_eosdac", withExtension: "png") //dummy
        
        return Dapp(id: id, title: title, subTitle: subTitle, url: url, iconUrl: icon)
        
    }
    
    static var list: [Dapp] = [Dapps.gameboy]
    
}
