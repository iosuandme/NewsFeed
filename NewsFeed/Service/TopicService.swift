//
//  TopicService.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/22/16.
//  Copyright © 2016 Kidney. All rights reserved.
//



class TopicService: NSObject {
    
    static func getAllTopics(block: (([Topic_Bmob], NSError?) -> Void)?) {
        searchTopic(byName: nil, block: block)
    }
    
    static func searchTopic(byName name: String?, block: (([Topic_Bmob], NSError?) -> Void)?) {
        let query = BmobQuery(className: "Topic")
        
        let trimName = name?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if trimName?.characters.count > 0 {
            query.whereKey("name", matchesWithRegex: ".*"+trimName!+".*")
        }
        
        query.findObjectsInBackgroundWithBlock { (topics, error) in
            block?(topics.map { obj in Topic_Bmob.convert(obj as! BmobObject) }, error ?? nil)
        }
    }
    
    static func getLikedTopics(ofUser: String?, block: (([Topic_Bmob], NSError?) -> Void)?) {

        let query = BmobQuery(className: "Topic")
        
        let user = BmobUser(outDataWithClassName: "_User", objectId: ofUser ?? User_Bmob.currentUser()?.objectId)
        
        query.whereObjectKey("topics_liked", relatedTo: user)
        query.findObjectsInBackgroundWithBlock({ (topics, error) in
            if error == nil {
                block?(topics.map { obj in Topic_Bmob.convert(obj as! BmobObject) }, nil)
            } else {
                block?([], error)
            }
        })
    }
    
    static func getLikedTopicIds(ofUser: String?, block: (([String], NSError?) -> Void)?) {
        
        let query = BmobQuery(className: "Topic")
        
        let user = BmobUser(outDataWithClassName: "_User", objectId: ofUser ?? User_Bmob.currentUser()?.objectId)
        query.whereObjectKey("topics_liked", relatedTo: user)
        
        query.selectKeys(["objectId"])
        
        query.findObjectsInBackgroundWithBlock({ (topics, error) in
            if error == nil {
                block?(topics.map { obj in (obj as! BmobObject).objectId }, nil)
            } else {
                block?([], error)
            }
        })
    }
}
