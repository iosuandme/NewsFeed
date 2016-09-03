//
//  User+Bmob.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/16/16.
//  Copyright © 2016 Kidney. All rights reserved.
//


class UserAdditionalInfo: BmobObject {
    
    enum FollowState: Int {
        case NotFollowedByMe = 0, FollowedByMe, IsMe
    }
    
    var postsCount: UInt! = 0
    var followersCount: UInt! = 0
    var followingsCount: UInt! = 0
    var likesCount: UInt! = 0
    var sharedCount: UInt! = 0
    
    var follow: FollowState = .NotFollowedByMe
    
    static func convert(obj: BmobObject?) -> UserAdditionalInfo {
        let info = UserAdditionalInfo.convertWithObject(obj)
        
        if let postsCount = obj?.objectForKey("postsCount") {
            info.postsCount = postsCount as! UInt
        }
        if let likesCount = obj?.objectForKey("likesCount") {
            info.likesCount = likesCount as! UInt
        }
        if let sharedCount = obj?.objectForKey("sharedCount") {
            info.sharedCount = sharedCount as! UInt
        }
        if let followersCount = obj?.objectForKey("followersCount") {
            info.followersCount = followersCount as! UInt
        }
        if let followingsCount = obj?.objectForKey("followingsCount") {
            info.followingsCount = followingsCount as! UInt
        }
        
        return info
    }
    
    override func sub_saveInBackgroundWithResultBlock(block: BmobBooleanResultBlock!) {
        self.className = "UserAdditionalInfo"

        self.setObject(self.postsCount, forKey: "postsCount")
        self.setObject(self.followersCount, forKey: "followersCount")
        self.setObject(self.followingsCount, forKey: "followingsCount")
        self.setObject(self.likesCount, forKey: "likesCount")
        self.setObject(self.sharedCount, forKey: "sharedCount")
        
        
        super.sub_saveInBackgroundWithResultBlock(block)
    }
}

class User_Bmob: BmobUser {
    
    var image: BmobFile? {
        didSet {
            if image != nil {
                imageURL = NSURL(string: image!.url)
            }
        }
    }
    
    var thumbnail: BmobFile? {
        didSet {
            if thumbnail != nil {
                thumbURL = NSURL(string: thumbnail!.url)
            }
        }
    }
    var imageURL: NSURL?
    var thumbURL: NSURL?
    
    private var _nickname: String?
    var nickname: String! {
        get {
            return _nickname?.characters.count > 0 ? _nickname : username
        }
        set {
            _nickname = newValue
        }
    }
    var profession = " "
    var hasSelectedTopics = false
    var info: UserAdditionalInfo!
    
    static func convert(obj: BmobObject?) -> User_Bmob {
        let user = User_Bmob.convertWithObject(obj)
        

        if let info = obj?.objectForKey("info") {
            user.info = UserAdditionalInfo.convert(info as? BmobObject)
        }
        
        user.hasSelectedTopics = (obj?.objectForKey("hasSelectedTopics") as? Bool) ?? false
        
        return user
    }
    
    static override func currentUser() -> User_Bmob? {
        let user = convert(BmobUser.currentUser())
        if user.objectId != nil {
            return user
        }
        
        return nil
    }
    
    override func sub_saveInBackgroundWithResultBlock(block: BmobBooleanResultBlock!) {
        //转化后的表名有问题，需要手动设置
        self.className = "_User"
        
        self.deleteForKey("imageURL")
        self.deleteForKey("thumbURL")
        self.deleteForKey("follow")
        
        super.sub_saveInBackgroundWithResultBlock(block)
    }
    
    override func signUpInBackgroundWithBlock(block: BmobBooleanResultBlock!) {
        
        self.setObject(self.nickname, forKey: "nickname")
        self.setObject(self.profession, forKey: "profession")
        self.setObject(self.image, forKey: "image")
        self.setObject(self.thumbnail, forKey: "thumbnail")
        
        
        super.signUpInBackgroundWithBlock { [weak self] (success, error) in
            if error != nil {
                block?(false, error!)
            } else {
                if let strongSelf = self {
                    let info = UserAdditionalInfo()
                    info.sub_saveInBackgroundWithResultBlock({ [weak info] (success2, error2) in
                        if error2 != nil {
                            block?(false, error2!)
                        } else {
                            if let strongInfo = info {
                                strongSelf.info = strongInfo
                                strongSelf.setObject(strongInfo, forKey: "info")
                                strongSelf.updateInBackgroundWithResultBlock(block)
                            } else {
                                block?(false, DeallocError)
                            }
                        }
                    })
                } else {
                    block?(false, DeallocError)
                }
                
                
            }
        }
    }
}
