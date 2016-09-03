
//
//  NotificationViewModel.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/22/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

import ReactiveCocoa
import YYText

class NotificationViewModel: NSObject {
    
    let dataSourceNotification: (Signal<DataSourceNotificationType, NSError>, Observer<DataSourceNotificationType, NSError>) = Signal.pipe()
    private(set) var messagesForView: [[String:AnyObject!]] = []
    
    // Mark: load more notifications
    lazy var loadNextPageAction : Action<DataSourceOperationType, Int, NSError> = {
        let pageSize = 10
        let ac = Action( { (operation: DataSourceOperationType) -> SignalProducer<Int, NSError> in
            return SignalProducer(signal: Signal {[unowned self] (observer: Observer<Int, NSError>) -> Disposable? in
                
                MessageSearcher.getMessages(.All, earlierThanLastMessageId: self.messagesForView.last?["id"] as? UInt, pageSize: pageSize, block: { (result, error) in
                    if error != nil {
                        observer.sendFailed(error!)
                    } else {
                        let notisNew = self.reformer(messages: result)
                        switch operation {
                        case .LoadNextPage where self.messagesForView.count > 0:
                            self.messagesForView += notisNew
                            
                            let indexPaths = (self.messagesForView.count-notisNew.count..<self.messagesForView.count).map{ NSIndexPath(forRow: $0, inSection: 0) }
                            self.dataSourceNotification.1.sendNext(.InsertItemsAtIndexPaths(indexPaths, notisNew.count != pageSize))
                        default:
                            self.messagesForView = notisNew
                            self.dataSourceNotification.1.sendNext(.ReloadData(notisNew.count != pageSize))
                        }
                        observer.sendCompleted()
                    }
                })
                
                return nil
            })
        })
        
        return ac;
        
    }()
    
    func didSelectCell(atIndexPath indexPath: NSIndexPath) {
        
        let msg = messagesForView[indexPath.row]
        switch Message_Bmob.MessageType(rawValue: msg["type"] as! Int)! {
        case .Message:
            PageRouter.showChatRoom(forUser: msg["senderId"] as! String, nickname: msg["senderName"] as! String, avatarURL: msg["senderAvatar"] as? NSURL)
        
        case .Follow: fallthrough
        case .Unfollow: fallthrough
        case .Comment: fallthrough
        case .Retweet: fallthrough
        case .Like:
            PageRouter.showNewsDetail(forNews: msg["newsRelated"] as! String)
        case .All:
            break
        }
    }

    func reformer(messages messages: [Message_Bmob]) -> [[String:AnyObject!]] {
        let darkgrey = UIColor(red: 97/255.0, green: 97/255.0, blue: 97/255.0, alpha: 1)
        let namefont = UIFont.systemFontOfSize(16)
        let descfont = UIFont.systemFontOfSize(14, weight: UIFontWeightThin)
        
        let nameAttrs = [NSForegroundColorAttributeName : ThemeColor,
                         NSFontAttributeName : namefont,]
        let descAttrs = [NSForegroundColorAttributeName : darkgrey,
                         NSFontAttributeName : descfont,]
        
        return messages.map { message -> [String : AnyObject!] in
            let imageNames = ["message_notification",
                "follow_notification",
                "unfollow_notification",
                "comment_notification",
                "retweeted_notification"]
            let imageURLs = imageNames.map{ name in FileHelper.getImagePath(name) }
            
            var (image, mode): (NSURL!, UIViewContentMode)
            if message.message_type == Message_Bmob.MessageType.Like {
                image = message.content?.newsRelated?.thumbURL
                mode = UIViewContentMode.ScaleToFill
            } else {
                image = imageURLs[message.message_type.rawValue]
                mode = UIViewContentMode.Center
            }
            
            let desc = " "+MessageService.getDescriptionPostfix(message.message_type)
            let attredText = NSMutableAttributedString()
            attredText.appendAttributedString(NSAttributedString(string: message.sender.nickname, attributes: nameAttrs))
            attredText.appendAttributedString(NSAttributedString(string: desc, attributes: descAttrs))
            
            return [
                "id": message.messageId!,
                "type": message.message_type.rawValue,
                
                "senderId": message.sender.objectId,
                "senderName": message.sender.nickname,
                "senderAvatar": message.sender.thumbURL,
                
                "newsRelated": message.content?.newsRelated?.objectId,
                
                "text": attredText,
                "date": message.createdAt,
                "image": image,
                "mode": mode.rawValue,
            ]
        }
    }
}
