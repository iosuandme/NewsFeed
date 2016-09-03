//
//  MessageContent+Bmob.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/16/16.
//  Copyright © 2016 Kidney. All rights reserved.
//


class MessageContent_Bmob: BmobObject {

    enum MessageContentType: UInt {
        case Text           = 0
        case Image
        case TextImage
        case TextImageLink
        case NewsRelated    = 999
    }
    /**
     *  0 text
     *  1 image
     *  2 text+image
     *  3 text+image+link
     */

    var content_type = MessageContentType.Text
    var text: String?
    var image: BmobFile?
    var imageURL: NSURL? {
        if image == nil {
            return nil
        }
        return image!.url.hasPrefix("http://") ? NSURL(string: image!.url) : NSURL(fileURLWithPath: image!.url)
    }
    var linkURL: NSURL? = nil
    var newsRelated: News_Bmob? = nil
    
    static func convert(obj: BmobObject) -> MessageContent_Bmob{
        let content = MessageContent_Bmob.convertWithObject(obj)
        
        //不支持转化Bool，Int，Float类型,所以 需要手动设置
        if let content_type = obj.objectForKey("content_type") {
            content.content_type = MessageContentType(rawValue: content_type as! UInt)!
        }
        
        if let image = obj.objectForKey("image") {
            content.image = image as? BmobFile
        }
        
        if let link = obj.objectForKey("link") {
            content.linkURL = NSURL(string: link as! String)
        }
        
        if let newsRelated = obj.objectForKey("newsRelated") {
            content.newsRelated = News_Bmob.convert(newsRelated as! BmobObject)
        }
        
        return content
    }
    
    override func sub_saveInBackgroundWithResultBlock(block: BmobBooleanResultBlock!) {
        //转化后的表名有问题，需要手动设置
        self.className = "MessageContent"
        
        //不支持转化Bool，Int，Float类型,所以 需要手动设置
        self.setObject(content_type.rawValue, forKey: "content_type")
        
        super.sub_saveInBackgroundWithResultBlock(block)
    }
    
}
