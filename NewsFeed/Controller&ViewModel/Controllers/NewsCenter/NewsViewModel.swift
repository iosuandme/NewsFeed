//
//  NewsViewModel.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/17/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

import ReactiveCocoa
import Result

class NewsViewModel: NSObject {
    
    var currentTopicNames: [String] = []
    var currentTagNames: [String] = []
    
    private var type = 0
    private var topiclist: [Topic_Bmob] = [] {
        didSet {
            let list = topiclist
            
            topicNames = list.map { topic in topic.name }
        }
    }
    
    let dataSourceNotification: (Signal<DataSourceNotificationType, NSError>, Observer<DataSourceNotificationType, NSError>) = Signal.pipe()
    var topicNames: [String] = []
    
    var newsDatasource: [[String : AnyObject?]] = []
    
    // MARK: like, comment, share
    
    func showCommentPage(forNewsAtIndexPath indexPath: NSIndexPath?) {
        if indexPath != nil {
            let news = self.newsDatasource[indexPath!.row]
            PageRouter.showCommentPage(forNews: news["newsObjectId"] as! String, authorId: news["authorId"] as! String)
        }
    }
    
    func showProfileFor(indexPath: NSIndexPath?, vc: UIViewController) {
        if indexPath != nil {
            let user = User_Bmob(outDataWithClassName: "_User", objectId: self.newsDatasource[indexPath!.row]["authorId"] as! String)
            user.info = UserAdditionalInfo()
            user.info.objectId = self.newsDatasource[indexPath!.row]["authorInfoId"] as! String
            PageRouter.showProfileFor(user, fromVC: vc)
        }
        
    }
    
    lazy var reloadVisible : Action<[NSIndexPath], Int, NSError> = {
        return Action( { (indexes: [NSIndexPath]) -> SignalProducer<Int, NSError> in
            
            return SignalProducer({ (observer: Observer<Int, NSError>, disposable: Disposable?) in
                if indexes.count == 0 {
                    observer.sendCompleted()
                } else {
                    let (id1, id2) = (indexes.first!.row, indexes.last!.row)
                    let (minId, maxId) = (min(id1, id2), max(id1, id2))
                    let (minNewsId, maxNewsId) = (self.newsDatasource[maxId]["newsId"] as! UInt, self.newsDatasource[minId]["newsId"] as! UInt)
                    NewsService.getNews(minNewsId, maxNewsId: maxNewsId, block: { (result, error) in
                        if error == nil {
                            self.newsDatasource.replaceRange(minId...maxId, with: self.reformer(news: result))
                            self.dataSourceNotification.1.sendNext(.ReloadItemsAtIndexPaths(indexes))
                        }
                        observer.sendCompleted()
                    })
                }
            })
        })
    }()
    
