//
//  LoginViewModel.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/7/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

import ReactiveCocoa
import Result

class LoginViewModel: NSObject {

    internal private(set) var username: String?
    internal private(set) var password: String?
    
    func getLastLoginInfo() {
        setValue(NSUserDefaults.standardUserDefaults().objectForKey("username") as? String, forKey: "username")
    }
    
    let nameInvalidHint = "username is blank"
    lazy var isNameValid: AnyProperty<Bool> = {
        return DynamicProperty(object: self, keyPath: "username").map{ ($0 as? String)?.characters.count > 0 }
    }()

    let passInvalidHint = "password is blank"
    lazy var isPassValid: AnyProperty<Bool> = {
        return DynamicProperty(object: self, keyPath: "password").map{ ($0 as? String)?.characters.count > 0 }
    }()
    
    lazy var isInputValid: AnyProperty<Bool> = { (_) -> AnyProperty<Bool> in
        return self.isNameValid.and(self.isPassValid).map{ $0 }
    }()
  
    lazy var loginAction: Action<(), User_Bmob, NSError> = {

        let ac = Action(enabledIf: self.isInputValid, { () -> SignalProducer<User_Bmob, NSError> in
            
            return SignalProducer({ (observer: Observer<User_Bmob, NSError>, disposable) in
                
                UserService.loginInbackgroundWithAccount(self.username!, andPassword: self.password!) { (user, error) in
                    if error != nil {
                        observer.sendFailed(error!)
                    } else {
                        observer.sendNext(user)
                        observer.sendCompleted()
                    }
                }
            })
        })
        
        return ac;

    }()
    
}
