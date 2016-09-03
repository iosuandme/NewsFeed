//
//  NewsDetailViewModel.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/23/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

import ReactiveCocoa
import Result
import DateTools

class NewsDetailViewModel: NSObject {
    
    private(set) var news: News_Bmob!
    
    // MARK: properties
    
    lazy var topicName: AnyProperty<String> = {
        return DynamicProperty(object: self, keyPath: "news.topic.name").map { ($0 as? String) ?? "Loading..." }
    }()
    lazy var nickName: AnyProperty<String> = {
        return DynamicProperty(object: self, keyPath: "news.author.nickname").map { ($0 as? String) ?? "Loading..." }
    }()
    lazy var likesCount: AnyProperty<String> = {
        return DynamicProperty(object: self, keyPath: "news.likesCount").map { $0 == nil ? "0" : String($0!) }
    }()
    lazy var commentsCount: AnyProperty<String> = {
        return DynamicProperty(object: self, keyPath: "news.commentsCount").map { $0 == nil ? "0" : String($0!) }
    }()
    
    // MARK: signals
    
    lazy var avatarURLSignal: RACSignal = {
        return RACObserve(self, "news.author.thumbURL")
    }()
    lazy var imageURLSignal: RACSignal = {
        return RACObserve(self, "news.imageURL")
    }()
    
    // MARK: actions
    
    lazy var likeNewsAction: Action<(), (), NSError> = {
        let ac = Action( { () -> SignalProducer<(), NSError> in
            
            return SignalProducer({ (observer: Observer<(), NSError>, disposable: Disposable?) in
                NewsService.likeNews(self.news.objectId, authorId: self.news.author.objectId, authorInfoId: self.news.author.info.objectId) { (success, error) in
                    if error != nil {
                        observer.sendFailed(error!)
                    } else {
                        self.news.setValue(self.news.likesCount+1, forKey: "likesCount")
                        observer.sendCompleted()
                    }
                }
            })
        })
        
        return ac;
    }()
    
    // same user scan same news multi times in one day do not add views count
    static var (userId, newsId, date): (String?, String?, NSDate?) = (nil, nil, nil)
    lazy var viewedNewsAction: Action<(), (), NoError> = {
        
        let ac = Action( { () -> SignalProducer<(), NoError> in
            
            return SignalProducer({ (observer: Observer<(), NoError>, disposable: Disposable?) in
                
                if userId != User_Bmob.currentUser()?.objectId || newsId != self.news.objectId || NSDate().day() != date?.day() {
                    userId = User_Bmob.currentUser()?.objectId
                    newsId = self.news.objectId
                    date = NSDate()
                    
                    NewsService.viewedNews(self.news.objectId)
                }
                
                observer.sendCompleted()
            })
        })
        
        return ac;
    }()
    
    // MARK: else
    
    init(withNews newsId: String) {
        super.init()
        
        let news = News_Bmob()
        news.objectId = newsId
        self.news = news
    }
    
    func showComment() {
        PageRouter.showCommentPage(forNews: news.objectId, authorId: news.author.objectId)
    }
    
    func refreshModel() {
        NewsService.getNewsDetail(self.news.objectId) { (result, error) in
            if error != nil {
                Toast.showError("get detail failed")
            } else {
                self.setValue(result, forKey: "news")
            }
        }
    }
}