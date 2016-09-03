//
//  AppDelegate.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/15/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import FCFileManager
import RealReachability

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var deviceToken: NSData?
    var helper = AppDelegateHelper()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        print(FCFileManager.pathForTemporaryDirectory())
        
        RealReachability.sharedInstance().startNotifier()
        
        Bmob.registerWithAppKey(Bmob_App_Key)
        
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
        
        registerRemoteNotifications()
        print("launch notifications: \(launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey])")
        
        helper.showMainInterfaceAtLaunch()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        
    }

    func applicationDidEnterBackground(application: UIApplication) {
        
    }

    func applicationWillEnterForeground(application: UIApplication) {
        
        Bmob.activateSDK()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        
    }

    func applicationWillTerminate(application: UIApplication) {
        
    }

    // MARK: Remote Notification
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {

        print("didRegisterForRemoteNotificationsWithDeviceToken!!!")
        helper.registerInstallation(withDeviceToken: deviceToken)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {

        print("didFailToRegisterForRemoteNotificationsWithError: \(error)")
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {

        print("receive remote notification: \(userInfo)")
        var state: String
        switch application.applicationState {
        case .Active:
            state = "Active"
            guard let id = (userInfo["messageId"] as? String) else {
                assertionFailure("messageId is lost")
                return
            }
            MessageSearcher.getMessage(byId: id, block: { (message, error) in
                if error == nil {
                    NSNotificationCenter.defaultCenter().postNotificationName(ReceiveMessageNotification, object: message, userInfo: nil)
                    completionHandler(.NewData)
                } else {
                    completionHandler(.Failed)
                }
            })
            
        case .Inactive:
            state = "Inactive"
            helper.jumpPageAction.apply(userInfo["jump"] as? [String:AnyObject]).start { (event) in
                switch event {
                case .Completed:
                    completionHandler(.NewData)
                case .Failed(.ProducerError(_)):
                    completionHandler(.Failed)
                default:
                    completionHandler(.NoData)
                }
            }
        case .Background:
            state = "Background"
        }
        print("receive remote notification, state => \(state)")
    }
    
    // MARK: Helper Methods
    
    func registerRemoteNotifications() {
        let categorys = UIMutableUserNotificationCategory()
        categorys.identifier = AppIdentifier
        
        var set = Set<UIUserNotificationCategory>()
        set.insert(categorys)
        
        let types = UIUserNotificationType(rawValue: UIUserNotificationType.Badge.rawValue | UIUserNotificationType.Sound.rawValue | UIUserNotificationType.Alert.rawValue)
        
        let userNotifiSetting = UIUserNotificationSettings(forTypes: types, categories: set)
        
        UIApplication.sharedApplication().registerUserNotificationSettings(userNotifiSetting)
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
}

