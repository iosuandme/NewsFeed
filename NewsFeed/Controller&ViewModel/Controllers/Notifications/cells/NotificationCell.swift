//
//  NotificationCell.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/22/16.
//  Copyright © 2016 Kidney. All rights reserved.
//



class NotificationCell: BaseActionCell {

    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var typeImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarButton.layer.cornerRadius = avatarButton.bounds.height/2
        avatarButton.clipsToBounds = true
    }
    
    override func configureCell(withBaseData data: [String : AnyObject?], collectionView: UICollectionView?, indexPath: NSIndexPath, delegate: CollectionCellAction?) {
        super.configureCell(withBaseData: data, collectionView: collectionView, indexPath: indexPath, delegate: delegate)
        
        avatarButton.sd_setImageWithURL(data["senderAvatar"] as? NSURL, forState: .Normal, placeholderImage: AvatarPlaceHolder)
        typeImageView.sd_setImageWithURL(data["image"] as? NSURL, placeholderImage: ImagePlaceHolder)
        typeImageView.contentMode = UIViewContentMode(rawValue: (data["mode"] as! Int)) ?? .ScaleToFill
        
        descriptionLabel.attributedText = data["text"] as? NSAttributedString
        dateLabel.text = DateHelper.timeAgo(data["date"] as? NSDate)
    }
    
}
