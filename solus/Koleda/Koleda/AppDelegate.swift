//
//  AppDelegate.swift
//  Koleda
//
//  Created by Oanh tran on 5/23/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
import GoogleSignIn
import FBSDKCoreKit
import CopilotAPIAccess
import Firebase
import FirebaseCore
import FirebaseAnalytics

var log: Logger = CocoalumberjackLogger()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let launcher = Launcher()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let window = UIWindow()
        GIDSignIn.sharedInstance().clientID = "341520222314-4159a7cq3nfkfancrk0d2r8m1ieh9h26.apps.googleusercontent.com"
        
        
        launcher.displayScreenBaseOnUserStatus(on: window)
        window.makeKeyAndVisible()
        self.window = window
//        ManagerWebsocket.shared.connect()
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions:
            launchOptions
        )
        FirebaseApp.configure()
        Analytics.setAnalyticsCollectionEnabled(true)
        Copilot.setup(analyticsProviders: [FirebaseAnalyticsEventLogProvider()])
        return true
    }
    
//    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//        return GIDSignIn.sharedInstance().handle(url)
//    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return ApplicationDelegate.shared.application(
            app,
            open: url,
            options: options
        )
        
//        if let fbSDKAppId = FBSDKSettings.appID(), url.scheme!.hasPrefix("fb\(fbSDKAppId)"), url.host == "authorize" {
//            let shouldOpen: Bool = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
//            return shouldOpen
//        }
//
//        // After it, handle any other response (e.g. deep links)
//        handlerOtherUrls(url: url)
//        return true
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
        NotificationCenter.default.post(name: .KLDDidChangeWifi, object: nil)
        guard let wifiInfo = WifiInfo.getWifiInfo() else {
            return
        }
        UserDataManager.shared.wifiInfo = wifiInfo
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

