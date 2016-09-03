//
//  Topic+Bmob.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/16/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

class Topic_Bmob: BmobObject {
    
    var hasLiked = false
    var name: String!
    var imageURL: NSURL?
    
    static func topic(withId id: String!) -> Topic_Bmob {
        return Topic_Bmob.convert(BmobObject(outDataWithClassName: "Topic", objectId: id))
    }
    
    static func convert(obj: BmobObject) -> Topic_Bmob {
        let topic = Topic_Bmob.convertWithObject(obj)
        
        //不支持转化Bool，Int，Float类型,所以 需要手动设置
        if let image = obj.objectForKey("image") {
            topic.imageURL = NSURL(string: (image as! BmobFile).url)
        }
        
        if let hasLiked = obj.objectForKey("hasLiked") {
            topic.hasLiked = hasLiked as! Bool
        }
        
        return topic
    }
    
    override func sub_saveInBackgroundWithResultBlock(block: BmobBooleanResultBlock!) {
        //转化后的表名有问题，需要手动设置
        self.className = "Message"
        
        //不支持转化Bool，Int，Float类型,所以 需要手动设置
        self.setObject(hasLiked, forKey: "hasLiked")
        
        super.sub_saveInBackgroundWithResultBlock(block)
    }
}
