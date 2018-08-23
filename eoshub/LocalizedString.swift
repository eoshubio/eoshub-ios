//
//  LocalizedString.swift
//  eoshub
//
//  Created by kein on 2018. 7. 8..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation


struct LocalizedString {
    struct Intro {
        static let title = NSLocalizedString("intro.title", comment: "")
    }
    
    struct Login {
        static let facebook = NSLocalizedString("login.facebook", comment: "")
        static let kakao = NSLocalizedString("login.kakao", comment: "")
        static let google = NSLocalizedString("login.google", comment: "")
        static let email = NSLocalizedString("login.email", comment: "")
        static let none = NSLocalizedString("login.none", comment: "")
        
        struct Email {
            static let email = NSLocalizedString("login.email.email", comment: "")
            static let pw = NSLocalizedString("login.email.pw", comment: "")
            static let signin = NSLocalizedString("login.email.signin", comment: "")
            static let forgot = NSLocalizedString("login.email.forget", comment: "")
            static let verify = NSLocalizedString("login.email.verficationSent", comment: "")
        }

        struct Verify {
            static let title = NSLocalizedString("login.verify.title", comment: "")
            static let description = NSLocalizedString("login.verify.description", comment: "")
            static let confirm = NSLocalizedString("login.verify.confirm", comment: "")
            static let relogin = NSLocalizedString("login.verify.relogin", comment: "")
            static let reloginText = NSLocalizedString("login.verify.reloginText", comment: "")
        }
        
        struct ForgotPW {
            static let title = NSLocalizedString("login.forgetpw.title", comment: "")
            static let send = NSLocalizedString("login.forgetpw.send", comment: "")
        }
    }
    
    struct Term {
        static let title = NSLocalizedString("term.title", comment: "")
        static let term = NSLocalizedString("term.goTerm", comment: "")
        static let termAndPrivacy = NSLocalizedString("term.termAndPrivacy", comment: "")
        static let goPrivacy = NSLocalizedString("term.goPrivacy", comment: "")
        static let privacyDesc = NSLocalizedString("term.privacyDesc", comment: "")
        static let start = NSLocalizedString("term.start", comment: "")
    }
    
    struct Setting {
        static let title = NSLocalizedString("setting.title", comment: "")
        static let security = NSLocalizedString("setting.security", comment: "")
        static let app = NSLocalizedString("setting.app", comment: "")
        static let wallet = NSLocalizedString("setting.wallet", comment: "")
        static let logout = NSLocalizedString("setting.logout", comment: "")
        
        struct Security {
            static let changePIN = NSLocalizedString("setting.security.changePin", comment: "")
        }
        
        struct Host {
            static let title = NSLocalizedString("setting.host.title", comment: "")
            static let success = NSLocalizedString("setting.host.success", comment: "")
            static let failed = NSLocalizedString("setting.host.failed", comment: "")
        }
        
        struct Wallet {
            static let showDetail = NSLocalizedString("setting.wallet.showDetail", comment: "")
            static let hideTokens = NSLocalizedString("setting.wallet.hideTokens", comment: "")
        }
        
        struct App {
            static let version = NSLocalizedString("setting.app.version", comment: "")
            static let license = NSLocalizedString("setting.app.license", comment: "")
            static let term = NSLocalizedString("setting.app.term", comment: "")
            static let telegram = NSLocalizedString("setting.app.telegram", comment: "")
        }
        
    }
    
    struct Create {
        struct New {
            static let title = NSLocalizedString("create.new.title", comment: "")
            static let text = NSLocalizedString("create.new.text", comment: "")
            static let action = NSLocalizedString("create.new.action", comment: "")
        }
        
        struct Import {
            static let title = NSLocalizedString("create.import.title", comment: "")
            static let text = NSLocalizedString("create.import.text", comment: "")
            static let action = NSLocalizedString("create.import.action", comment: "")
            static let warningTitle = NSLocalizedString("create.import.warningTitle", comment: "")
            static let warning = NSLocalizedString("create.import.warning", comment: "")
            static let keychain = NSLocalizedString("create.import.iCloudKeychain", comment: "")
        }
        
        struct Interest {
            static let title = NSLocalizedString("create.interest.title", comment: "")
            static let text = NSLocalizedString("create.interest.text", comment: "")
            static let action = NSLocalizedString("create.interest.action", comment: "")
        }
        
