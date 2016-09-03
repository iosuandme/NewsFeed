//
//  NewsService.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/21/16.
//  Copyright © 2016 Kidney. All rights reserved.
//



class NewsService: NSObject {
    
    // MARK: Web API
    
    // MARK: C
    static func publishNews(image: UIImage, text: String, relatedToTopic topicId:String, block: BmobBooleanResultBlock) {
        let news = News_Bmob()
        
        let fileDics = FileHelper.generateJPEGFilesInlcudeThumbnail(withImage: image)
        BmobFile.filesUploadBatchWithDataArray(fileDics, progressBlock: nil, resultBlock: { (files, isSuccessful, error) in
            if isSuccessful {
                
                //如果文件保存成功，则把文件添加到file列
                news.thumbnail = files[0] as? BmobFile
                news.image = files[1] as? BmobFile
                news.content = text
                news.author = User_Bmob.currentUser()
                news.topic = Topic_Bmob.topic(withId: topicId)
                
                news.sub_saveInBackgroundWithResultBlock({ [weak news] (success, error2) in
                    if error2 != nil {
                        block(false, error2)
                    } else {
                        if let strongNews = news {
                            let info = BmobObject(outDataWithClassName: "UserAdditionalInfo", objectId: User_Bmob.currentUser()!.info.objectId)
                            
                            let relation = BmobRelation()
                            relation.addObject(BmobObject(outDataWithClassName: "News", objectId: strongNews.objectId))
                            info.addRelation(relation, forKey: "posts_list")
                            info.incrementKey("postsCount")
                            
                            info.updateInBackgroundWithResultBlock({ (success3, error3) in
                                block(success3, error3)
                            })
                        } else {
                            block(false, DeallocError)
                        }
                        
                    }
                })
            }else{
                block(false, error)
            }
        })
    }
    
    // MARK: R
    
    static func getNewsDetail(newsId: String, block: (News_Bmob!, NSError?)->Void) {
        let query = BmobQuery(className: "News")
        
        query.includeKey("topic,author")
        
        query.getObjectInBackgroundWithId(newsId) { (result, error) in
            if error == nil {
                block(News_Bmob.convert(result), nil)
            } else {
                block(nil, error!)
            }
        }
    }
    
    /**
     search news by user
     */
    static func getNews(pageSize: Int, boundary newsId: UInt?, ofUser userId: String?, earlier: Bool = true, block: ([News_Bmob], NSError?)->Void) {
        let query = BmobQuery(className: "News")
        
        query.whereKey("author", equalTo: BmobUser(outDataWithClassName: "_User", objectId: userId))
        if newsId != nil {
            if earlier {
                query.whereKey("newsId", lessThan: newsId)
            } else {
                query.whereKey("newsId", greaterThan: newsId)
            }
        }
        
        query.includeKey("author")
        query.orderByDescending("newsId")
        query.limit = pageSize
        
        query.findObjectsInBackgroundWithBlock({ (result, error) in
            let newsPage = Array(result.map{ msg in News_Bmob.convert(msg as! BmobObject) })
            block(newsPage, error)
        })
    }
    
    /**
     search news by topic, result is time desc
     */
    static func getNews(relatedToTopic topicId: String?, pageSize: Int, lastNewsId newsId: UInt?, earlierOrLater: Bool = true, block: ([News_Bmob], NSError?)->Void) {
        let query = BmobQuery(className: "News")
        
        if topicId != nil {
            query.whereKey("topic", equalTo: BmobObject(outDataWithClassName: "Topic", objectId: topicId))
        }
        if newsId != nil {
            query.whereKey("newsId", lessThan: newsId)
        }
        
        query.includeKey("author,topic")
        query.orderByDescending("newsId")
        query.limit = pageSize
        
        query.findObjectsInBackgroundWithBlock({ (result, error) in
            let newsPage = Array(result.map{ msg in News_Bmob.convert(msg as! BmobObject) })
            block(newsPage, error)
        })
    }
    
    /**
     search news by tags, result is time desc
     */
    static func getNews(relatedToTag tags: [String], pageSize: Int, lastNewsId newsId: UInt?, block: ([News_Bmob], NSError?)->Void) {
        let query = BmobQuery(className: "News")
        
        if tags.count != 0 {
            query.whereKey("hashtags", equalTo: ["$all": tags])
        }
        if newsId != nil {
            query.whereKey("newsId", lessThan: newsId)
        }
        
        query.includeKey("author")
        query.orderByDescending("newsId")
        query.limit = pageSize
        
        query.findObjectsInBackgroundWithBlock({ (result, error) in
            let newsPage = Array(result.map{ msg in News_Bmob.convert(msg as! BmobObject) })
            block(newsPage, error)
        })
    }
    
