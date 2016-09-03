//
//  JSQTextMediaItem.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/19/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

import JSQMessagesViewController
import SnapKit
import MobileCoreServices
import RTIconButton
import UITintedButton

private class TextMediaView: UIView {
    
    static let hmargin = CGFloat(10.0), vmargin = CGFloat(10.0), padding = CGFloat(5.0), vpadding = CGFloat(6), timeHeight = CGFloat(12)
    static var textFont = UIFont.systemFontOfSize(14)
    static var timeFont = UIFont.systemFontOfSize(8, weight: UIFontWeightRegular)
    
    var textView = JSQMessagesCellTextView()
    var timeIconButton = RTIconButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // text
        textView.editable = false
        textView.selectable = true
        textView.userInteractionEnabled = true
        textView.showsHorizontalScrollIndicator = false
        textView.showsVerticalScrollIndicator = false
        textView.scrollEnabled = false
        textView.dataDetectorTypes = .All
        textView.contentInset = UIEdgeInsetsZero
        textView.scrollIndicatorInsets = UIEdgeInsetsZero
        textView.contentOffset = CGPointZero
        textView.textContainerInset = UIEdgeInsetsZero
        //textView.textContainer.lineFragmentPadding = 0
        textView.backgroundColor = UIColor.clearColor()
        textView.font = TextMediaView.textFont
        textView.textContainer.lineBreakMode = .ByWordWrapping
        addSubview(textView)
        textView.snp_makeConstraints { (make) in
            make.leading.equalTo(self).offset(TextMediaView.hmargin)
            make.trailing.equalTo(self).offset(-TextMediaView.hmargin)
            make.top.equalTo(self).offset(TextMediaView.vmargin)
        }
        
        // time
        timeIconButton.setImage(UIImage(named: "time_grey"), forState: .Normal)
        timeIconButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        timeIconButton.setImageTintColor(UIColor.whiteColor(), forState: .Normal)
        timeIconButton.setTitleColor(ThemeColor, forState: .Selected)
        timeIconButton.setImageTintColor(ThemeColor, forState: .Selected)
        timeIconButton.titleLabel?.font = TextMediaView.timeFont
        timeIconButton.iconMargin = 3
        timeIconButton.iconSize = CGSizeMake(12, 12)
        timeIconButton.iconPosition = RTIconPosition.Left.rawValue
        timeIconButton.contentHorizontalAlignment = .Right
        timeIconButton.userInteractionEnabled = false
        timeIconButton.setContentHuggingPriority(UILayoutPriorityDefaultLow, forAxis: .Vertical)
        timeIconButton.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Vertical)
        
        addSubview(timeIconButton)
        timeIconButton.snp_makeConstraints { (make) in
            make.top.equalTo(textView.snp_bottom).offset(TextMediaView.vpadding)
            make.trailing.equalTo(textView)
            make.bottom.equalTo(self).offset(-TextMediaView.vmargin)
            make.height.equalTo(TextMediaView.timeHeight)
        }
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func appliesMediaViewMaskAsOutgoing(isOutGoing: Bool) -> Void {
        
        self.backgroundColor = isOutGoing ? ThemeColor : UIColor.whiteColor()
        textView.textColor = isOutGoing ? UIColor.whiteColor() : UIColor.blackColor()
        textView.linkTextAttributes = [ NSForegroundColorAttributeName : textView.textColor!,
                                        NSUnderlineStyleAttributeName : NSUnderlineStyle.StyleSingle.rawValue | NSUnderlineStyle.PatternSolid.rawValue];
        
        let (leading, trailing) = isOutGoing ? (0.0, TextMediaView.padding) : (TextMediaView.padding, 0.0)
        textView.snp_updateConstraints { (make) in
            make.leading.equalTo(self).offset((TextMediaView.hmargin+leading))
            make.trailing.equalTo(self).offset(-(TextMediaView.hmargin+trailing))
        }
        
        timeIconButton.selected = !isOutGoing
        
    }
    
    
    static func heightFor(data: [ String : AnyObject? ]) -> CGSize {
        let maxWidth = Main_Screen_Width - 35 * 2 - 50
        var textHeight = CGFloat(0)

        var width = CGFloat(100), textMaxWidth = maxWidth-TextMediaView.padding - 2*TextMediaView.hmargin
        if let text = data["text"] where (text as! NSString).length > 0 {
            
            let size = (text as! NSString).boundingRectWithSize(CGSizeMake(textMaxWidth, CGFloat.max), options: drawingOptions, attributes: [NSFontAttributeName:textFont], context: nil)
            width = max(size.width+10, width)
            textHeight = size.height
        }
        
        return CGSizeMake(width+TextMediaView.padding + 2*TextMediaView.hmargin, textHeight + timeHeight + 1 + 2*vmargin+vpadding)
    }

}

class JSQTextMediaItem: JSQMediaItem {
    private var cachedMediaView: TextMediaView?
    
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
        
        if let text = data?["text"] {
            value ^= (text as! NSObject).hash
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
        let viewData: [String : AnyObject?] = ["text": data["text"] as? String,
                        "date": DateHelper.timeAgo(data!["date"] as? NSDate)]
        return TextMediaView.heightFor(viewData);
    }
    
    override func mediaView() -> UIView! {
        if self.data == nil {
            return nil
        }
        
        if cachedMediaView == nil {
            cachedMediaView = TextMediaView(frame: CGRect(origin: CGPointZero, size: self.mediaViewDisplaySize()))
            cachedMediaView?.clipsToBounds = true
            
            cachedMediaView?.appliesMediaViewMaskAsOutgoing(self.appliesMediaViewMaskAsOutgoing)
            
            cachedMediaView!.textView.text = data["text"] as? String
            cachedMediaView?.timeIconButton.setTitle(DateHelper.timeAgo(data!["date"] as? NSDate), forState: .Normal)
            cachedMediaView?.timeIconButton.setTitle(DateHelper.timeAgo(data!["date"] as? NSDate), forState: .Disabled)
            
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
    
    //MARK: NSCoding
    
    override func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)
        
        aCoder.encodeObject(data?["text"] ?? nil, forKey: "text")
        aCoder.encodeObject(data?["date"] ?? nil, forKey: "date")
    }
    
    
    //MARK: NSCopying
    override func copyWithZone(zone: NSZone) -> AnyObject {
        return JSQPhotoMediaItemCustom(withData: self.data)
    }
}