        struct Account {
            static let title = NSLocalizedString("create.account.title", comment: "")
            static let name = NSLocalizedString("create.account.name", comment: "")
            static let enter = NSLocalizedString("create.account.enter", comment: "")
            static let rules = NSLocalizedString("create.account.rules", comment: "")
            static let check = NSLocalizedString("create.account.check", comment: "")
            static let checked = NSLocalizedString("create.account.checked", comment: "")
            static let keys = NSLocalizedString("create.account.keys", comment: "")
            static let genTitle = NSLocalizedString("create.account.generate.title", comment: "")
            static let genText = NSLocalizedString("create.account.generate.text", comment: "")
            static let seTitle = NSLocalizedString("create.account.se.title", comment: "")
            static let seText = NSLocalizedString("create.account.se.text", comment: "")
            static let seDetail = NSLocalizedString("create.account.se.detail", comment: "")
            static let insertTitle = NSLocalizedString("create.account.insert.title", comment: "")
            static let insertText = NSLocalizedString("create.account.insert.text", comment: "")
            static let next = NSLocalizedString("create.account.next", comment: "")
        }
        
        struct Check {
            static let title = NSLocalizedString("create.check.title", comment: "")
            static let name = NSLocalizedString("create.check.name", comment: "")
            static let text = NSLocalizedString("cretae.check.text", comment: "")
            static let keys = NSLocalizedString("create.check.keys", comment: "")
            static let failed = NSLocalizedString("create.account.check.failed", comment: "")
            static let success = NSLocalizedString("create.account.check.success", comment: "")
        }
        
        struct Invoice {
            static let title = NSLocalizedString("create.invoice.title", comment: "")
            static let textDeposit = NSLocalizedString("create.invoice.textDeposit", comment: "")
            static let timelimit = NSLocalizedString("create.invoice.timelimit", comment: "")
            static let textTimelimit = NSLocalizedString("create.invoice.textTimelimit", comment: "")
            static let memo = NSLocalizedString("create.invoice.memo", comment: "")
            static let account = NSLocalizedString("create.invoice.account", comment: "")
            static let textConfirm = NSLocalizedString("create.invoice.textConfirm", comment: "")
            static let confirm = NSLocalizedString("create.invoice.Confirm", comment: "")
            static let refreshWarning = NSLocalizedString("create.invoice.refreshWarning", comment: "")
        }
        
        
    }
    
    struct Wallet {
        static let send = NSLocalizedString("wallet.send", comment: "")
        static let receive = NSLocalizedString("wallet.receive", comment: "")
        static let available = NSLocalizedString("wallet.available", comment: "")
        static let staked = NSLocalizedString("wallet.staked", comment: "")
        static let refunding = NSLocalizedString("wallet.refunding", comment: "")
        
        static let priKey = NSLocalizedString("wallet.priKey", comment: "")
        static let pubKey = NSLocalizedString("wallet.pubKey", comment: "")
        
        static let resources = NSLocalizedString("wallet.resources", comment: "")
        static let details = NSLocalizedString("wallet.viewDetails", comment: "")
        static let notice = NSLocalizedString("wallet.notice", comment: "")
        
        struct Import {
            static let title = NSLocalizedString("wallet.import.title", comment: "")
            static let account = NSLocalizedString("wallet.import.account", comment: "")
            static let store = NSLocalizedString("wallet.import.store", comment: "")
            static let findAccount = NSLocalizedString("wallet.import.findAccount", comment: "")
            static let clickHere = NSLocalizedString("wallet.import.clickHere", comment: "")
        }
        
        struct Find {
            static let title = NSLocalizedString("wallet.find.title", comment: "")
            static let search = NSLocalizedString("wallet.find.search", comment: "")
            
        }
  
        struct Interest {
            static let title = NSLocalizedString("wallet.interest.title", comment: "")
            static let account = NSLocalizedString("wallet.interest.account", comment: "")
            static let add = NSLocalizedString("wallet.interest.store", comment: "")
        }
        
        struct First {
            static let greeting = NSLocalizedString("wallet.first.greeting", comment: "")
            static let guide = NSLocalizedString("wallet.first.guide", comment: "")
        }

        struct Transfer {
            static let available = NSLocalizedString("wallet.transfer.available", comment: "")
            static let sendTo = NSLocalizedString("wallet.transfer.sendTo", comment: "")
            static let accountPlaceholder = NSLocalizedString("wallet.transfer.accountPlaceholder", comment: "")
            static let memo = NSLocalizedString("wallet.transfer.memo", comment: "")
            static let memoDesc = NSLocalizedString("wallet.transfer.memoDesc", comment: "")
            static let quantity = NSLocalizedString("wallet.transfer.quantity", comment: "")
            static let transfer = NSLocalizedString("wallet.transfer.transfer", comment: "")
            static let history = NSLocalizedString("wallet.transfer.history", comment: "")
            static let account = NSLocalizedString("wallet.transfer.account", comment: "")
            static let popupTitle = NSLocalizedString("wallet.transfer.popupTitle", comment: "")
        }
  
        struct Delegate {
            static let stakedEOS = NSLocalizedString("wallet.delegate.stakedEOS", comment: "")
            static let delegate = NSLocalizedString("wallet.delegate.delegate", comment: "")
            static let undelegate = NSLocalizedString("wallet.delegate.undelegate", comment: "")
            static let history = NSLocalizedString("wallet.delegate.history", comment: "")
            static let delegateTitle = NSLocalizedString("wallet.delegate.delegateTitle", comment: "")
        }
        
