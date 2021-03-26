//
//  LoginType.swift
//  eoshub
//
//  Created by kein on 2018. 7. 8..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit


enum LoginType: String {
    case apple, facebook, google, kakao
    case email
    case none
    
    var title: String {
        switch self {
        case .apple:
            return LocalizedString.Login.apple
        case .facebook:
            return LocalizedString.Login.facebook
        case .google:
            return LocalizedString.Login.google
        case .kakao:
            return LocalizedString.Login.kakao
        case .email:
            return LocalizedString.Login.email
        case .none:
            return LocalizedString.Login.none
        }
    }
    

}
