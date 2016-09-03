//
//  SelfProfileHeader.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/7/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

import UIKit
import JazzHands

let SelfProfileHeaderHeight = CGFloat(310.0)

class SelfProfileHeader: BaseActionReusableView {
    
    enum HeaderAction: Int {
        case Menu = 0, Message, WriteNews
    }
    
    @IBOutlet weak var professionLabel: UILabel!
    @IBOutlet weak var backImageView: UIImageView!
    
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet var staticsLabels: [UILabel]!
    
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var writeNewsButton: UIButton!
    var link: CADisplayLink?
    
    
    @IBOutlet weak var headImageTopMargin: NSLayoutConstraint!
    @IBOutlet weak var headImageHeight: NSLayoutConstraint!
    
    @IBOutlet weak var staticsContainerView: UIStackView!
    
    var animator = IFTTTAnimator()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        headImageView.layer.cornerRadius = headImageView.bounds.height/2
        headImageView.layer.masksToBounds = true
        headImageView.layer.borderColor = UIColor.whiteColor().CGColor
        headImageView.layer.borderWidth = 2
        headImageView.backgroundColor = UIColor.whiteColor()
        
        addAnimations()
    }
    
    override func configureCell(withBaseData data: [String : AnyObject?], collectionView: UICollectionView?, indexPath: NSIndexPath, delegate: CollectionCellAction?) {
        super.configureCell(withBaseData: data, collectionView: collectionView, indexPath: ParallaxHeaderIndexPath(forSection: indexPath.section), delegate: delegate)
        
        updateCell(withBaseData: data)
        
        if link == nil {
            link = CADisplayLink(target: self, selector: #selector(SelfProfileHeader.updatePosition))
            link?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: UITrackingRunLoopMode)
        }
    }
    
    override func updateCell(withBaseData data: [String : AnyObject?]) {
        let user = User_Bmob.currentUser()!
        nameLabel.text = user.nickname
        professionLabel.text = user.profession
        headImageView.sd_setImageWithURL(user.imageURL, placeholderImage: AvatarPlaceHolder)
        
        let statics = data["statics"] as! [String]
        for (index, label) in staticsLabels.enumerate() {
            label.text = statics[index]
        }
    }

    override func initializeViewTagAndReturnActionViews() -> [UIView] {
        menuButton.tag = HeaderAction.Menu.rawValue
        messageButton.tag = HeaderAction.Message.rawValue
        writeNewsButton.tag = HeaderAction.WriteNews.rawValue
        
        return [menuButton, messageButton, writeNewsButton]
    }
    
    // MARK: Animation
    
    func addAnimations() -> Void {
        let alphaAnimation = IFTTTAlphaAnimation(view: staticsContainerView)
        alphaAnimation.addKeyframeForTime(210, alpha: 0.0)
        alphaAnimation.addKeyframeForTime(310, alpha: 1.0)
        
        let headSizeAnimation = IFTTTConstraintConstantAnimation(superview: headImageView.superview, constraint: headImageHeight)
        headSizeAnimation.addKeyframeForTime(64, constant: 64)
        headSizeAnimation.addKeyframeForTime(310, constant: 125)
        headSizeAnimation.addKeyframeForTime(1000, constant: 1000-(310-125)-400)
        
        let headMarginTopAnimation = IFTTTConstraintConstantAnimation(superview: headImageView.superview, constraint: headImageTopMargin)
        headMarginTopAnimation.addKeyframeForTime(64, constant: 20+12)
        headMarginTopAnimation.addKeyframeForTime(310, constant: 72)
        
        let cornerRadiusAnimation = IFTTTCornerRadiusAnimation(view: headImageView)
        cornerRadiusAnimation.addKeyframeForTime(64, cornerRadius: 64.0/2)
        cornerRadiusAnimation.addKeyframeForTime(310, cornerRadius: 125.0/2)
        cornerRadiusAnimation.addKeyframeForTime(1000, cornerRadius: (1000.0-(310-125)-400)/2)
        
        let nameAlphaAnimation = IFTTTAlphaAnimation(view: nameLabel)
        nameAlphaAnimation.addKeyframeForTime(110, alpha: 0.0)
        nameAlphaAnimation.addKeyframeForTime(210, alpha: 1.0)
        
        let professionAlphaAnimation = IFTTTAlphaAnimation(view: professionLabel)
        professionAlphaAnimation.addKeyframeForTime(110, alpha: 0.0)
        professionAlphaAnimation.addKeyframeForTime(210, alpha: 1.0)
        
        animator.addAnimation(alphaAnimation)
        animator.addAnimation(headSizeAnimation)
        animator.addAnimation(headMarginTopAnimation)
        animator.addAnimation(cornerRadiusAnimation)
        animator.addAnimation(nameAlphaAnimation)
        animator.addAnimation(professionAlphaAnimation)
    }
    
    @IBAction func updatePosition() -> Void {
        animator.animate(bounds.height)
    }
    
    override func prepareForReuse() {
        link?.invalidate()
        link = nil
    }
}
