//
//  CommentModel.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/24/16.
//  Copyright © 2016 Kidney. All rights reserved.
//


class CommentModel: BmobObject {
    
    var newsRelated = News_Bmob()
    var author = User_Bmob.currentUser()
    var tags: [String]?
    var comment: String?
    
    static func createComment(newsId: String) -> CommentModel {
        let comment = CommentModel()
        
        comment.author = User_Bmob(outDataWithClassName: "_User", objectId: User_Bmob.currentUser()?.objectId)
        comment.newsRelated.objectId = newsId
        
        return comment
    }
    
    static func convert(obj: BmobObject) -> CommentModel {
        
        let comment = CommentModel.convertWithObject(obj)
        
        if let newsRelated = obj.objectForKey("newsRelated") {
            comment.newsRelated = News_Bmob.convert(newsRelated as! BmobObject)
        }
        if let author = obj.objectForKey("author") {
            comment.author = User_Bmob.convert(author as? BmobObject)
        }
        
        return comment
    }
    
    override func sub_saveInBackgroundWithResultBlock(block: BmobBooleanResultBlock!) {
        //转化后的表名有问题，需要手动设置
        self.className = "Comment"
        
        //不支持转化Bool，Int，Float类型,所以 需要手动设置
        
        self.setObject(BmobObject(outDataWithClassName: "News", objectId: newsRelated.objectId), forKey: "newsRelated")
        self.setObject(BmobObject(outDataWithClassName: "_User", objectId: author!.objectId), forKey: "author")
        self.setObject(tags, forKey: "tags")
        self.setObject(comment, forKey: "comment")
        
        super.sub_saveInBackgroundWithResultBlock(block)
    }
    
    override func sub_updateInBackgroundWithResultBlock(block: BmobBooleanResultBlock!) {
        
    }
}
