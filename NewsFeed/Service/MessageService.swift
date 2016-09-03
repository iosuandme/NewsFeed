//
//  MessageService.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/20/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

import FCFileManager
import SDWebImage

typealias StateChangeBlock = ((state: Message_Bmob.MessageState, message: Message_Bmob?, error: NSError?) -> Void);

class MessageService: NSObject {
    
    static func send(text text: String, toUser: String, withSendStateBlock stateBlock: StateChangeBlock?) {
        
        let msgContent = MessageContent_Bmob()
        
        msgContent.content_type = .Text
        msgContent.text = text

        let message = Message_Bmob()
        
        message.message_type = .Message
        message.sender = User_Bmob.currentUser()
        message.receiver = User_Bmob()
        message.receiver.objectId = toUser
        message.content = msgContent
        message.createdAt = NSDate()
        
        message.state = .Sending
        stateBlock?(state: message.state, message: message, error: nil)
        
        send(message, withSendStateBlock: stateBlock)
    }
    
    static func send(image image: UIImage, toUser: String, withSendStateBlock stateBlock: StateChangeBlock?) {
        
        let msgContent = MessageContent_Bmob()
        
        msgContent.content_type = .Image
        
        let message = Message_Bmob()
        
        message.message_type = .Message
        message.sender = User_Bmob.currentUser()
        message.receiver = User_Bmob()
        message.receiver.objectId = toUser
        message.createdAt = NSDate()
        message.content = msgContent
        
        let file = FileHelper.generateJPEGFile(withImage: image)
        message.content?.image = file
        
        message.state = .SendingUploadStart
        stateBlock?(state: message.state, message: message, error: nil)
        
        file.saveInBackground(
            { [weak file,msgContent,message] (uploadSuccess, uploadError) in
                
                if uploadError != nil {
                    
                    message.state = .FailedUpload
                    stateBlock?(state: message.state, message: nil, error: uploadError)
                    
                } else {
                    
                    msgContent.image = file
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { 
                        SDImageCache.sharedImageCache().storeImage(image, forKey: file?.url)
                    })
                    
                    message.state = .Sending
                    stateBlock?(state: message.state, message: nil, error: nil)
                    
                    self.send(message, withSendStateBlock: stateBlock)
                }
                
            })
            { (progress) in
                stateBlock?(state: .SendingUploading(progress), message: nil, error: nil)
            }

    }
    
    // like、comment、share、follow
    static func send(actionNotification: Message_Bmob.MessageType, toUser: String, newsRelated: String? = nil, withSendStateBlock stateBlock: StateChangeBlock?) {
        let message = Message_Bmob()
        
        message.message_type = actionNotification
        message.sender = User_Bmob.currentUser()
        message.receiver = User_Bmob()
        message.receiver.objectId = toUser
        message.createdAt = NSDate()
        
        if newsRelated != nil {
            let msgContent = MessageContent_Bmob()
            msgContent.content_type = .NewsRelated
            msgContent.setObject(BmobObject(outDataWithClassName: "News", objectId: newsRelated), forKey: "newsRelated")
            message.content = msgContent
        }
        
        send(message, newsRelated: newsRelated, withSendStateBlock: stateBlock)
    }
    
    private static func send(message: Message_Bmob, newsRelated: String? = nil, withSendStateBlock stateBlock: StateChangeBlock?) {
        message.sub_saveInBackgroundWithResultBlock { [weak message] (success, error) in
            
            if let strongMessage = message {
                if stateBlock != nil {
                    strongMessage.state = (error == nil) ? .Sended : .FailedSend
                    stateBlock!(state: strongMessage.state, message: nil, error: nil)
                }
                
                if success {
                    PushService.push(strongMessage, newsRelated: newsRelated, toUser: strongMessage.receiver.objectId)
                } else {
                    Toast.show("message send fail: \(error.localizedDescription)")
                }
            }
        }
        
    }
    
    static func getDescriptionPostfix(forMessageType: Message_Bmob.MessageType) -> String {
        var postfix: String?
        switch forMessageType {
        case .Message:
            postfix = "sent you a message"
        case .Like:
            postfix = "liked your photo"
        case .Comment:
            postfix = "commented your photo"
        case .Retweet:
            postfix = "retweeted your photo"
        case .Follow:
            postfix = "followed you"
        default:
            break
        }
        
        assert(postfix != nil, "message type invalid")
        
        return postfix!
    }
}

private class PushService: NSObject {

    // push
    static func push(message: Message_Bmob, newsRelated: String? = nil, toUser userId: String) {
        
        let user = User_Bmob.currentUser()!
        
        let push = BmobPush()
        
        let query = BmobQuery(className: "_Installation")
        query.whereKey("isDeveloper", equalTo: true)
        query.whereKey("userId", equalTo: userId)
        
        push.setQuery(query)
        
        query.findObjectsInBackgroundWithBlock({ (array, error) in
            print("push query: \(array)")
        })
        
        
        let postfix = MessageService.getDescriptionPostfix(message.message_type)
        
        var data: [NSObject : AnyObject] = ["aps": ["alert": user.nickname + " " + postfix,
                            ],
                    ]
        data["messageId"] = message.objectId
        if newsRelated == nil {
            var jump = ["UIViewController": "SingleChatRoomViewController",
                        "id": user.objectId,
                        "name": user.nickname,
                        ]
            
            if let avatar = user.thumbURL?.absoluteString {
                jump["avatar"] = avatar
            }
            data["jump"] = jump
        } else {
            data["jump"] = ["UIViewController": "NewsDetailViewController",
                            "id": newsRelated!]
        }
        push.setData(data)
        
        push.sendPushInBackgroundWithBlock { (success, error) in
            
        }
    }
}