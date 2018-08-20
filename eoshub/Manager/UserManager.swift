//
//  AuthManager.swift
//  eoshub
//
//  Created by kein on 2018. 7. 29..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import FirebaseAuth

class UserManager {
    static let shared = UserManager()
    
    var profileURL: URL? {
        return Auth.auth().currentUser?.urlForProfileImageFor(imageResolution: .highres)
    }
    
    var userId: String {
        return Auth.auth().currentUser?.uid ?? "UnknownID"
    }
    
    var identiferString: String {
       return Auth.auth().currentUser?.identifierString ?? ""
    }

    
}

extension User {
    
    var identifierString: String {
        if let email = email {
            return email + " (\(loginType.rawValue))"
        }
        return "from \(loginType.rawValue)"
    }
    
    enum LoginType: String {
        case anonymous
        case email
        case facebook
        case google
        case unknown
    }
    
    var loginType: LoginType {
        if isAnonymous { return .anonymous }
        for userInfo in providerData {
            switch userInfo.providerID {
            case FacebookAuthProviderID: return .facebook
            case GoogleAuthProviderID  : return .google
            case EmailAuthProviderID   : return .email
            default                    : break
            }
        }
        return .unknown
    }
    
    enum ImageResolution {
        case thumbnail
        case highres
        case custom(size: UInt)
    }
    
    var facebookUserId : String? {
        for userInfo in providerData {
            switch userInfo.providerID {
            case FacebookAuthProviderID: return userInfo.uid
            default                    : break
            }
        }
        return nil
    }
    
    
    func urlForProfileImageFor(imageResolution: ImageResolution) -> URL? {
        
        switch imageResolution {
        //for thumnail we just return the std photoUrl
        case .thumbnail         : return photoURL
        //for high res we use a hardcoded value of 1024 pixels
        case .highres           : return urlForProfileImageFor(imageResolution:.custom(size: 200))
        //custom size is where the user specified its own value
        case .custom(let size)  :
            if let photoURLString = photoURL?.absoluteString, photoURLString.hasPrefix("https://graph.facebook.com") == true {
                let urlString = photoURLString + "/picture?height=\(size)"
                return URL(string: urlString)
            }
            
            switch loginType {
            //for facebook we assemble the photoUrl based on the facebookUserId via the graph API
            case .facebook :
                guard let facebookUserId = facebookUserId else { return photoURL }
                return URL(string: "https://graph.facebook.com/\(facebookUserId)/picture?height=\(size)")
            //for google the trick is to replace the s96-c with our own requested size...
            case .google   :
                guard var url = photoURL?.absoluteString else { return photoURL }
                url = url.replacingOccurrences(of: "/s96-c/", with: "/s\(size)-c/")
                return URL(string:url)
            //all other providers we do not support anything special (yet) so return the standard photoURL
            default        : return photoURL
            }
        }
    }
    
}
