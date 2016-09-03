//
//  News+Bmob.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/16/16.
//  Copyright © 2016 Kidney. All rights reserved.
//


class News_Bmob: BmobObject {
    
    var image: BmobFile? {
        didSet {
            if image != nil {
                imageURL = NSURL(string: image!.url)!
            }
        }
    }
    
    var thumbnail: BmobFile? {
        didSet {
            if thumbnail != nil {
                thumbURL = NSURL(string: thumbnail!.url)!
            }
        }
    }
    
    var author: User_Bmob!
    var content: String!
    var newsId: UInt?
    var topic: Topic_Bmob!
    
    var likesCount: UInt = 0
    var commentsCount: UInt = 0
    var viewsCount: UInt = 0
    var shareCount: UInt = 0
    
    var hashtags: [String]?
    var hashtagsCount: [String:UInt]?
    var comments: [CommentModel]?

    var imageURL: NSURL!
    
    var thumbURL: NSURL!
    
    override init() {
        super.init(className: "News")
    }
    
    static func convert(obj: BmobObject) -> News_Bmob {
        
        // because array & dictionary will return blank string "", so match the type
        if !(obj.objectForKey("hashtags") is [String]) {
            obj.setObject([], forKey: "hashtags")
        }
        if !(obj.objectForKey("hashtagsCount") is [String:UInt]) {
            obj.setObject([:], forKey: "hashtagsCount")
        }

        let news = News_Bmob.convertWithObject(obj)

        if let newsId = obj.objectForKey("newsId") {
            news.newsId = newsId as? UInt
        }
        if let author = obj.objectForKey("author") {
            news.author = User_Bmob.convert(author as? BmobObject)
        }
        if let topic = obj.objectForKey("topic") {
            news.topic = Topic_Bmob.convert(topic as! BmobObject)
        }

        if let comments = (obj.objectForKey("comments") as? [BmobObject]) {
            news.comments = comments.map({ (value) -> CommentModel in
                CommentModel.convert(value)
            })
        } else {
            news.comments = nil
        }
        
        if let likesCount = obj.objectForKey("likesCount") {
            news.likesCount = likesCount as! UInt
        }
        if let commentsCount = obj.objectForKey("commentsCount") {
            news.commentsCount = commentsCount as! UInt
        }
        if let viewsCount = obj.objectForKey("viewsCount") {
            news.viewsCount = viewsCount as! UInt
        }
        if let shareCount = obj.objectForKey("shareCount") {
            news.shareCount = shareCount as! UInt
        }
        
        return news
    }
    
    override func sub_saveInBackgroundWithResultBlock(block: BmobBooleanResultBlock!) {
        //转化后的表名有问题，需要手动设置
        self.className = "News"
        
        self.newsId = nil
        self.setObject(topic, forKey: "topic")
        
        super.sub_saveInBackgroundWithResultBlock(block)
    }
    
    override func sub_updateInBackgroundWithResultBlock(block: BmobBooleanResultBlock!) {
        //转化后的表名有问题，需要手动设置
        self.className = "News"
        
        //不支持转化Bool，Int，Float类型,所以 需要手动设置
        
        
        super.sub_updateInBackgroundWithResultBlock(block)
    }
}
