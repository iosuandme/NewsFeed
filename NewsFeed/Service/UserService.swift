//
//  UserService.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/18/16.
//  Copyright © 2016 Kidney. All rights reserved.
//
import CocoaSecurity

class UserService: NSObject {
    
    // MARK: Account related
    
    static func getLastLoginedUser() -> User_Bmob? {
        return User_Bmob.currentUser()
    }
    
    static func loginInbackgroundWithAccount(username: String, andPassword pass: String? = nil, block: (User_Bmob!, NSError?)->Void) {
        
        var encrytedPass: String!
        if pass != nil {
            encrytedPass = CocoaSecurity.aesEncrypt(pass, hexKey: Encrypt_Key, hexIv: Encrypt_IV).base64
        } else {
            encrytedPass = NSUserDefaults.standardUserDefaults().stringForKey("password")
        }
        
        BmobUser.loginInbackgroundWithAccount(username, andPassword: encrytedPass) { (user, error) in

            block(User_Bmob.convert(user), error)
            
            if error == nil {
                NSUserDefaults.standardUserDefaults().setObject(username, forKey: "username")
                NSUserDefaults.standardUserDefaults().setObject(encrytedPass, forKey: "password")
                (UIApplication.sharedApplication().delegate as! AppDelegate).helper.registerInstallation(withDeviceToken: nil)
            }
        }
    }
    
    static func signUp(username: String, andPassword pass: String, nickname: String? = nil, profession: String? = nil, avatar: UIImage? = nil, block: BmobBooleanResultBlock) {
        let user = User_Bmob()
        
        let signUpBlock = {
            let encrytedPass = CocoaSecurity.aesEncrypt(pass, hexKey: Encrypt_Key, hexIv: Encrypt_IV).base64
            user.password = encrytedPass
            user.nickname = nickname
            user.profession = profession ?? "unknown"
            user.username = username
            user.signUpInBackgroundWithBlock({ (isSucc, error) in
                block(isSucc, error ?? nil)
                NSUserDefaults.standardUserDefaults().setObject(username, forKey: "username")
                NSUserDefaults.standardUserDefaults().setObject(encrytedPass, forKey: "password")
            })
        }
        
        if avatar != nil {
            let fileDics = FileHelper.generateJPEGFilesInlcudeThumbnail(withImage: avatar!)
            
            BmobFile.filesUploadBatchWithDataArray(fileDics, progressBlock: nil, resultBlock: { (files, success, error) in
                if error != nil {
                    block(false, error)
                } else {
                    user.thumbnail = files[0] as? BmobFile
                    user.image = files[1] as? BmobFile
                    signUpBlock()
                }
            })
        } else {
            signUpBlock()
        }
        
        
    }
    
    // MARK: User related
    
    static func getInfo(ofUser userId: String?, userInfoId: String?, block: (User_Bmob!, NSError?)->Void) {
        let userInfoToGet = userInfoId ?? User_Bmob.currentUser()!.info.objectId
        let userToGet = userId ?? User_Bmob.currentUser()!.objectId
        
        let query = BmobQuery(className: "UserAdditionalInfo")
        query.whereKey("objectId", equalTo: userInfoToGet)
        
        let inQuery = BmobUser.query()
        inQuery.whereKey("objectId", equalTo: User_Bmob.currentUser()?.objectId)
        inQuery.limit = 1
        
        query.whereKey("followers", matchesQuery: inQuery)
        
        query.countObjectsInBackgroundWithBlock({ (count, error) in
            
            if error == nil {
                let queryDetail = BmobQuery(className: "_User")
                
                queryDetail.includeKey("info")
                queryDetail.getObjectInBackgroundWithId(userToGet, block: { (result, errorDetail) in
                    
                    
                    if errorDetail != nil {
                        block(nil, errorDetail!)
                    } else {
                        let info = User_Bmob.convert(result)
                        
                        if result.objectId == User_Bmob.currentUser()?.objectId {
                            info.info.follow = .IsMe
                        } else {
                            info.info.follow = UserAdditionalInfo.FollowState(rawValue: Int(count))!
                        }
                        block(info, nil)
                    }
                })
            }
        })
    }
    
    
    
    static func toggleFollow(toUser user: User_Bmob, block: BmobBooleanResultBlock?) {
        
        isFollowing(toUser: user) { (isFollowing, error) in
            if error != nil {
                block?(false, error!)
            } else {
                let toUser = BmobUser(outDataWithClassName: "_User", objectId: user.objectId)
                let fromUser = User_Bmob.currentUser()!
                
                let fromInfo = BmobObject(outDataWithClassName: "UserAdditionalInfo", objectId: User_Bmob.currentUser()!.info.objectId)
                let fromrelation = BmobRelation()
                if !isFollowing {
                    fromrelation.addObject(toUser)
                    fromInfo.incrementKey("followingsCount")
                } else {
                    fromrelation.removeObject(toUser)
                    fromInfo.decrementKey("followingsCount")
                }
                fromInfo.addRelation(fromrelation, forKey: "followings")
                
                fromInfo.updateInBackgroundWithResultBlock { (success, error) in
                    if error != nil {
                        block?(false, error!)
                    } else {
                        let query = BmobQuery(className: "_User")
                        query.getObjectInBackgroundWithId(user.objectId, block: { (user, error2) in
                            if error2 != nil {
                                
                            } else {
                                
                                let info = BmobObject(outDataWithClassName: "UserAdditionalInfo", objectId: User_Bmob.convert(user).info.objectId)
                                let torelation = BmobRelation()
                                if !isFollowing {
                                    torelation.addObject(fromUser)
                                    info.incrementKey("followersCount")
                                } else {
                                    torelation.removeObject(fromUser)
                                    info.decrementKey("followersCount")
                                }
                                
                                info.addRelation(torelation, forKey: "followers")

                                info.updateInBackgroundWithResultBlock({ (_, error3) in
                                    if error3 != nil {
                                        block?(false, error3)
                                    } else {
                                        block?(!isFollowing, nil)
                                    }
                                })
                                
                                if !isFollowing {
                                    MessageService.send(.Follow, toUser: user.objectId, withSendStateBlock: nil)
                                }
                            }
                        })
                        
                    }
                }
            }
        }
        
    }
    
    static func isFollowing(toUser user: User_Bmob, block: BmobBooleanResultBlock) {
        let query = BmobQuery(className: "UserAdditionalInfo")
        
        query.whereKey("objectId", equalTo: user.info.objectId)
        
        let inQuery = BmobUser.query()
        inQuery.whereKey("objectId", equalTo: User_Bmob.currentUser()?.objectId)
        inQuery.limit = 1
        
        query.whereKey("followers", matchesQuery: inQuery)
        
        query.countObjectsInBackgroundWithBlock { (count, error) in
            
            if error != nil {
                block(false, error!)
            } else {
                block(count > 0, nil)
            }
        }

    }
    
    // MARK: News related
    
    static func changeLikes(toUser userId: String, infoId: String, delta: Int = 1, block: BmobBooleanResultBlock?) {
        let info = BmobObject(outDataWithClassName: "UserAdditionalInfo", objectId: infoId)
        
        if delta == 1 {
            info.incrementKey("likesCount")
        } else {
            info.decrementKey("likesCount")
        }
        
        info.updateInBackgroundWithResultBlock(block)
    }
}
