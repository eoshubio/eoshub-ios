//
//  DBObject.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 17..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation
import RealmSwift

class DBObject: RealmSwift.Object {
    
    override static func primaryKey() -> String? { return "id" }
    
    @objc dynamic var id = ""
    
    public static func ==(lhs: DBObject, rhs: DBObject) -> Bool {
        return lhs.id == rhs.id
    }
}

class DB {
    static let shared = DB()
    
    private var notNotifyingTokens: [NotificationToken] = []
    
    fileprivate static let migrationBlock: MigrationBlock = { (migration, oldSchemaVersion) in
        if oldSchemaVersion < 1 {
            
        }
    }
    
    
    let realm: Realm
    
    init() {
        var config = Realm.Configuration(
            schemaVersion: 1, migrationBlock: DB.migrationBlock)
        config.fileURL = config.fileURL!
            .deletingLastPathComponent()
            .appendingPathComponent("wallet.realm")
        
        do {
            try Realm.performMigration(for: config)
        } catch {
            print("Migration error\n\(error)")
            let fm = FileManager.default
            if let path = config.fileURL?.path, fm.fileExists(atPath: path) {
                try? fm.removeItem(atPath: path)
            }
        }
        
        realm = try! Realm(configuration: config)
        
    }
    
    
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