        struct Ram {
            static let buyram = NSLocalizedString("wallet.ram.buyram", comment: "")
            static let sellram = NSLocalizedString("wallet.ram.sellram", comment: "")
            static let buy = NSLocalizedString("wallet.ram.buy", comment: "")
            static let sell = NSLocalizedString("wallet.ram.sell", comment: "")
            static let history = NSLocalizedString("wallet.ram.history", comment: "")
            static let used = NSLocalizedString("wallet.ram.used", comment: "")
            static let warning = NSLocalizedString("wallet.ram.warning", comment: "")
        }
        
        struct Option {
            static let addToken = NSLocalizedString("wallet.option.addToken", comment: "")
            static let delete = NSLocalizedString("wallet.option.delete", comment: "")
            static let deleteWarning = NSLocalizedString("wallet.option.deleteWarning", comment: "")
        }
        
        struct Inactive {
            static let account = NSLocalizedString("wallet.inactive.account", comment: "")
            static let guide = NSLocalizedString("wallet.inactive.guide", comment: "")
        }
        
        
        struct Detail {
            static let title = NSLocalizedString("wallet.detail.title", comment: "")
            static let keypairs = NSLocalizedString("wallet.detail.keypairs", comment: "")
        }
    }
    
    struct Token {
        
        /* 토큰 */
        static let add = NSLocalizedString("token.add", comment: "")
        static let added = NSLocalizedString("token.added", comment: "")
        static let howToAdd = NSLocalizedString("token.howToAdd", comment: "")
        
        struct Add {
            static let title = NSLocalizedString("token.add.title", comment: "")
            static let contract = NSLocalizedString("token.add.contract", comment: "")
            static let contractEx = NSLocalizedString("token.add.contractEx", comment: "")
            static let symbol = NSLocalizedString("token.add.symbol", comment: "")
            static let symbolEx = NSLocalizedString("token.add.symbolEx", comment: "")
            static let add = NSLocalizedString("token.add.add", comment: "")
            
            static let success = NSLocalizedString("token.add.success", comment: "")
            static let failed = NSLocalizedString("token.add.failed", comment: "")
        }
       
        
    }
    
    struct Vote {
        static let title = NSLocalizedString("vote.title", comment: "")
        static let staked = NSLocalizedString("vote.stakedEOS", comment: "")
        static let changeStake = NSLocalizedString("vote.changeStake", comment: "")
        static let changeAccount = NSLocalizedString("vote.selectAccountTitle", comment: "")
        static let selectAccount = NSLocalizedString("vote.selectAccount", comment: "")
    }
    
    struct Secure {
        struct Pin {
            static let create = NSLocalizedString("secure.pin.create", comment: "")
            static let confirm = NSLocalizedString("secure.pin.confirm", comment: "")
            static let validation = NSLocalizedString("secure.pin.validation", comment: "")
            static let change = NSLocalizedString("secure.pin.change", comment: "")
            static let useFaceId = NSLocalizedString("secure.pin.useFaceID", comment: "")
            static let useTouchId = NSLocalizedString("secure.pin.useTouchID", comment: "")
        }
        
        struct Bio {
            static let reason = NSLocalizedString("secure.bio.reason", comment: "")
            static let faceID = NSLocalizedString("secure.bio.faceId", comment: "")
            static let touchID = NSLocalizedString("secure.bio.touchId", comment: "")
        }
    }

    struct Tx {
        static let title = NSLocalizedString("tx.title", comment: "")
        static let sended = NSLocalizedString("tx.sended", comment: "")
        static let received = NSLocalizedString("tx.received", comment: "")
        static let id = NSLocalizedString("tx.id", comment: "")
        static let state = NSLocalizedString("tx.state", comment: "")
        static let complete = NSLocalizedString("tx.complete", comment: "")
        static let failed = NSLocalizedString("tx.failed", comment: "")
        static let transfer = NSLocalizedString("tx.transfer", comment: "")
        static let success = NSLocalizedString("tx.success", comment: "")
        
    }
    
    
    struct Common {
        static let paste = NSLocalizedString("common.paste", comment: "")
        static let copy = NSLocalizedString("common.copy", comment: "")
        static let apply = NSLocalizedString("common.apply", comment: "")
        static let cancel = NSLocalizedString("common.cancel", comment: "")
        static let share = NSLocalizedString("common.share", comment: "")
        static let done = NSLocalizedString("common.done", comment: "")
        static let edit = NSLocalizedString("common.edit", comment: "")
        static let cancelShort = NSLocalizedString("common.cancelShort", comment: "")
        static let confirmShort = NSLocalizedString("common.confirmShort", comment: "")
        static let caution = NSLocalizedString("common.caution", comment: "")
    }
    
    
}
