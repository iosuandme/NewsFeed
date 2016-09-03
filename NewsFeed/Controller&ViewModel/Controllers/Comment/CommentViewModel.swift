//
//  CommentViewModel.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/24/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

import ReactiveCocoa

class CommentViewModel: NSObject {
    
    private var newsId: String!
    private var authorId: String!
    
    var comment: String?
    var tags: [String] = []
    
    init(withNews newsId: String, authorId: String) {
        super.init()
        
        self.newsId = newsId
        self.authorId = authorId
    }
    
    lazy var commentAction : Action<(), Int, NSError> = {

        return Action( { () -> SignalProducer<Int, NSError> in
            SignalProducer { (observer: Observer<Int, NSError>, disposable: Disposable?) in
                if self.comment?.trimLength() > 0 {
                    NewsService.commentNews(self.newsId, authorId: self.authorId, comment: self.comment!, withTags: self.tags) { (success, error) in
                        if success {
                            observer.sendCompleted()
                        } else {
                            observer.sendFailed(error)
                        }
                    }
                } else {
                    observer.sendFailed(ParameterError("please write comment first"))
                }
            }
        })
    }()

}