    static func getNews(minNewsId: UInt, maxNewsId: UInt, relatedToTopicId: String? = nil, tags: [String] = [], ofUser userId: String? = nil, block: ([News_Bmob], NSError?)->Void) {
        let query = BmobQuery(className: "News")
        
        var conditions: [[String: AnyObject]] = [["newsId": ["$lte": maxNewsId]], ["newsId": ["$gte": minNewsId]]]
        if relatedToTopicId != nil {
            conditions.append(["topic": ["__type":"Pointer","className":"Topic","objectId":relatedToTopicId!]])
        }
        if tags.count > 0 {
            conditions.append(["hashtags":["$all": tags]])
        }
        if userId != nil {
            conditions.append(["author":["__type":"Pointer","className":"_User","objectId":userId!]])
        }
        
        query.addTheConstraintByAndOperationWithArray(conditions)
        query.includeKey("author")
        query.orderByDescending("newsId")
        
        query.findObjectsInBackgroundWithBlock({ (result, error) in
            let newsPage = Array(result.map{ msg in News_Bmob.convert(msg as! BmobObject) })
            block(newsPage, error)
        })
    }
    
    /**
        get latest num comments
     */
    static func getComments(relatedToNews newsId: String, limitNum num: Int, block: ([CommentModel], NSError?)->Void) {

        let query = BmobQuery(className: "Comment")

        let news = BmobObject(outDataWithClassName: "News", objectId: newsId)
        query.whereObjectKey("comments", relatedTo: news)
        query.orderByDescending("commentId")
        query.limit = num
        
        query.includeKey("author")
        
        query.findObjectsInBackgroundWithBlock { (result, error) in
            let comments = Array(result.map{ msg in CommentModel.convert(msg as! BmobObject) }.reverse())
            block(comments, error)
        }
    }
    
    // MARK: U
    
    // comment
    static func commentNews(newsObjectId: String, authorId: String, comment text: String, withTags tags: [String], block: BmobBooleanResultBlock?) {
        
        let comment = CommentModel.createComment(newsObjectId)
        
        comment.comment = text
        comment.tags = tags
        
        comment.sub_saveInBackgroundWithResultBlock { [weak comment] (success, error) in
            if error != nil {
                block?(false, error)
            } else {
                let news = BmobObject(outDataWithClassName: "News", objectId: newsObjectId)
                
                if let comm = comment {
                    news.incrementKey("commentsCount")
                    
                    let relation = BmobRelation()
                    relation.addObject(BmobObject(outDataWithClassName: "Comment", objectId: comm.objectId))
                    news.addRelation(relation, forKey: "comments")
                    
                    news.addUniqueObjectsFromArray(tags, forKey: "hashtags")
                    for tagName in tags {
                        news.incrementKey("hashtagsCount." + tagName)
                    }
                    
                    news.updateInBackgroundWithResultBlock(block)
                    
                    MessageService.send(.Comment, toUser: authorId, newsRelated: newsObjectId, withSendStateBlock: nil)
                }
                
            }
        }
    }
    
    // like
    static func likeNews(newsObjectId: String, authorId: String, authorInfoId: String, block: BmobBooleanResultBlock?) {
        let query = BmobQuery(className: "News")
        
        let inQuery = BmobUser.query()
        inQuery.whereKey("objectId", equalTo: User_Bmob.currentUser()?.objectId)
        inQuery.limit = 1
        
        query.whereKey("objectId", equalTo: newsObjectId)
        query.whereKey("likes", matchesQuery: inQuery)
        
        query.countObjectsInBackgroundWithBlock { (count, error) in
            if error != nil {
                block?(false, error)
            } else {
                if count > 0 {
                    
                    block?(false, NSError(domain: "bmob", code: 400, userInfo: [NSLocalizedDescriptionKey: "you hava already liked this news"]))

                } else {
                    let relation = BmobRelation()
                    relation.addObject(BmobUser(outDataWithClassName: "_User", objectId: User_Bmob.currentUser()?.objectId))
                    
                    let news = BmobObject(outDataWithClassName: "News", objectId: newsObjectId)
                    
                    news.addRelation(relation, forKey: "likes")
                    news.incrementKey("likesCount")
                    
                    news.updateInBackgroundWithResultBlock({ (isSuccess, error) in
                        
                        block?(isSuccess, error)
                        
                        if isSuccess {
                            MessageService.send(.Like, toUser: authorId, newsRelated: newsObjectId, withSendStateBlock: nil)
                            UserService.changeLikes(toUser: authorId, infoId: authorInfoId, block: nil)
                        }
                    })
                    
                }
            }
        }
    }
    
    // viewed
    static func viewedNews(newsObjectId: String) {
        
        let news = BmobObject(outDataWithClassName: "News", objectId: newsObjectId)
        news.incrementKey("viewsCount")
        
        news.updateInBackground()
    }
}