//
//  JSQPhotoMediaItemCustom.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/19/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

import JSQMessagesViewController
import SnapKit
import MobileCoreServices
import RTIconButton

private class PhotoMediaView: UIView {
    
    var imageView = UIImageView()
    var activityHolder = JSQMessagesMediaPlaceholderView.viewWithActivityIndicator()
    var timeIconButton = RTIconButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // image
        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true
        addSubview(imageView)
        
        imageView.snp_makeConstraints { (make) in
            make.top.leading.bottom.trailing.equalTo(self)
        }
        
        activityHolder.backgroundColor = UIColor.whiteColor()
        addSubview(activityHolder)
        activityHolder.snp_makeConstraints { (make) in
            make.edges.equalTo(imageView)
        }
        
        // time
        timeIconButton.setImage(UIImage(named: "time_grey")?.tintImageWithColor(UIColor.whiteColor()), forState: .Normal)
        timeIconButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        timeIconButton.titleLabel?.font = UIFont.systemFontOfSize(8, weight: UIFontWeightRegular)
        timeIconButton.iconMargin = 3
        timeIconButton.iconSize = CGSizeMake(8, 8)
        timeIconButton.iconPosition = RTIconPosition.Left.rawValue
        timeIconButton.contentHorizontalAlignment = .Right
        timeIconButton.userInteractionEnabled = false
        timeIconButton.setContentHuggingPriority(UILayoutPriorityDefaultLow, forAxis: .Vertical)
        timeIconButton.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Vertical)
        timeIconButton.contentEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8)
        timeIconButton.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        timeIconButton.layer.cornerRadius = 14.0/2
        
        addSubview(timeIconButton)
        timeIconButton.snp_makeConstraints { (make) in
            make.bottom.trailing.equalTo(self).offset(-8)
            make.height.equalTo(14)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class JSQPhotoMediaItemCustom: JSQMediaItem {
    
    private var cachedMediaView: PhotoMediaView?
    
    private var data: Dictionary<String, AnyObject?>! {
        didSet {
            cachedMediaView = nil
        }
    }
    
    override var appliesMediaViewMaskAsOutgoing: Bool {
        didSet {
            cachedMediaView = nil
        }
    }
    
    override var description: String {
        return "<\(NSStringFromClass(JSQPhotoMediaItemCustom)): data=\(data), appliesMediaViewMaskAsOutgoing=\(appliesMediaViewMaskAsOutgoing)>"
    }
    
    override var hash: Int {
        var value = super.hash
        
        if let imageURL = data?["imageURL"] {
            value ^= (imageURL as! NSObject).hash
        }
        
        if let time = data?["date"] {
            value ^= (time as! NSObject).hash
        }
        
        return value
    }
    
    //MARK: Initialization
    
    init(withData data: Dictionary<String, AnyObject?>) {
        super.init()
        
        self.data = data
        cachedMediaView = nil
    }
    
    override init!(maskAsOutgoing: Bool) {
        super.init(maskAsOutgoing: maskAsOutgoing)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func clearCachedMediaViews() {
        super.clearCachedMediaViews()
        
        self.cachedMediaView = nil
    }
    

    //MARK: JSQMessageMediaData protocol
    
    override func mediaViewDisplaySize() -> CGSize {
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
            return CGSizeMake(315.0, 245.0);
        }
        
        return CGSizeMake(210.0, 140.0);
    }
    
    override func mediaView() -> UIView! {
        if self.data == nil {
            return nil
        }
        
        if cachedMediaView == nil {
            cachedMediaView = PhotoMediaView(frame: CGRect(origin: CGPointZero, size: self.mediaViewDisplaySize()))
            cachedMediaView?.clipsToBounds = true
            
            let trailing = appliesMediaViewMaskAsOutgoing ? 5.0 : 0.0
            cachedMediaView?.timeIconButton.snp_updateConstraints(closure: { (make) in
                if let superview = cachedMediaView?.timeIconButton.superview {
                    make.trailing.equalTo(superview).offset(-(trailing+8))
                }
            })
            
            self.cachedMediaView?.activityHolder.hidden = false
            cachedMediaView!.imageView.sd_setImageWithURL(data?["imageURL"] as? NSURL, placeholderImage: ImagePlaceHolder, completed: { (_, error, _, _) in
                if error == nil {
                    self.cachedMediaView?.activityHolder.hidden = true
                }
            })
            cachedMediaView!.timeIconButton.setTitle(DateHelper.timeAgo(data["date"] as? NSDate), forState: .Normal)
            
            // Masker
            JSQMessagesMediaViewBubbleImageMasker.applyBubbleImageMaskToMediaView(cachedMediaView, isOutgoing: appliesMediaViewMaskAsOutgoing)
        }
        
        return cachedMediaView
    }

    override func mediaHash() -> UInt {
        if self.hash == Int.min {
            return UInt.max;
        }
        return self.hash < 0 ? UInt(Int.max) + UInt(-self.hash) : UInt(self.hash)
    }

    func mediaDataType() -> String {
        return kUTTypeJPEG as String
    }
    
    func mediaData() -> NSData! {
        return nil
    }
    
    // MARK: NSCoding
    
    override func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)
        
        aCoder.encodeObject(data?["imageURL"] ?? nil, forKey: "imageURL")
        aCoder.encodeObject(data?["date"] ?? nil, forKey: "date")
    }
    
    // MARK: NSCopying
    override func copyWithZone(zone: NSZone) -> AnyObject {
        return JSQPhotoMediaItemCustom(withData: self.data)
    }
}
