//
//  PageRouter.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/7/16.
//  Copyright © 2016 Kidney. All rights reserved.
//


import UIKit
import MSDynamicsDrawerViewController

class PageRouter: NSObject {
    
    static let dynamicVC = MSDynamicsDrawerViewController()
    
    static func showSignInPage() {
        let story = UIStoryboard(name: "Entry", bundle: nil)
        let loginvc = story.instantiateViewControllerWithIdentifier("LoginViewController")
        SharedAppDelegate().window?.rootViewController = UINavigationController(rootViewController: loginvc)
    }
    
    static func showMainInterface() -> Void {
        
        let story = UIStoryboard(name: "Main", bundle: nil)
        let drawer = story.instantiateViewControllerWithIdentifier("SideBar")
        
        if dynamicVC.drawerViewControllerForDirection(.Left) == nil {
            dynamicVC.setDrawerViewController(drawer, forDirection: .Left)
            
            let shadow = MSDynamicsDrawerShadowStyler.styler()
            shadow.shadowRadius = 4
            dynamicVC.addStylersFromArray([MSDynamicsDrawerParallaxStyler.styler(), MSDynamicsDrawerResizeStyler.styler(), shadow], forDirection: .Left)
            
            let nav = UINavigationController()
            dynamicVC.setPaneViewController(nav, animated: false, completion: nil)
            
            let pane = story.instantiateViewControllerWithIdentifier("CustomTabPageViewController")
            nav.pushViewController(pane, animated: false)
            
            dynamicVC.setPaneState(.Closed, animated: false, allowUserInterruption: true, completion: nil)
        }
        
        if !(SharedAppDelegate().window?.rootViewController is MSDynamicsDrawerViewController) {
            print("\(SharedAppDelegate().window?.rootViewController)")
            SharedAppDelegate().window?.rootViewController = dynamicVC
        }
    }
    
    static func showHomePage() {
        if let nav = (dynamicVC.paneViewController as? UINavigationController) {
            dynamicVC.setPaneState(.Closed, animated: true, allowUserInterruption: false, completion: nil)
            nav.popToRootViewControllerAnimated(true)
        } else {
            showMainInterface()
        }
    }
    
    static func showSideBar() {
        dynamicVC.setPaneState(.Open, inDirection: .Left, animated: true, allowUserInterruption: false, completion: nil)
    }
    
    static func showViewController(vc: UIViewController?) {
        
        if vc == nil {
            assertionFailure("UIViewController instance is expected, but nil is found")
        }
        
        var nav: UINavigationController! = dynamicVC.paneViewController as? UINavigationController
        if nav == nil {
            showMainInterface()
            nav = (dynamicVC.paneViewController as! UINavigationController)
        }
        
        if dynamicVC.paneState != .Closed {
            dynamicVC.setPaneState(.Closed, animated: true, allowUserInterruption: false, completion: nil)
        }
        var found = false
        
        let newVCs = nav.viewControllers.map({ (value) -> UIViewController in
            if value.isKindOfClass(vc!.classForCoder) {
                found = true
                return vc!
            } else {
                return value
            }
        })
        
        if found {
            nav.viewControllers = newVCs
            nav.popToViewController(vc!, animated: true)
        } else {
            nav.pushViewController(vc!, animated: true)
        }
    }
    
    
    static func showProfileFor(user: User_Bmob?, fromVC: UIViewController) {
        
        let identifier = user == nil ? "SelfProfileViewController" : "OtherProfileViewController"
        guard let vc = fromVC.storyboard?.instantiateViewControllerWithIdentifier(identifier) else {
            print("cannot find viewcontroller with identifier: \(identifier)")
            return
        }
        
        vc.setValue(ProfileViewModel(user: user), forKey: "viewModel")
        showViewController(vc)
    }
    
    static func logout() {
        User_Bmob.logout()
        if dynamicVC.paneState != .Closed {
            dynamicVC.setPaneState(.Closed, animated: false, allowUserInterruption: false, completion: {
                showSignInPage()
            })
        }
    }
    
    static func getRootNavigationController() -> UINavigationController? {
        return UIApplication.sharedApplication().delegate?.window!!.rootViewController as? UINavigationController
    }
    
    static func showCommentPage(forNews newsId: String, authorId: String) {
        let story = UIStoryboard(name: "Main", bundle: nil)
        let vc = story.instantiateViewControllerWithIdentifier("CommentViewController")
        vc.setValue(CommentViewModel(withNews: newsId, authorId: authorId), forKey: "viewModel")
        (dynamicVC.paneViewController as! UINavigationController).pushViewController(vc, animated: true)
    }
    
    static func showNewsDetail(forNews newsId: String) {
        let newsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("NewsDetailViewController") as! NewsDetailViewController
        
        newsVC.viewModel = NewsDetailViewModel(withNews: newsId)
        PageRouter.showViewController(newsVC)
    }
    
    static func showChatRoom(forUser userId: String, nickname: String, avatarURL: NSURL?) {
        let story = UIStoryboard(name: "Main", bundle: nil)
        let vc = story.instantiateViewControllerWithIdentifier("SingleChatRoomViewController")
        let viewModel = ChatViewModel(user: userId, nickname: nickname, avatarURL: avatarURL)
        vc.setValue(viewModel, forKey: "viewModel")
        
        showViewController(vc)
    }
    
    static func showPublishPage() {
        showPage("PublishNewsViewController")
    }
    
    static func showNotifications() {
        showPage("NotificationsViewController")
    }
    
    static func showSettings() {
        showPage("SettingsViewController")
    }
    
    static func showPage(identifier: String) {
        let story = UIStoryboard(name: "Main", bundle: nil)
        let vc = story.instantiateViewControllerWithIdentifier(identifier)
        
        showViewController(vc)
    }
}
