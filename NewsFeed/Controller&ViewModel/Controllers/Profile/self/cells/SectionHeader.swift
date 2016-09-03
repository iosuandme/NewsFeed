//
//  SectionHeader.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/11/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

import UIKit
import UITintedButton
import ChameleonFramework

class SectionHeader: BaseActionReusableView {
    
    enum HeaderAction: Int {
        case GridLayout = 0, ListLayout
    }

    @IBOutlet weak var countNewsLabel: UILabel!
    @IBOutlet weak var gridStyleButton: UIButton!
    @IBOutlet weak var listStyleButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        listStyleButton.setImageTintColor(FlatWhiteDark(), forState: .Normal)
        listStyleButton.setImageTintColor(ThemeColor, forState: .Selected)
        gridStyleButton.setImageTintColor(FlatWhiteDark(), forState: .Normal)
        gridStyleButton.setImageTintColor(ThemeColor, forState: .Selected)
        
        gridStyleButton.selected = true
        
        backgroundColor = UIColor.lightGrayColor()
    }
    
    override func configureCell(withBaseData data: [String : AnyObject?], collectionView: UICollectionView?, indexPath: NSIndexPath, delegate: CollectionCellAction?) {
        super.configureCell(withBaseData: data, collectionView: collectionView, indexPath: SectionHeaderIndexPath(forSection: indexPath.section), delegate: delegate)
        
        countNewsLabel.text = ((data["count"] as? String) ?? "0") + " PHOTOS"
    }
    
    override func updateCell(withBaseData data: [String : AnyObject?]) {
        countNewsLabel.text = ((data["count"] as? String) ?? "0") + " PHOTOS"
    }
    
    override func initializeViewTagAndReturnActionViews() -> [UIView] {
        gridStyleButton.tag = HeaderAction.GridLayout.rawValue
        listStyleButton.tag = HeaderAction.ListLayout.rawValue
        
        return [gridStyleButton, listStyleButton]
    }
}
