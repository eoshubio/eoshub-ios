//
//  LoginType.swift
//  eoshub
//
//  Created by kein on 2018. 7. 8..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit


enum LoginType {
    case facebook, google, kakao
    
    var title: String {
        switch self {
        case .facebook:
            return LocalizedString.Login.facebook
        case .google:
            return LocalizedString.Login.google
        case .kakao:
            return LocalizedString.Login.kakao
        }
    }
    

}
