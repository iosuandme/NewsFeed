//
//  CollectionCellAction.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/21/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

import Foundation
import BlocksKit

protocol CollectionCellAction: NSObjectProtocol {
    func collectionView(collectionView: UICollectionView, didTriggerAction: Int, atIndexPath indexPath: NSIndexPath)
    
}

protocol BaseCollectionReusableViewProtocol: NSObjectProtocol {
    weak var collectionView: UICollectionView?  { get set }
    weak var delegate: CollectionCellAction?    { get set }
    var indexPath: NSIndexPath!                 { get set }
    
    func configureCell(withBaseData data: [ String : AnyObject? ], collectionView: UICollectionView?, indexPath: NSIndexPath, delegate: CollectionCellAction?)
    func updateCell(withBaseData data: [ String : AnyObject? ])
    
    func initializeViewTagAndReturnActionViews() -> [UIView]
}

class BaseActionReusableView: UICollectionReusableView, BaseCollectionReusableViewProtocol {
    
    weak var collectionView: UICollectionView?
    weak var delegate: CollectionCellAction?
    var indexPath: NSIndexPath!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let views = initializeViewTagAndReturnActionViews()
        for acView in views {
            if let btn = acView as? UIButton {
                btn.bk_addEventHandler({ [weak self] (button) in
                    if self != nil && self!.delegate != nil && self!.collectionView != nil {
                        self!.delegate?.collectionView(self!.collectionView!, didTriggerAction: (button as! UIButton).tag, atIndexPath: self!.indexPath)
                    }
                    }, forControlEvents: .TouchUpInside)
            } else {
                acView.bk_whenTapped({ [weak self] in
                    if self != nil && self!.delegate != nil && self!.collectionView != nil {
                        self!.delegate?.collectionView(self!.collectionView!, didTriggerAction: acView.tag, atIndexPath: self!.indexPath)
                    }
                    })
            }
        }
    }
    
    func configureCell(withBaseData data: [ String : AnyObject? ], collectionView: UICollectionView?, indexPath: NSIndexPath, delegate: CollectionCellAction?) {
        
        self.collectionView = collectionView
        self.indexPath = indexPath
        self.delegate = delegate

    }
    
    func updateCell(withBaseData data: [String : AnyObject?]) {
        
    }
    
    func initializeViewTagAndReturnActionViews() -> [UIView] {
        return []
    }
}

class BaseActionCell: UICollectionViewCell, BaseCollectionReusableViewProtocol {
    
    weak var collectionView: UICollectionView?
    weak var delegate: CollectionCellAction?
    var indexPath: NSIndexPath!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let views = initializeViewTagAndReturnActionViews()
        for acView in views {
            if let btn = acView as? UIButton {
                btn.bk_addEventHandler({ [weak self] (button) in
                    if self != nil && self!.delegate != nil && self!.collectionView != nil {
                        self!.delegate?.collectionView(self!.collectionView!, didTriggerAction: (button as! UIButton).tag, atIndexPath: self!.indexPath)
                    }
                }, forControlEvents: .TouchUpInside)
            } else {
                acView.bk_whenTapped({ [weak self] in
                    if self != nil && self!.delegate != nil && self!.collectionView != nil {
                        self!.delegate?.collectionView(self!.collectionView!, didTriggerAction: acView.tag, atIndexPath: self!.indexPath)
                    }
                })
            }
        }
    }
    
    func configureCell(withBaseData data: [ String : AnyObject? ], collectionView: UICollectionView?, indexPath: NSIndexPath, delegate: CollectionCellAction?) {
        
        self.collectionView = collectionView
        self.indexPath = indexPath
        self.delegate = delegate
        
    }
    
    func updateCell(withBaseData data: [String : AnyObject?]) {
        
    }
    
    func initializeViewTagAndReturnActionViews() -> [UIView] {
        return []
    }
}