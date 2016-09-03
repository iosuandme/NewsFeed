//
//  UIView+border.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/24/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

import Foundation
import SnapKit

enum BorderSide: Int {
    case Right   = 8881
    case Left
    case Top
    case Bottom
}

extension UIView {
    
    func addBorder(ofSide side: BorderSide, width: CGFloat, color: UIColor? = nil) {
        var border: UIView! = self.viewWithTag(side.rawValue)
        
        if border == nil {
            border = UIView()
            border.tag = side.rawValue
            
            insertSubview(border, atIndex: 0)
            
            border.snp_updateConstraints { (make) in
                switch side {
                case .Left:
                    make.leading.top.bottom.equalTo(self)
                case .Right:
                    make.trailing.top.bottom.equalTo(self)
                case .Top:
                    make.leading.trailing.top.equalTo(self)
                case .Bottom:
                    make.leading.trailing.bottom.equalTo(self)
                }
            }
            
        } else {
            bringSubviewToFront(border)
        }
        
        border.backgroundColor = color ?? UIColor.lightGrayColor()
        
        border.snp_updateConstraints { (make) in
            switch side {
            case .Left:
                make.width.equalTo(width)
            case .Right:
                make.width.equalTo(width)
            case .Top:
                make.height.equalTo(width)
            case .Bottom:
                make.height.equalTo(width)
            }
        }
    }

}