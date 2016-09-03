//
//  Message+Bmob.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/16/16.
//  Copyright © 2016 Kidney. All rights reserved.
//



class Message_Bmob: BmobObject {
    
    enum MessageType: Int {
        case Message = 0        // - xxx sent you a message
        case Follow             // - xxx followed you
        case Unfollow           // - xxx unfollowed you
        case Comment            // - xxx commented your photo
        case Retweet            // - xxx retweeted your photo
        case Like               // - xxx liked your photo
        case All                // for search
    }
    
    enum MessageState {
        case Initialed
        case SendingUploadStart
        case SendingUploading(CGFloat)
        case Sending
        case FailedUpload
        case FailedSend
        case Sended
        case Achieved
        case Readed
        
        func getValue() -> (Int, String) {
            switch self {
            case .Initialed:
                return (0, "initialed")
            case .SendingUploadStart:
                return (100, "start upload")
            case .SendingUploading:
                return (101, "uploading")
            case .Sending:
                return (102, "sending")
            case .FailedUpload:
                return (200, "upload failed")
            case .FailedSend:
                return (201, "failed")
            case .Sended:
                return (300, "sended")
            case .Achieved:
                return (400, "achieved")
            case .Readed:
                return (401, "readed")
            }
        }
        
        static func initWithRawValue(rawValue: Int, progress: CGFloat = 0) -> MessageState {
            switch (rawValue, progress) {
            case (0, _):
                return .Initialed
            case (100, _):
                return .SendingUploadStart
            case (101, _):
                return .SendingUploading(progress)
            case (102, _):
                return .Sending
            case (200, _):
                return .FailedUpload
            case (201, _):
                return .FailedSend
            case (300, _):
                return .Sended
            case (400, _):
                return .Achieved
            case (401, _):
                return .Readed
            default:
                return .Initialed
            }
        }
    }
    
    var message_type = MessageType.Message
    var content: MessageContent_Bmob? = nil
    var messageId: UInt?
    var sender: User_Bmob!
    var receiver: User_Bmob!
    var state = MessageState.Initialed
    
    static func convert(obj: BmobObject) -> Message_Bmob{
        let msg = Message_Bmob.convertWithObject(obj)
        
        //不支持转化Bool，Int，Float类型,所以 需要手动设置
        if let state = obj.objectForKey("state") {
            msg.state = MessageState.initWithRawValue(state as! Int)
        }
        
        if let message_type = obj.objectForKey("message_type") {
            msg.message_type = MessageType(rawValue: message_type as! Int)!
        }
        
        if let messageId = obj.objectForKey("messageId") {
            msg.messageId = messageId as? UInt
        }
        
        if let content = obj.objectForKey("content") {
            msg.content = MessageContent_Bmob.convert(content as! BmobObject)
        }
        
        if let sender = obj.objectForKey("sender") {
            msg.sender = User_Bmob.convert(sender as? BmobObject)
        }
        
        if let receiver = obj.objectForKey("receiver") {
            msg.receiver = User_Bmob.convert(receiver as? BmobObject)
        }

        return msg
    }
    
    override func sub_saveInBackgroundWithResultBlock(block: BmobBooleanResultBlock!) {
        //转化后的表名有问题，需要手动设置
        self.className = "Message"
        
        //不支持转化Bool，Int，Float类型,所以 需要手动设置
        self.setObject(messageId, forKey: "messageId")
        self.setObject(message_type.rawValue, forKey: "message_type")
        self.setObject(MessageState.Sended.getValue().0, forKey: "state")
        self.setObject(BmobUser(outDataWithClassName: "_User", objectId: self.sender.objectId), forKey: "sender")
        self.setObject(BmobUser(outDataWithClassName: "_User", objectId: self.receiver.objectId), forKey: "receiver")
            
        if self.content != nil {
            self.content?.sub_saveInBackgroundWithResultBlock({ (success, error) in
                if success {
                    self.setObject(BmobObject(outDataWithClassName: "MessageContent", objectId: self.content?.objectId), forKey: "content")
                    
                    super.sub_saveInBackgroundWithResultBlock(block)
                } else {
                    block?(false, error)
                }
            })
        } else {
            super.sub_saveInBackgroundWithResultBlock(block)
        }
    }
}
