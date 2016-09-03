//
//  MessageSearcher.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/22/16.
//  Copyright © 2016 Kidney. All rights reserved.
//



class MessageSearcher: NSObject {
    /**
     the messages returned is ordered by time desc
     */
    static func getMessages(type: Message_Bmob.MessageType, earlierThanLastMessageId messageId: UInt?, withUser userId: String? = nil, pageSize: Int = 10, block: (([Message_Bmob], NSError?) -> Void )) {
        
        let query = BmobQuery(className: "Message")
        
        // set sender & receiver => for interaction with certain user
        if userId != nil {
            let ids = [userId, User_Bmob.currentUser()?.objectId]
            
            let sub1 = ["sender":["__type":"Pointer","className":"_User","objectId":ids[0]!],
                        "receiver":["__type":"Pointer","className":"_User","objectId":ids[1]!]]
            let sub2 = ["sender":["__type":"Pointer","className":"_User","objectId":ids[1]!],
                        "receiver":["__type":"Pointer","className":"_User","objectId":ids[0]!]]
            query.addTheConstraintByOrOperationWithArray([sub1, sub2])
        } else {
            query.whereKey("receiver", equalTo: BmobObject(outDataWithClassName: "_User", objectId: User_Bmob.currentUser()?.objectId))
        }
        
        if messageId != nil {
            query.whereKey("messageId", lessThan: messageId)
        }
        
        if type != .All {
            query.whereKey("message_type", equalTo: type.rawValue)
        }
        
        query.includeKey("sender,content,content.newsRelated")
        query.orderByDescending("messageId")
        query.limit = pageSize
        
        query.findObjectsInBackgroundWithBlock({ (result, error) in
            if error != nil {
                block([], error)
            } else {
                let newMsgs = result.map{ msg in Message_Bmob.convert(msg as! BmobObject) }
                block(Array(newMsgs), nil)
            }
        })
    }
    
    static func getMessage(byId id: String, block: (Message_Bmob!, NSError?)->Void) {
        let query = BmobQuery(className: "Message")
        
        query.includeKey("sender,content")
        query.getObjectInBackgroundWithId(id) { (result, error) in
            if error != nil {
                block(nil, error!)
            } else {
                block(Message_Bmob.convert(result), nil)
            }
        }
    }
}
