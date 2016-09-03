//
//  NewsCenterCell.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/7/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

import UIKit
import ChameleonFramework

let drawingOptions = NSStringDrawingOptions(rawValue: NSStringDrawingOptions.UsesLineFragmentOrigin.rawValue|NSStringDrawingOptions.UsesFontLeading.rawValue)


class NewsCenterCell: BaseActionCell {

    enum NewsCellAction: Int {
        case Comment = 1
        case Share
        case Like
        case Avatar
    }
    
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var viewedButton: UIButton!
    @IBOutlet weak var timeButton: UIButton!
    
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var contentImageView: UIImageView!
    
    @IBOutlet weak var commentsLabel: UILabel!
    
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var flagButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarButton.layer.cornerRadius = avatarButton.bounds.height/2
        avatarButton.clipsToBounds = true
        
        timeButton.setImageTintColor(ThemeColor, forState: .Normal)
        
        viewedButton.setImageTintColor(ThemeColor, forState: .Normal)
        contentImageView.backgroundColor = FlatWhite()
        contentImageView.clipsToBounds = true
    }

    override func configureCell(withBaseData data: [String : AnyObject?], collectionView: UICollectionView?, indexPath: NSIndexPath, delegate: CollectionCellAction?) {
        super.configureCell(withBaseData: data, collectionView: collectionView, indexPath: indexPath, delegate: delegate)

        commentsLabel.attributedText = data["comments"] as? NSAttributedString
        contentLabel.attributedText = data["text"] as? NSAttributedString
        
        let (prefix, postfix) = ("Comments", " (" + (data["commentsCount"] as! String) + ")")
        let attrComments = NSMutableAttributedString(string: prefix + postfix)
        
        attrComments.yy_setColor(UIColor.whiteColor(), range: NSMakeRange(0, prefix.characters.count))
        attrComments.yy_setColor(UIColor.whiteColor().colorWithAlphaComponent(0.7), range: NSMakeRange(prefix.characters.count, postfix.characters.count))
        commentButton.setAttributedTitle(attrComments, forState: .Normal)
        
        likeButton.setTitle((data["likesCount"] as! String) + " Likes", forState: .Normal)
        viewedButton.setTitle((data["viewsCount"] as! String), forState: .Normal)
        
        usernameLabel.text = data["authorName"] as? String
        timeButton.setTitle(DateHelper.timeAgo(data["date"] as? NSDate), forState: .Normal)
        
        let flag = (data["flag"] as? String)
        flagButton.hidden = flag?.characters.count <= 0
        if flag?.characters.count > 0 {
            flagButton.setTitle(flag, forState: .Normal)
        }
    }
    
    func configureCell(withRemoteOrLocalData data: [ String : AnyObject? ]) {
        self.contentImageView.contentMode = .Center
        contentImageView.sd_setImageWithURL(data["image"] as? NSURL, placeholderImage: ImagePlaceHolder) { (image, error, type, url) in
            if image != nil {
                self.contentImageView.contentMode = .ScaleAspectFill
            }
        }
        avatarButton.sd_setImageWithURL(data["authorAvatar"] as? NSURL, forState: .Normal, placeholderImage: AvatarPlaceHolder)
    }
    
    /**
       高度计算模型：  16 + 42 + 20 + textHeight + 10 + imageHeight + 14 + 36 + (14 + commentHeight) + 14
     - parameter data: cell的数据
     */
    static func heightFor(data: [ String : AnyObject? ]) -> CGFloat {
        var textHeight = CGFloat(0), imageHeight = CGFloat(0), commentHeight = CGFloat(0)
        
        if let text = data["text"] where (text as! NSAttributedString).length > 0 {
            textHeight = (text as! NSAttributedString).boundingRectWithSize(CGSizeMake(Main_Screen_Width-2*10, CGFloat.max), options: drawingOptions, context: nil).height
        }
        
        imageHeight = Main_Screen_Width * 210.0/375.0
        
        if let comments = data["comments"] where (comments as! NSAttributedString).length > 0 {
            commentHeight = (comments as! NSAttributedString).boundingRectWithSize(CGSizeMake(Main_Screen_Width-2*10, CGFloat.max), options: drawingOptions, context: nil).height + 14
        }
        
        return textHeight + imageHeight + commentHeight + 152
    }
    
    // MARK: Actions
    
    override func initializeViewTagAndReturnActionViews() -> [UIView] {
        shareButton.tag = NewsCenterCell.NewsCellAction.Share.rawValue
        likeButton.tag = NewsCenterCell.NewsCellAction.Like.rawValue
        commentButton.tag = NewsCenterCell.NewsCellAction.Comment.rawValue
        avatarButton.tag = NewsCenterCell.NewsCellAction.Avatar.rawValue
        
        return [avatarButton ,shareButton, likeButton, commentButton]
    }
}
