//
//  UIImage+tintcolor.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/15/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

import Foundation

extension UIImage {
    
    func tintImage() -> UIImage {
        return self.tintImageWithColor(ThemeColor);
    }
    
    func tintImageWithColor(color: UIColor?) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.mainScreen().scale);
        let context = UIGraphicsGetCurrentContext();
        
        CGContextTranslateCTM(context, 0, self.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        let rect = CGRectMake(0, 0, self.size.width, self.size.height);
        
        CGContextSetBlendMode(context, .Normal);
        CGContextDrawImage(context, rect, self.CGImage);
        
        CGContextSetBlendMode(context, .SourceIn);
        color?.setFill()
        CGContextFillRect(context, rect);
        
        let coloredImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return coloredImage;
    }
    
    static func imageWithColor(color: UIColor, cornerRadius: CGFloat) -> UIImage {
        let rect = CGRectMake(0, 0, cornerRadius*2+10, cornerRadius*2+10);
        
        let path = UIBezierPath.init(roundedRect: rect, cornerRadius: cornerRadius)
        path.lineWidth = 0;
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0);
        let context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, color.CGColor);
        
        path.fill()
        path.stroke()
        path.addClip()
        
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image.resizableImageWithCapInsets(UIEdgeInsetsMake(10, 10, 10, 10));
    }
}