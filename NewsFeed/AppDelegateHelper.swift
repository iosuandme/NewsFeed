//
//  AppDelegateHelper.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/26/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

import RealReachability
import ReactiveCocoa

class AppDelegateHelper: NSObject {
    
    private var deviceToken: NSData?
    
    func registerInstallation(withDeviceToken deviceToken: NSData?) {
        if deviceToken?.length > 0 {
            self.deviceToken = deviceToken
        }
        guard self.deviceToken?.length > 0 else { return }
        
        if let user = User_Bmob.currentUser() {
            let installation = BmobInstallation.init()
            installation.setDeviceTokenFromData(self.deviceToken)
            installation.setObject(true, forKey: "isDeveloper")
            installation.setObject(user.objectId, forKey: "userId")
            installation.saveInBackgroundWithResultBlock({ (success, error) in
                if error != nil {
                    print(error!.localizedDescription)
                }
            })
        }
    }
    
    // MARK: UI related
    
    func showMainInterfaceAtLaunch() {
        
        let vc = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        SharedAppDelegate().window = UIWindow(frame: UIScreen.mainScreen().bounds)
        SharedAppDelegate().window?.rootViewController = vc
        SharedAppDelegate().window?.makeKeyAndVisible()
        
        if let user = UserService.getLastLoginedUser() {

            RealReachability.sharedInstance().reachabilityWithBlock({ (status) in
                switch status {
                case .RealStatusViaWiFi: fallthrough
                case .RealStatusViaWWAN:

                    UserService.loginInbackgroundWithAccount(user.username, andPassword: nil, block: { (_, error) in
                        if error != nil {
                            PageRouter.showSignInPage()
                            Toast.showError("auto login failed:\(error!.localizedDescription)")
                        } else {
                            PageRouter.showMainInterface()
                        }
                    })
                default:
                    PageRouter.showMainInterface()
                }
            })
        } else {
            PageRouter.showSignInPage()
        }
    }
    
    lazy var jumpPageAction : Action<[String : AnyObject]?, (), NSError> = {
        return Action( { (info: [String : AnyObject]?) -> SignalProducer<(), NSError> in
            
            return SignalProducer({ (observer: Observer<(), NSError>, disposable: Disposable?) in
                guard let vcname = (info?["UIViewController"] as? String) else {
                    print("notification info lose the UIViewController name")
                    return
                }
                
                let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(vcname)
                switch vcname {
                case "SingleChatRoomViewController":
                    let (userId, name, avatar)  = (info?["id"] as? String, info?["name"] as? String, info?["avatar"] as? String)
                    if userId != nil && name != nil {
                        PageRouter.showChatRoom(forUser: userId!, nickname: name!, avatarURL: avatar == nil ? nil : NSURL(string: avatar!))
                    } else {
                        print("SingleChatRoomViewController message format invalid")
                    }
                case "NewsDetailViewController":
                    if let newsId = (info?["id"] as? String) {
                        PageRouter.showNewsDetail(forNews: newsId)
                    }
                default:
                    print("UIViewController param is invalid")
                }
            })
        })
    }()
}
