//
//  AppDelegate.swift
//  ZertuNew
//
//  Created by Shalini Sharma on 18/11/19.
//  Copyright © 2019 Shalini Sharma. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import UserNotifications
import FBSDKCoreKit
import Braintree
import Firebase

var isUserTappedSkipButton = false
var isUserRestoredAllPurchases = true  // changed to True on 10/Oct20, as for paid course we don't want to sho Restore screen for 1 time

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false

        registerForPushNotificationSettings()
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions) //for Facebook
        BTAppSwitch.setReturnURLScheme("com.medialima.appzertu.payments")

        FirebaseApp.configure()
        
        loadVC()
        return true
    }

    func loadVC()
    {
        if let isRestored:Bool = k_userDef.value(forKey: userDefaultKeys.userRestoredAllPurchases.rawValue) as? Bool
        {
            if isRestored == true
            {
                isUserRestoredAllPurchases = true
            }
        }
        
        if let isOnBoardingShown:String = k_userDef.value(forKey: userDefaultKeys.onBoardingShown.rawValue) as? String
        {
            if isOnBoardingShown != ""
            {
                // OnBoarding Once Done and Accepted by user
                let vc: LoginVC = AppStoryboards.Login.instance.instantiateViewController(withIdentifier: "LoginVC_ID") as! LoginVC
                k_window.rootViewController = vc
            }
            else
            {
                // let the Onboarding be Loaded
            }
        }
        else
        {
            // let the Onboarding be Loaded
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool
    {
        if url.scheme?.localizedCaseInsensitiveCompare("com.medialima.appzertu.payments") == .orderedSame
        {
            return BTAppSwitch.handleOpen(url, options: options)
        }
        return ApplicationDelegate.shared.application(app, open: url, options: options) //for Facebook
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
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

extension AppDelegate : UNUserNotificationCenterDelegate
{
    func registerForPushNotificationSettings()
    {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
            // Enable or disable features based on authorization.
        }
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    // Called when Device Token is received
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let token = self.getStringFrom(token: deviceToken as NSData)
        print("Device Token: \(token)")
        //send this device token to server
        devicePushToken = token
    }
    
    func getStringFrom(token:NSData) -> String {
        return token.reduce("") { $0 + String(format: "%02.2hhx", $1) }
    }
    
    // Called if unable to register for APNS.
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register Push : \(error)")
    }
    
    // On Receiving notification following delegate will call
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    {
        guard let aps = userInfo["aps"] as? [String: AnyObject] else {
            completionHandler(.failed)
            return
        }
        print("Notification Payload Received -> ",aps)
        
        if let dictAlert:[String:Any] = aps["alert"] as? [String:Any]
        {
            if let str:String = dictAlert["body"] as? String
            {
                if str == "First Notification1"
                {
                    // Take to some VC
                    print("> > Take to some VC from Push - -")
                }
            }
        }
        
    }
    
}