    lazy var likeNewsAction : Action<Int, Int, NSError> = {
        return Action( { (index: Int) -> SignalProducer<Int, NSError> in
            
            return SignalProducer({ (observer: Observer<Int, NSError>, disposable: Disposable?) in

                let (newsId, authorId, infoId) = (self.newsDatasource[index]["newsObjectId"] as! String,
                                                  self.newsDatasource[index]["authorId"] as! String,
                                                  self.newsDatasource[index]["authorInfoId"] as! String
                                                  )
                NewsService.likeNews(newsId, authorId: authorId, authorInfoId: infoId, block: { [weak self] (success, error) in
                    if error != nil {
                        observer.sendFailed(error!)
                    } else {
                        self!.newsDatasource[index]["likesCount"] = String(UInt(self!.newsDatasource[index]["likesCount"] as! String)! + 1)
                        self?.dataSourceNotification.1.sendNext(.ReloadItemsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)]))
                        observer.sendCompleted()
                    }
                })
            })
        })
    }()
    
    lazy var showNewsDetail : Action<Int, (), NoError> = {
        return Action( { (index: Int) -> SignalProducer<(), NoError> in
            
            return SignalProducer({ (observer: Observer<(), NoError>, disposable: Disposable?) in
                PageRouter.showNewsDetail(forNews: self.newsDatasource[index]["newsObjectId"] as! String)
                observer.sendCompleted()
            })
        })
    }()
    
    // MARK: for tag
    
    lazy var dataSourceOperationWithTag : Action<DataSourceOperationType, (), NSError> = {
        let pageSize = 2
        
        let ac = Action( { (operation: DataSourceOperationType) -> SignalProducer<(), NSError> in
            return SignalProducer(signal: Signal {[unowned self] (observer: Observer<(), NSError>) -> Disposable? in
                
                self.type = 1
                
                var newsId: UInt? = nil
                switch operation {
                case .LoadNextPage where self.newsDatasource.count > 0:
                    newsId = self.newsDatasource.last!["newsId"] as? UInt
                default:
                    break
                }
                
                let tags = self.currentTagNames.filter{ HashTags.contains($0) }
                NewsService.getNews(relatedToTag: tags, pageSize: pageSize, lastNewsId: newsId, block: { (result, error) in
                    let newsNew = self.reformer(news: result)
                    switch operation {
                    case .LoadNextPage where self.newsDatasource.count > 0:
                        self.newsDatasource += newsNew
                        
                        let indexPaths = (self.newsDatasource.count-newsNew.count..<self.newsDatasource.count).map{ NSIndexPath(forRow: $0, inSection: 0) }
                        self.dataSourceNotification.1.sendNext(.InsertItemsAtIndexPaths(indexPaths, newsNew.count != pageSize))
                    default:
                        self.newsDatasource = newsNew
                        self.dataSourceNotification.1.sendNext(.ReloadData(newsNew.count != pageSize))
                    }
                    observer.sendCompleted()
                })
                
                return nil
                })
        })
        
        return ac;
    }()
    
    // MARK: for people
    
    lazy var dataSourceOperationWithTopic : Action<DataSourceOperationType, (), NSError> = {
        let pageSize = 2
        
        let ac = Action( { (operation: DataSourceOperationType) -> SignalProducer<(), NSError> in
            return SignalProducer(signal: Signal {[unowned self] (observer: Observer<(), NSError>) -> Disposable? in
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    self.type = 0
                    
                    var (newsId, topicId): (UInt?, String?) = (nil, nil)
                    switch operation {
                    case .LoadNextPage where self.newsDatasource.count > 0:
                        newsId = self.newsDatasource.last!["newsId"] as? UInt
                    default:
                        break
                    }
                    
                    if self.currentTopicNames.count > 0 {
                        if let index = self.topicNames.indexOf(self.currentTopicNames[0]) {
                            topicId = self.topiclist[index].objectId
                        }
                    }
                    
                    NewsService.getNews(relatedToTopic: topicId, pageSize: pageSize, lastNewsId: newsId, block: { (result, error) in
                        let newsNew = self.reformer(news: result)
                        switch operation {
                        case .LoadNextPage where self.newsDatasource.count > 0:
                            self.newsDatasource += newsNew
                            let indexPaths = (self.newsDatasource.count-newsNew.count..<self.newsDatasource.count).map{ NSIndexPath(forRow: $0, inSection: 0) }
                            self.dataSourceNotification.1.sendNext(.InsertItemsAtIndexPaths(indexPaths, newsNew.count != pageSize))
                        default:
                            self.newsDatasource = newsNew
                            self.dataSourceNotification.1.sendNext(.ReloadData(newsNew.count != pageSize))
                        }
                        
                        observer.sendCompleted()
                    })
                }
                
                return nil
            })
        })
        
        return ac;
    }()
    

    func loadComments() -> Action<(Int), Int, NSError> {

        let ac = Action( { (index: Int) -> SignalProducer<Int, NSError> in
            
            return SignalProducer({ (observer: Observer<Int, NSError>, disposable: Disposable?) in
                let newsId = self.newsDatasource[index]["newsObjectId"] as! String
                NewsService.getComments(relatedToNews: newsId, limitNum: 3, block: { (comments, error) in
                    if error != nil {
                        observer.sendFailed(error!)
                    } else {
                        if self.newsDatasource[index]["newsObjectId"] as! String == newsId {
                            self.newsDatasource[index]["comments"] = self.reformer(comments: comments) ?? NSAttributedString()
                            observer.sendNext(index)
                        }
                        observer.sendCompleted()
                    }
                })
            })
        })
        
        return ac;
    }
    
    lazy var loadTopics : Action<(), [String]?, NSError> = {
        let ac = Action( { () -> SignalProducer<[String]?, NSError> in
            
            return SignalProducer({ (observer: Observer<[String]?, NSError>, disposable: Disposable?) in
                TopicService.getAllTopics { [weak self] (topics, error) in
                    
                    if error == nil {
                        self!.topiclist = topics
                        observer.sendNext(self?.topicNames)
                        observer.sendCompleted()
                    } else {
                        observer.sendFailed(error!)
                    }
                }
            })
        })
        
        return ac;
    }()
    
    // MARK: reformers
    
    func reformer(news newsArray: [News_Bmob]) -> [[String: AnyObject?]] {
        return newsArray.map({ (news) -> [String: AnyObject?] in

            var dic: [String: AnyObject?] = [:]
            
            dic["newsObjectId"] = news.objectId
            dic["newsId"] = news.newsId
            
            dic["authorAvatar"] = news.author.thumbURL
            dic["authorName"] = news.author.nickname
            dic["authorId"] = news.author.objectId
            dic["authorInfoId"] = news.author.info.objectId
            
            dic["viewsCount"] = String(news.viewsCount)
            dic["commentsCount"] = String(news.commentsCount)
            dic["shareCount"] = String(news.shareCount)
            dic["likesCount"] = String(news.likesCount)
            
            dic["date"] = news.createdAt
            dic["text"] = NSAttributedString(string: news.content ?? "🈳")
            dic["image"] = news.imageURL
            
            /**
             *  calculate the flag
             *      1. topicname
             *      2. tagname + maxcount
             */
            if type == 0 {
                dic["flag"] = news.topic.name
            } else {
                let tags = self.currentTagNames.filter{ HashTags.contains($0) }
                if tags.count > 0 {
                    if let tagCount = news.hashtagsCount?[tags[0]] {
                        dic["flag"] = ("#" + tags[0] + " " + String(tagCount))
                    }
                } else {
                    if let tuple = (news.hashtagsCount?.maxElement{ $0.1 < $1.1 }) {
                        dic["flag"] = ("#" + tuple.0 + " " + String(tuple.1))
                    }
                }
            }
            dic["comments"] = self.reformer(comments: news.comments)
            
            return dic
        })
    }
    
    func reformer(comments comments: [CommentModel]?) -> NSAttributedString? {

        if comments == nil || comments?.count <= 0 {
            return nil
        }
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .ByCharWrapping
        
        let commentsAttriString = NSMutableAttributedString()
        
        let darkgrey = UIColor(red: 97/255.0, green: 97/255.0, blue: 97/255.0, alpha: 1)
        let lightgrey = UIColor(red: 189/255.0, green: 189/255.0, blue: 189/255.0, alpha: 1)
        let font = UIFont.systemFontOfSize(14)
        
        let nameAttrs = [NSForegroundColorAttributeName : darkgrey,
                         NSFontAttributeName : font,]
        let commAttrs = [NSForegroundColorAttributeName : lightgrey,
                         NSFontAttributeName : font,]
        let tagsAttrs = [NSForegroundColorAttributeName : ThemeColor,
                         NSFontAttributeName : font,]
        
        for (index, comm) in comments!.enumerate() {
            commentsAttriString.appendAttributedString(NSAttributedString(string: comm.author!.nickname + " ", attributes: nameAttrs))
            commentsAttriString.appendAttributedString(NSAttributedString(string: comm.comment! + " ", attributes: commAttrs))
            
            if let tags = (comm.tags?.map{ "#"+$0 })?.joinWithSeparator(" ") {
                commentsAttriString.appendAttributedString(NSAttributedString(string: tags, attributes: tagsAttrs))
            }
            if index != comments!.count - 1 {
                commentsAttriString.appendAttributedString(NSAttributedString(string: "\n"))
            }
        }
        commentsAttriString.yy_paragraphStyle = paragraph
        
        return commentsAttriString
    }
}
