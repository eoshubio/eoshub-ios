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
        var encryptionConfig = Realm.Configuration(encryptionKey: encryptedKeyData, readOnly: false, schemaVersion: 2, migrationBlock: DB.migrationBlock)
        
        encryptionConfig.fileURL = encryptionConfig.fileURL!
            .deletingLastPathComponent()
            .appendingPathComponent("wallet.realm")
      
        
        realm = try! Realm(configuration: encryptionConfig)
        
    }
    

    //MARK: EOS Account
    func addAccount(account: EHAccount) {
        //TODO: 중복검사
        safeWrite {
            realm.add(account)
        }
    }
    
    func deleteAccount(account: String) {
        if let willDeleteAccount = getAccounts().filter("account = '\(account)'").first {
            DB.shared.safeWrite {
                realm.delete(willDeleteAccount)
            }
        }
    }
    
    func deleteAccount(account: AccountInfo) {
        if let willDeleteAccount = getAccounts().filter("account = '\(account.account)'").first {
            DB.shared.safeWrite {
                realm.delete(willDeleteAccount)
                realm.delete(account)
            }
        }
    }
    
    func getAccounts() -> Results<EHAccount> {
        return realm.objects(EHAccount.self)
    }
    
    func getAccountInfos() -> Results<AccountInfo> {
        return realm.objects(AccountInfo.self)
    }
    
    func getTxs() -> Results<Tx> {
        return realm.objects(Tx.self)
    }
    
    func getTokens() -> Results<TokenInfo> {
        return realm.objects(TokenInfo.self)
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
    
    
    func addOrUpdateObjects<Element: DBObject>(_ newObjects: [Element]) where Element: Mergeable {
        safeWrite {
            var newObjectsMap: [String: Element] = [:]
            newObjects.forEach({ newObjectsMap[$0.id] = $0 })
            
            let oldObjects = realm.objects(Element.self)
            
            for oldObject in oldObjects {
                guard let newObject = newObjectsMap[oldObject.id] else {
                    continue
                }
                
                newObjectsMap[oldObject.id] = nil
                oldObject.mergeChanges(from: newObject)
            }
            
            let brandNewObjects = newObjectsMap.values
            realm.add(brandNewObjects, update: false)
        }
    }
    
    func syncObjects<Element: DBObject>(_ newObjects: [Element]) where Element: Mergeable {
        safeWrite {
            var newObjectsMap: [String: Element] = [:]
            newObjects.forEach({ newObjectsMap[$0.id] = $0 })
            
            let oldObjects = realm.objects(Element.self)
            
            var deleteObjects: [Element] = []
            
            for oldObject in oldObjects {
                guard let newObject = newObjectsMap[oldObject.id] else {
                    deleteObjects.append(oldObject)
                    continue
                }
                
                newObjectsMap[oldObject.id] = nil
                oldObject.mergeChanges(from: newObject)
            }
            
            let brandNewObjects = newObjectsMap.values
            realm.add(brandNewObjects, update: false)
            realm.delete(deleteObjects)
            
        }
        
        
        
    }
}
