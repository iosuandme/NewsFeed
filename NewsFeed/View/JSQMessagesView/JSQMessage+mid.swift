//
//  JSQMessage+mid.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/16/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

import JSQMessagesViewController

extension JSQMessage {
    
    // MARK: Catagory Set/Get

    private struct AssociatedKeys {
        static var MessageIDName = "nf_MessageIDName"
        static var MessageStateName = "nf_MessageStateName"
    }
    
    var messageId: UInt? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.MessageIDName) as? UInt
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &AssociatedKeys.MessageIDName,
                    newValue as UInt?,
                    objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC
                )
            }
        }
    }
    
    var messageState: Int?  {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.MessageStateName) as? Int
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &AssociatedKeys.MessageStateName,
                    newValue as Int?,
                    objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC
                )
            }
        }
    }
}