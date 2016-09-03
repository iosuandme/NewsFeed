//
//  JSQMessagesCollectionViewCell+statebutton.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/22/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

import Foundation
import JSQMessagesViewController
import Aspects
import SnapKit
import ChameleonFramework

protocol JSQCellState {
    func update(state: Message_Bmob.MessageState) -> Void
}

extension JSQMessagesCollectionViewCell {
    
    // MARK: Catagory Set/Get
    
    private struct AssociatedKeys {
        static var StateButtonName = "nf_StateButton"
    }
    
    var stateButton: UIButton? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.StateButtonName) as? UIButton
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &AssociatedKeys.StateButtonName,
                    newValue as UIButton?,
                    objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }
    
}

extension JSQMessagesCollectionViewCellOutgoing: JSQCellState {
    override public static func initialize() {
        
        let wrappedBlock:@convention(block) (AspectInfo)->Void = { (info) in
            
            if let cell = info.instance() as? JSQMessagesCollectionViewCell {
                if cell.stateButton == nil {
                    cell.stateButton = UIButton(type: .Custom)
                    
                    cell.stateButton?.layer.cornerRadius = 3
                    cell.stateButton?.contentEdgeInsets = UIEdgeInsetsMake(2, 4, 2, 4)
                    cell.stateButton?.titleLabel?.font = UIFont.systemFontOfSize(10)
                    cell.stateButton?.setTitleColor(UIColor.whiteColor(), forState: .Disabled)
                    cell.stateButton?.enabled = false
                    
                    cell.messageBubbleContainerView.superview?.addSubview(cell.stateButton!)
                    cell.stateButton?.snp_makeConstraints(closure: { (make) in
                        make.centerY.equalTo(cell.messageBubbleContainerView)
                        make.trailing.equalTo(cell.messageBubbleContainerView.snp_leading).offset(-4)
                    })
                }
            }
            
        }
        let wrappedObject: AnyObject = unsafeBitCast(wrappedBlock, AnyObject.self)
        
        do {
            try JSQMessagesCollectionViewCellOutgoing.aspect_hookSelector(#selector(JSQMessagesCollectionViewCellOutgoing.awakeFromNib), withOptions: .PositionAfter, usingBlock: wrappedObject)
        } catch {
            
        }
        
    }
    
    // MARK: JSQMediaItemStateProtocol
    
    func update(state: Message_Bmob.MessageState) {

        // title
        switch state {
        case .Initialed:
            stateButton?.setTitle("initialed", forState: .Disabled)
        case .FailedSend: fallthrough
        case .FailedUpload:
            stateButton?.setTitle("failed", forState: .Disabled)
        case let .SendingUploading(progress):
            stateButton?.setTitle("uploading " + String(Int(progress*100)) + "%", forState: .Disabled)
        case .Sending:
            stateButton?.setTitle("sending", forState: .Disabled)
        case .Sended:
            stateButton?.setTitle("sended", forState: .Disabled)
        case .Achieved:
            stateButton?.setTitle("achieved", forState: .Disabled)
        case .Readed:
            stateButton?.setTitle("readed", forState: .Disabled)
        default:
            break
        }
        
        // background
        switch state {
        
        case .FailedSend: fallthrough
        case .FailedUpload:
            stateButton?.backgroundColor = FlatRed()
            
        case .Initialed: fallthrough
        case .SendingUploading: fallthrough
        case .Sending:
            stateButton?.backgroundColor = FlatOrange()
            
        case .Sended: fallthrough
        case .Achieved:
            stateButton?.backgroundColor = FlatWhiteDark()
            
        case .Readed:
            stateButton?.backgroundColor = FlatGreenDark()
        default:
            break
        }
    }
}