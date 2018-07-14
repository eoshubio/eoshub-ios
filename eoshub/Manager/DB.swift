//
//  DBManager.swift
//  eoshub
//
//  Created by kein on 2018. 7. 13..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import RealmSwift
import KeychainSwift

class DB {
    static let shared = DB()
    
    private var notNotifyingTokens: [NotificationToken] = []
    
    fileprivate static let migrationBlock: MigrationBlock = { (migration, oldSchemaVersion) in
        if oldSchemaVersion < 1 {
            
        }
    }
    
    
    let realm: Realm
    

    
    init() {
        let encryptedKeyData = Security.shared.getDBKeyData()
        
        //Encrypted Realm Config
        var encryptionConfig = Realm.Configuration(encryptionKey: encryptedKeyData, readOnly: false, schemaVersion: 1)
        
        encryptionConfig.fileURL = encryptionConfig.fileURL!
            .deletingLastPathComponent()
            .appendingPathComponent("wallet.realm")
      
        
        realm = try! Realm(configuration: encryptionConfig)
        
    }
    
    //MARK: EOSHub user
    func addUser(user: EHUser) {
        safeWrite {
            realm.add(user)
        }
    }
   
    func getUser(from: LoginType) -> EHUser? {
        return realm.objects(EHUser.self).filter("from = '\(from.rawValue)'").first
    }
    
    //MARK: EOS Account
    func addAccount(account: EHAccount) {
        //TODO: 중복검사
        safeWrite {
            realm.add(account)
        }
    }
    
    func getAccounts() -> Results<EHAccount> {
        return realm.objects(EHAccount.self)
    }
    
}

//MARK: Utils
extension DB {
    func addNotNotifyingToken(_ token: NotificationToken?) {
        guard let t = token else { return }
        notNotifyingTokens.append(t)
    }
    
    func removeNotNotifyingToken(_ token: NotificationToken?) {
        guard let t = token else { return }
        notNotifyingTokens = notNotifyingTokens.filter { $0 != t }
    }
    
    
    
    func safeWrite(block: ()->Void) {
        dispatch_sync_on_mainThread {
            if realm.isInWriteTransaction {
                block()
            } else {
                try? realm.write {
                    block()
                }
            }
        }
    }
    
    func safeWriteAsync(block: @escaping ()->Void) {
        dispatch_async_on_mainThread {
            if self.realm.isInWriteTransaction {
                block()
            } else {
                try? self.realm.write {
                    block()
                }
            }
        }
    }
    
    func safeWrite(block: ()->Void, withoutNotifying tokens: [NotificationToken])  {
        dispatch_sync_on_mainThread {
            if realm.isInWriteTransaction {
                block()
            } else {
                realm.beginWrite()
                block()
                try? realm.commitWrite(withoutNotifying: tokens)
            }
        }
    }
    
    
    func safeWriteWithoutNotifying(block: ()->Void) {
        safeWrite(block: block, withoutNotifying: notNotifyingTokens)
    }
    
    func deleteAll() {
        safeWrite {
            realm.deleteAll()
        }
    }
    
    
    
    
    
    
    
    
}
