//
//  RegisterViewModel.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/24/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

import ReactiveCocoa
import Result

class RegisterViewModel: NSObject {
    
    var username: String?
    var password: String?
    var nickname: String?
    var profession: String?
    var avatar: UIImage?
    
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
    
    lazy var registerAction: Action<(), Bool, NSError> = {
        
        return Action(enabledIf: self.isInputValid, { () -> SignalProducer<Bool, NSError> in
            return SignalProducer({ (observer: Observer<Bool, NSError>, disposable) in
                UserService.signUp(self.username!, andPassword: self.password!, nickname: self.nickname, profession: self.profession, avatar: self.avatar, block: { (success, error) in
                    if error != nil {
                        observer.sendFailed(error)
                    } else {
                        observer.sendNext(true)
                        observer.sendCompleted()
                    }
                })
            })
        })
        
    }()
    
}
