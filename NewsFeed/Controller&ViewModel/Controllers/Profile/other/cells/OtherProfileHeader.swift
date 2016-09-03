//
//  OtherProfileHeader.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/7/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

import UIKit
import JazzHands

class OtherProfileHeader: BaseActionReusableView {

    enum CellAction: Int {
        case Menu = 1, Search, More, Follow
    }
    
    @IBOutlet weak var backImageView: UIImageView!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var professionLabel: UILabel!
    
    @IBOutlet var staticsLabels: [UILabel]!
    
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var followingButton: UIButton!
    
    // for animations
    var animator = IFTTTAnimator()
    var link: CADisplayLink?
    @IBOutlet weak var avatarWidth: NSLayoutConstraint!
    @IBOutlet weak var backImageHeight: NSLayoutConstraint!
    @IBOutlet weak var nameTopMargin: NSLayoutConstraint!
    @IBOutlet weak var nameRightMargin: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.height/2
        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.borderColor = UIColor.whiteColor().CGColor
        avatarImageView.layer.borderWidth = 5
        avatarImageView.backgroundColor = UIColor.whiteColor()
        
        addAnimations()
    }
    
    override func configureCell(withBaseData data: [String : AnyObject?], collectionView: UICollectionView?, indexPath: NSIndexPath, delegate: CollectionCellAction?) {
        super.configureCell(withBaseData: data, collectionView: collectionView, indexPath: indexPath, delegate: delegate)
        
        updateCell(withBaseData: data)
        
        if link == nil {
            link = CADisplayLink(target: self, selector: #selector(SelfProfileHeader.updatePosition))
            link?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: UITrackingRunLoopMode)
        }
    }
    
    override func updateCell(withBaseData data: [String : AnyObject?]) {
        let statics = data["statics"] as? [String]
        for (index, label) in staticsLabels.enumerate() {
            if index < statics?.count {
                label.text = statics![index]
            } else {
                break
            }
        }
        
        avatarImageView.sd_setImageWithURL(data["avatar"] as? NSURL, placeholderImage: AvatarPlaceHolder)
        nameLabel.text = data["name"] as? String ?? "Loading..."
        professionLabel.text = data["profession"] as? String ?? "Loading..."
        
        let followed = (data["followed"] as? Int ) ?? 0
        switch UserAdditionalInfo.FollowState(rawValue: followed)! {
        case .NotFollowedByMe:
            followingButton.setTitle("Follow", forState: .Normal)
            followingButton.enabled = true
        case .FollowedByMe:
            followingButton.setTitle("Following", forState: .Normal)
            followingButton.enabled = true
        case .IsMe:
            followingButton.setTitle("Me", forState: .Disabled)
            followingButton.enabled = false
        }
    }
    
    override func initializeViewTagAndReturnActionViews() -> [UIView] {
        menuButton.tag = CellAction.Menu.rawValue
        searchButton.tag = CellAction.Search.rawValue
        moreButton.tag = CellAction.More.rawValue
        followingButton.tag = CellAction.Follow.rawValue
        
        return [menuButton ,searchButton, moreButton, followingButton]
    }
    
    // MARK: Animation
    
    func addAnimations() -> Void {
        let nameTopMarginAnimation = IFTTTConstraintConstantAnimation(superview: nameLabel.superview, constraint: nameTopMargin)
        nameTopMarginAnimation.addKeyframeForTime(464, constant: 87)
        nameTopMarginAnimation.addKeyframeForTime(64, constant: 23.5)
        
        let nameRightMarginAnimation = IFTTTConstraintConstantAnimation(superview: nameLabel.superview, constraint: nameRightMargin)
        nameRightMarginAnimation.addKeyframeForTime(464, constant: -88)
        nameRightMarginAnimation.addKeyframeForTime(128, constant: 0)
        
        let avatarSizeAnimation = IFTTTConstraintConstantAnimation(superview: avatarImageView.superview, constraint: avatarWidth)
        avatarSizeAnimation.addKeyframeForTime(64, constant: 44)
        avatarSizeAnimation.addKeyframeForTime(464, constant: 170)
        avatarSizeAnimation.addKeyframeForTime(1000, constant: 1000-(464-170))
        
        let backImageHeightAnimation = IFTTTConstraintConstantAnimation(superview: backImageView.superview, constraint: backImageHeight)
        backImageHeightAnimation.addKeyframeForTime(64, constant: 164-(87-23.5)+22)
        backImageHeightAnimation.addKeyframeForTime(464, constant: 250)
        backImageHeightAnimation.addKeyframeForTime(1000, constant: 1000-(464-250))
        
        let cornerRadiusAnimation = IFTTTCornerRadiusAnimation(view: avatarImageView)
        cornerRadiusAnimation.addKeyframeForTime(64, cornerRadius: 22)
        cornerRadiusAnimation.addKeyframeForTime(464, cornerRadius: 85)
        cornerRadiusAnimation.addKeyframeForTime(1000, cornerRadius: (1000.0-(464-170))/2)
        
        let topViewBackColorAnimation = IFTTTBackgroundColorAnimation(view: menuButton.superview!)
        topViewBackColorAnimation.addKeyframeForTime(88, color: ThemeColor)
        topViewBackColorAnimation.addKeyframeForTime(88*2, color: UIColor.clearColor())
        
        animator.addAnimation(nameTopMarginAnimation)
        animator.addAnimation(nameRightMarginAnimation)
        animator.addAnimation(avatarSizeAnimation)
        animator.addAnimation(backImageHeightAnimation)
        animator.addAnimation(cornerRadiusAnimation)
        animator.addAnimation(topViewBackColorAnimation)
    }
    
    @IBAction func updatePosition() -> Void {
        animator.animate(bounds.height)
    }
}
