//
//  SelectTopicsViewModel.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/22/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

import ReactiveCocoa

class SelectTopicsViewModel: NSObject {

    var topiclist: [Topic_Bmob] = [] {
        didSet {
            searchResult = topiclist
        }
    }
    
    var searchResult: [Topic_Bmob] = [] {
        didSet {
            topiclistForView = searchResult.map({ (topic) -> [String: AnyObject?] in
                return ["name" : topic.name,
                    "image" : topic.imageURL]
            })
            let set = Set(searchResult.map{ return $0.objectId })
            likedIds = likedIds.intersect(set)
        }
    }
    
    var topiclistForView: [[String:AnyObject?]] = []
    var likedIds: Set<String> = []
    
    lazy var searchTopics : Action<String?, Int, NSError> = {
        
        if self.topiclist.count > 0 {
            
        }
        
        let ac = Action( { (name: String?) -> SignalProducer<Int, NSError> in
            
            return SignalProducer({ (observer: Observer<Int, NSError>, disposable: Disposable?) in
                if self.topiclist.count > 0 {
                    
                    self.searchResult = self.topiclist.filter { return name?.characters.count == 0 ? true : $0.name.uppercaseString.containsString(name!.uppercaseString) }
                    observer.sendCompleted()
                } else {
                    TopicService.searchTopic(byName: name, block: { (result, error) in
                        if error != nil {
                            observer.sendFailed(error!)
                        } else {
                            self.topiclist = result
                            
                            TopicService.getLikedTopicIds(nil, block: { (likeIds, error2) in
                                if error2 != nil {
                                    observer.sendFailed(error2!)
                                } else {
                                    self.likedIds = Set(likeIds)
                                    observer.sendCompleted()
                                }
                            })
                        }
                        
                    })
                }
            })
        })
        
        return ac;
        
    }()
    
    func likeTopics(indexesSelected: [Int]?, block: BmobBooleanResultBlock?) {
        let user = BmobUser.currentUser()
        let relation = BmobRelation()
        let relation2 = BmobRelation()
        

        for top in topiclist {
            
            let obj = BmobObject(outDataWithClassName: "Topic", objectId: top.objectId)
            if likedIds.contains(top.objectId) {
                relation.addObject(obj)
            } else {
                relation2.removeObject(obj)
            }
        }
        
        user.addRelation(relation, forKey: "topicsLiked")
        user.setObject(true, forKey: "hasSelectedTopics")
        user.updateInBackgroundWithResultBlock { (isSuccess, error) in
            if isSuccess {
                user.addRelation(relation2, forKey: "topicsLiked")
                user.updateInBackgroundWithResultBlock({ (isSuccess2, error2) in
                    block?(isSuccess2, error2)
                })
            } else {
                block?(false, error)
            }
        }

    }
}
