//
//  ChatData.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/6/16.
//  Copyright © 2016 Kidney. All rights reserved.
//
import JSQMessagesViewController
import ReactiveCocoa
import SDWebImage
import DateTools

class ChatViewModel: NSObject {
    
    enum MessageType: Int {
        case History = 0, New
    }
    
    var messages: [JSQMessage] = []
    private(set) var users: [ String : User_Bmob ] = [:]
    private(set) var heads: [ String : AnyObject? ] = [:]
    private(set) var theOtherSideUserId: String!
    let holder = JSQMessagesAvatarImageFactory.avatarImageWithImage(AvatarPlaceHolder, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
    
    private(set) var hasMoreHistory = true
    var newMessagesCount: Int = 0
    private(set) lazy var newMessages: AnyProperty<(MessageType, String)> = {
        return DynamicProperty(object: self, keyPath: "newMessagesCount").map { (MessageType(rawValue: ($0 as! Int) > 0 ? 1 : 0)!, String($0 as! Int) + " new") }
    }()
    
    lazy var chatRoomTitle: AnyProperty<String> = {
        return DynamicProperty(object: self, keyPath: "theOtherSideUserId").map { _ in (self.users[self.theOtherSideUserId]?.nickname) ?? "Loading..." }
    }()
    
    init(user userId:String, nickname: String, avatarURL: NSURL?) {
        super.init()
        
        let userinfo = User_Bmob()
        userinfo.objectId = userId
        userinfo.nickname = nickname
        userinfo.thumbURL = avatarURL
        
        refreshUserInfo(userinfo)
        users.updateValue(User_Bmob.currentUser()!, forKey: (User_Bmob.currentUser()?.objectId)!)
        
        NSNotificationCenter.defaultCenter().rac_addObserverForName(ReceiveMessageNotification, object: nil).subscribeNext { (value) in
            if let notification = value as? NSNotification {
                print("receive message：\(notification)")
                self.messages.append(self.translate(notification.object as! Message_Bmob))
                self.setValue(self.newMessagesCount + 1, forKey: "newMessagesCount")
            }
        }
    }
    
    func clearNewMessages() {
        self.newMessagesCount = 0
    }
    
    private func refreshUserInfo(userinfo: User_Bmob) {
        setValue(userinfo.objectId, forKey: "theOtherSideUserId")
        users.updateValue(userinfo, forKey: userinfo.objectId)
        
    }
    
    // MARK: action - RAC
    
    lazy var refreshModel : Action<(), (), NSError> = {
        return Action( { (_) -> SignalProducer<(), NSError> in
            return SignalProducer({ (observer, disposable) in
                UserService.getInfo(ofUser: self.theOtherSideUserId, userInfoId: nil) { (result, error) in
                    if error != nil {
                        observer.sendFailed(error!)
                    } else {
                        self.heads.removeValueForKey(self.theOtherSideUserId)
                        observer.sendCompleted()
                    }
                }
            })
        })
    }()
    
    func loadAvatar(user: User_Bmob) -> Action<(), UIImage?, NSError> {

        if heads[user.objectId] == nil {
            heads[user.objectId] = "ing"
        }
        
        return Action( { () -> SignalProducer<UIImage?, NSError> in
            SignalProducer { [unowned self] (observer: Observer<UIImage?, NSError>, disposable: Disposable?) in
                
                if user.thumbURL == nil {
                    self.heads[user.objectId] = JSQMessagesAvatarImageFactory.avatarImageWithImage(AvatarPlaceHolder, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
                    observer.sendCompleted()
                } else {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                        SDWebImageManager.sharedManager().downloadImageWithURL(user.thumbURL, options: .RetryFailed, progress: nil, completed: { (head, error, type, finished, url) in
                            if user.thumbURL == url && head != nil {
                                self.heads[user.objectId] = JSQMessagesAvatarImageFactory.avatarImageWithImage(head!, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
                                observer.sendCompleted()
                            }
                        })
                    })
                }
            }
        })
    }
    
    lazy var loadNextPageAction : Action<UInt?, Int, NSError> = {
        let pageSize = 10
        return Action( { (lastId: UInt?) -> SignalProducer<Int, NSError> in
            SignalProducer { [unowned self] (observer: Observer<Int, NSError>, disposable: Disposable?) in
                MessageSearcher.getMessages(.Message, earlierThanLastMessageId: self.messages.first?.messageId, withUser: self.theOtherSideUserId, pageSize: pageSize, block: { (result, error) in
                    if error != nil {
                        observer.sendFailed(error!)
                    } else {
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                            // time desc => time asc and transform type
                            let newMsgs = result.map{ msg in self.translate(msg) }.reverse()
                            if newMsgs.count != 0 {
                                
                                self.messages.insertContentsOf(newMsgs, at: 0)
                                self.setValue(MessageType.History.rawValue, forKey: "newMessagesCount")
                                
                                observer.sendNext(newMsgs.count)
                               
                            }
                            if (pageSize != newMsgs.count){
                                self.hasMoreHistory = false
                            }
                            observer.sendCompleted()
                        })
                    }
                })
            }
        })
    }()
    
    func translate(message: Message_Bmob) -> JSQMessage {
        
        var item: JSQMediaItem!
        let (userId, userName) = (message.sender.objectId, message.sender.nickname)
        switch message.content!.content_type {
        case .Text:
            item = JSQTextMediaItem(withData: ["text":message.content?.text, "date":message.createdAt,])
        default:
            item = JSQPhotoMediaItemCustom(withData: ["imageURL":message.content?.imageURL, "text":message.content?.text, "date":message.createdAt,])
            
        }
        item.appliesMediaViewMaskAsOutgoing = (userId == User_Bmob.currentUser()?.objectId)
        
        let jsqMessage = JSQMessage(senderId: userId, senderDisplayName: userName, date: message.createdAt, media: item)
        jsqMessage.messageId = message.messageId
        jsqMessage.messageState = message.state.getValue().0
        
        return jsqMessage
    }
    
    // MARK: action - function
    
    func sendText(text: String, stateBlock: ((NSIndexPath?, Message_Bmob.MessageState) -> Void)) -> Void {
        var jsqMessage: JSQMessage!
        MessageService.send(text: text, toUser: theOtherSideUserId) { [weak self] (state, message, error) in
            var index = -1
            
            if jsqMessage == nil && message != nil {
                jsqMessage = self?.translate(message!)
                self?.messages.append(jsqMessage)
            } else {
                index = self?.messages.indexOf(jsqMessage) ?? -1
            }
            
            jsqMessage.messageState = state.getValue().0
            
            stateBlock( index >= 0 ? NSIndexPath(forItem: index, inSection: 0) : nil , state)
        }
        
    }
    
    func sendImage(image: UIImage, stateBlock: ((NSIndexPath?, Message_Bmob.MessageState) -> Void)) -> Void {
        var jsqMessage: JSQMessage!
        MessageService.send(image: image, toUser: theOtherSideUserId) { [weak self] (state, message, error) in
            var index = -1
            
            if jsqMessage == nil && message != nil {
                jsqMessage = self?.translate(message!)
                self?.messages.append(jsqMessage)
            } else {
                index = self?.messages.indexOf(jsqMessage) ?? -1
            }
            
            jsqMessage.messageState = state.getValue().0
            
            stateBlock( index >= 0 ? NSIndexPath(forItem: index, inSection: 0) : nil , state)
        }
        
    }
}