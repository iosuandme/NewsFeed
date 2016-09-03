//
//  SelfProfile.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/11/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Result

class ProfileViewModel: NSObject {
    
    let dataSourceNotification: (Signal<DataSourceNotificationType, NSError>, Observer<DataSourceNotificationType, NSError>) = Signal.pipe()
    var dataSource: [[String : AnyObject!]] = []
    
    private(set) var user: User_Bmob!
    
    lazy var userInfo: AnyProperty<Dictionary<String, AnyObject>> = {
        return DynamicProperty(object: self, keyPath: "user").map { (value) -> Dictionary<String, AnyObject> in
            var dic: [String: AnyObject] = [:]
            
            if let bmobUser = value as? User_Bmob  {
                if bmobUser.nickname != nil {
                    dic["avatar"] = bmobUser.imageURL
                    dic["name"] = bmobUser.nickname
                    dic["profession"]  = bmobUser.profession
                    dic["followed"] = (bmobUser.info.follow ?? .NotFollowedByMe).rawValue
                    
                    dic["statics"] = [String(bmobUser.info.postsCount),
                        String(bmobUser.info.followersCount),
                        String(bmobUser.info.followingsCount),
                        String(bmobUser.info.likesCount),
                    ]
                    dic["count"] = String(bmobUser.info.postsCount)
                }
            }
            
            return dic
        }
    }()
    
    required override init() {
        super.init()
        
    }
    
    convenience init(user: User_Bmob?) {
        self.init()

        self.user = user ?? User_Bmob.currentUser()
    }
    
    // MARK: actions
    
    func refreshModel() {
        UserService.getInfo(ofUser: self.user.objectId, userInfoId: self.user.info.objectId) { (result, error) in
            if error == nil {
                self.setValue(result, forKey: "user")
            }
        }
        
    }
    
    lazy var dataSourceOperation : Action<DataSourceOperationType, (Bool, Int), NSError> = {
        let pageSize = 9
        return Action { (operation: DataSourceOperationType) -> SignalProducer<(Bool, Int), NSError> in
            return SignalProducer { (observer: Observer<(Bool, Int), NSError>, disposable: Disposable?) in
                
                switch operation {
                case .LoadNextPage:
                    NewsService.getNews(pageSize, boundary: self.dataSource.last!["newsId"] as? UInt, ofUser: self.user.objectId, earlier: true, block: { (result, error) in
                        let newsNew = self.reformer(news: result)
                        self.dataSource += newsNew
                        let indexPaths = (self.dataSource.count-newsNew.count..<self.dataSource.count).map{ NSIndexPath(forRow: $0, inSection: 0) }
                        self.dataSourceNotification.1.sendNext(.InsertItemsAtIndexPaths(indexPaths, newsNew.count != pageSize))
                        
                        observer.sendCompleted()
                    })
                case .LoadLatest:
                    NewsService.getNews(pageSize, boundary: self.dataSource.first!["newsId"] as? UInt, ofUser: self.user.objectId, earlier: false, block: { (result, error) in
                        let newsNew = self.reformer(news: result)
                        
                        self.dataSource = newsNew + self.dataSource
                        let indexPaths = (0..<newsNew.count).map{ NSIndexPath(forRow: $0, inSection: 0) }
                        self.dataSourceNotification.1.sendNext(.InsertItemsAtIndexPaths(indexPaths, false))
                        
                        observer.sendCompleted()
                    })
                case let .ReloadVisible(indexes):
                    let (id1, id2) = (indexes.first!.row, indexes.last!.row)
                    let (minIndex, maxIndex) = (min(id1, id2), max(id1, id2))
                    let (minNewsId, maxNewsId) = (self.dataSource[maxIndex]["newsId"] as! UInt, self.dataSource[minIndex]["newsId"] as! UInt)
                    NewsService.getNews(minNewsId, maxNewsId: maxNewsId, relatedToTopicId: nil, tags: [], ofUser: self.user.objectId, block: { (result, error) in
                        if error == nil {
                            self.dataSource.replaceRange(minIndex...maxIndex, with: self.reformer(news: result))
                            self.dataSourceNotification.1.sendNext(.ReloadItemsAtIndexPaths(indexes))
                            observer.sendCompleted()
                        } else {
                            observer.sendFailed(error!)
                        }
                    })
                default:
                    NewsService.getNews(pageSize, boundary: nil, ofUser: self.user.objectId, earlier: true, block: { (result, error) in
                        let newsNew = self.reformer(news: result)
                        self.dataSource = newsNew
                        self.dataSourceNotification.1.sendNext(.ReloadData(newsNew.count != pageSize))
                        
                        observer.sendCompleted()
                    })
                }
            }
        }
    }()
    
    lazy var followAction : Action<(), (), NSError> = {
        return Action( { (_) -> SignalProducer<(), NSError> in
            
            return SignalProducer({ (observer: Observer<(), NSError>, disposable: Disposable?) in
                UserService.toggleFollow(toUser: self.user, block: { (isFollowing, error) in
                    if error != nil {
                        observer.sendFailed(error!)
                    } else {
                        self.user.info.follow = isFollowing ? .FollowedByMe : .NotFollowedByMe
                        if isFollowing {
                            self.user.info.followersCount? += 1
                        } else {
                            self.user.info.followersCount? -= 1
                        }
                        self.setValue(self.user, forKey: "user")    // trigger kvo
                        observer.sendCompleted()
                    }
                })
            })
        })
    }()
    
    lazy var likeNewsAction : Action<Int, Int, NSError> = {
        return Action( { (index: Int) -> SignalProducer<Int, NSError> in
            
            return SignalProducer({ (observer: Observer<Int, NSError>, disposable: Disposable?) in
                
                let (newsId, authorId, infoId) = (self.dataSource[index]["newsObjectId"] as! String,
                    self.dataSource[index]["authorId"] as! String,
                    self.dataSource[index]["authorInfoId"] as! String
                )
                NewsService.likeNews(newsId, authorId: authorId, authorInfoId: infoId, block: { [weak self] (success, error) in
                    if error != nil {
                        observer.sendFailed(error!)
                    } else {
                        if let strongSelf = self {
                            strongSelf.user.info.likesCount! += 1
                            strongSelf.setValue(strongSelf.user, forKey: "user")    // trigger kvo
                            observer.sendCompleted()
                        } else {
                            observer.sendFailed(DeallocError)
                        }
                    }
                    })
            })
        })
    }()
    
    lazy var showNewsDetail : Action<Int, (), NoError> = {
        return Action( { (index: Int) -> SignalProducer<(), NoError> in
            
            return SignalProducer({ (observer: Observer<(), NoError>, disposable: Disposable?) in
                PageRouter.showNewsDetail(forNews: self.dataSource[index]["newsObjectId"] as! String)
                observer.sendCompleted()
            })
        })
    }()
    
    func showCommentPage(forNewsAtIndexPath indexPath: NSIndexPath?) {
        if indexPath != nil {
            let news = self.dataSource[indexPath!.row]
            PageRouter.showCommentPage(forNews: news["newsObjectId"] as! String, authorId: news["authorId"] as! String)
        }
    }
    
    func reformer(news list: [News_Bmob]) -> [[String: AnyObject!]] {
        return list.map({ (news) -> [String: AnyObject!] in
            
            var dic: [String: AnyObject!] = [:]
            
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
            dic["comments"] = NSAttributedString(string: "")
            dic["image"] = news.imageURL
            
            return dic
        })
    }
}