//
//  OtherProfileCell.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/7/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

import YYText



class OtherProfileCell: BaseActionCell {

    enum CellAction: Int {
        case Comment = 1
        case Share
        case Like
    }
    
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var viewedButton: UIButton!
    @IBOutlet weak var timeButton: UIButton!
    
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var contentImageView: UIImageView!
    
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarButton.layer.cornerRadius = avatarButton.bounds.height/2
        avatarButton.clipsToBounds = true
    }
    
    override func configureCell(withBaseData data: [String : AnyObject?], collectionView: UICollectionView?, indexPath: NSIndexPath, delegate: CollectionCellAction?) {
        super.configureCell(withBaseData: data, collectionView: collectionView, indexPath: indexPath, delegate: delegate)
        
        contentLabel.attributedText = data["text"] as? NSAttributedString
        
        let (prefix, postfix) = ("Comments", " (" + (data["commentsCount"] as! String) + ")")
        let attrComments = NSMutableAttributedString(string: prefix + postfix)
        
        attrComments.yy_setColor(UIColor(red: 78.0/255, green: 78.0/255, blue: 78.0/255, alpha: 1), range: NSMakeRange(0, prefix.characters.count))
        attrComments.yy_setColor(UIColor(red: 179.0/255, green: 180.0/255, blue: 180.0/255, alpha: 1), range: NSMakeRange(prefix.characters.count, postfix.characters.count))
        commentButton.setAttributedTitle(attrComments, forState: .Normal)
        
        likeButton.setTitle((data["likesCount"] as! String) + " Likes", forState: .Normal)
        viewedButton.setTitle((data["viewsCount"] as! String), forState: .Normal)
        
        usernameLabel.text = data["authorName"] as? String
        timeButton.setTitle(DateHelper.timeAgo(data["date"] as? NSDate), forState: .Normal)
    }
    
    func configureCell(withRemoteOrLocalData data: [ String : AnyObject? ]) {
        
        contentImageView.sd_setImageWithURL(data["image"] as? NSURL, placeholderImage: ImagePlaceHolder)
        avatarButton.sd_setImageWithURL(data["authorAvatar"] as? NSURL, forState: .Normal, placeholderImage: AvatarPlaceHolder)
    }
    
    /**
     高度计算模型：  16 + 42 + 20 + textHeight + 10 + imageHeight + 14 + 36 + 16
     - parameter data: cell的数据
     */
    static func heightFor(data: [ String : AnyObject? ]) -> CGFloat {
        var textHeight = CGFloat(0), imageHeight = CGFloat(0)
        
        if let text = data["text"] where (text as! NSAttributedString).length > 0 {
            textHeight = (text as! NSAttributedString).boundingRectWithSize(CGSizeMake(Main_Screen_Width-2*10, CGFloat.max), options: drawingOptions, context: nil).height
        }
        
        imageHeight = (Main_Screen_Width - 2 * 10) * 178.0/348.0
        
        return textHeight + imageHeight + 154.0
    }
    
    // MARK: Actions
    
    override func initializeViewTagAndReturnActionViews() -> [UIView] {
        shareButton.tag = CellAction.Share.rawValue
        likeButton.tag = CellAction.Like.rawValue
        commentButton.tag = CellAction.Comment.rawValue
        
        return [shareButton, likeButton, commentButton]
    }
}
