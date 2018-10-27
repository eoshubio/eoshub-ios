//
//  AppDelegate.swift
//  eoshub
//
//  Created by kein on 2018. 7. 8..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDynamicLinks
import GoogleSignIn
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {


    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        
        _ = DB.shared
        _ = AccountManager.shared
        
        //Start Flow
        window = UIWindow(frame : UIScreen.main.bounds)
        let config = FlowConfigure(container: window!, parent: nil, flowType: .window)
        let mainFlow = MainFlowController(configure: config)
        mainFlow.start(animated: false)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        /*
         url    URL    "eoshub://tx?request_data=%7B%22code%22%3A%22eosio%22%2C%22action%22%3A%22newaccount%22%2C%22args%22%3A%7B%22creator%22%3A%22eosio%22%2C%22name%22%3A%22keinremote1%22%2C%22owner%22%3A%7B%22threshold%22%3A0%2C%22accounts%22%3A%5B%7B%22actor%22%3A%22keinremote1%22%2C%22permission%22%3A%22owner%22%2C%22weight%22%3A0%7D%5D%2C%22keys%22%3A%5B%22EOS8WtEtozjeBnxporQ1x4uvAL77D4UxRvaFVwMPFjCmnG618XF8u%22%2C%22EOS6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV%22%5D%2C%22waits%22%3A%5B0%5D%7D%2C%22active%22%3A%7B%22threshold%22%3A0%2C%22accounts%22%3A%5B%7B%22actor%22%3A%22keinremote1%22%2C%22permission%22%3A%22active%22%2C%22weight%22%3A0%7D%5D%2C%22keys%22%3A%5B%22EOS8WtEtozjeBnxporQ1x4uvAL77D4UxRvaFVwMPFjCmnG618XF8u%22%2C%22EOS6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV%22%5D%2C%22waits%22%3A%5B0%5D%7D%7D%7D"
         url    URL    "eoshub://tx?request_data=data&call_back=http://eos.win/dice/id23434"
        url.scheme  "eoshub"
        url.host    "tx"
        url.query   "request_data=data&call_back=http://eos.win/dice/id23434"
        
        */
        
        if GIDSignIn.sharedInstance().handle(url,
                                             sourceApplication:options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                             annotation: [:]) {
            return true
        } else if let sourceOption = options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: sourceOption, annotation: options[UIApplication.OpenURLOptionsKey.annotation]) {
            return true
        } else if let dLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            Log.i(dLink.description)
            return true
        } else if let eoshubScheme = Scheme(url: url) {
            /*
            let account = AccountManager.shared.ownerInfos.filter("account = 'eoshubiotest'").first!
            let contract = eoshubScheme.getAction(actor: EOSName("eoshubiotest"), authorization: Authorization(actor: account.account, permission: account.permission))!
            
            let topVC = UIApplication.topViewController()!

            let vc = UIStoryboard(name: "Wallet", bundle: nil).instantiateViewController(withIdentifier: "TxConfirmViewController") as! TxConfirmViewController
            
            vc.configure(contract: contract)
            
            topVC.navigationController?.pushViewController(vc, animated: true)
            */
            
            //Dapp
            if let dappAction = eoshubScheme.dappAction, let topVC = UIApplication.topViewController() {
                let config = FlowConfigure(container: topVC, parent: nil, flowType: .modal)
                let dappFc = DappWebFlowController(configure: config)
                dappFc.configure(dappAction: dappAction)
                dappFc.start(animated: false)
            }
        }
        
        return false
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        let handled = DynamicLinks.dynamicLinks().handleUniversalLink(userActivity.webpageURL!) { (dynamiclink, error) in
            // ...
            if let error = error {
                Log.e(error)
            } else {
                Log.i(dynamiclink.debugDescription)
            }
        }
        return handled
    }

}

