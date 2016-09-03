//
//  EmptyListStyle.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/25/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

import DZNEmptyDataSet
import ChameleonFramework
import MJRefresh

enum EmptyImageType: String {
    case AddNews = "news_publish"
    case NoNotification = "empty_message"
}

protocol SVLEmptyListDelegate: NSObjectProtocol {
    func configurationsForEmpty() -> (image: EmptyImageType, title: String?, description: String?, buttonTitle: String?, didTapButton: (()->Void)?)
}

class EmptyListStyle: NSObject, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    weak var delegate: SVLEmptyListDelegate!
    
    init(withScrollView scrollView: UIScrollView, delegate: SVLEmptyListDelegate) {
        super.init()
        
        self.delegate = delegate
        
        scrollView.emptyDataSetSource = self
        scrollView.emptyDataSetDelegate = self
    }
    
    // MARK: Customizable part Of empty style
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: delegate.configurationsForEmpty().image.rawValue)
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        
        if let title = delegate.configurationsForEmpty().title {
            
            let attributes = [NSFontAttributeName: UIFont.boldSystemFontOfSize(16),
                              NSForegroundColorAttributeName: UIColor.darkGrayColor()];
            return NSAttributedString(string: title, attributes: attributes)
        }
        
        return nil
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        
        if let description = delegate.configurationsForEmpty().description {
            
            let paragraph = NSMutableParagraphStyle()
            paragraph.lineBreakMode = .ByWordWrapping
            paragraph.alignment = .Center
            
            let attributes = [NSFontAttributeName: UIFont.systemFontOfSize(13),
                              NSForegroundColorAttributeName: UIColor.lightGrayColor(),
                              NSParagraphStyleAttributeName: paragraph];
            return NSAttributedString(string: description, attributes: attributes)
        }
        
        return nil
    }
    
    func buttonTitleForEmptyDataSet(scrollView: UIScrollView!, forState state: UIControlState) -> NSAttributedString! {
        
        if let title = delegate.configurationsForEmpty().buttonTitle {
            
            let attributes: [String : AnyObject] = [NSFontAttributeName: UIFont.boldSystemFontOfSize(16),
                                                    NSUnderlineStyleAttributeName : NSUnderlineStyle.StyleSingle.rawValue | NSUnderlineStyle.PatternSolid.rawValue,
                                                    NSForegroundColorAttributeName : ThemeColor]
            return NSAttributedString(string: title, attributes: attributes)
        }
        
        return nil
    }
    
    func emptyDataSetDidTapButton(scrollView: UIScrollView!) {
        delegate.configurationsForEmpty().didTapButton?()
    }
    
    // MARK: stationary part of empty style
    
    func imageTintColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
        return UIColor.darkGrayColor()
    }
    
    func backgroundColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
        return UIColor(red: 252/255.0, green: 252/255.0, blue: 250/255.0, alpha: 1)
    }
    
    func emptyDataSetWillAppear(scrollView: UIScrollView!) {
        scrollView.contentSize = scrollView.bounds.size
        scrollView.mj_footer.hidden = true
    }
    
    func emptyDataSetWillDisappear(scrollView: UIScrollView!) {
        scrollView.mj_footer.hidden = false
    }
}
