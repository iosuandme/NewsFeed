//
//  UINavigationBar+customstyle.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/6/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

import Foundation

extension UINavigationItem {
    
    public static override func initialize() {
        
        // 1.设置导航栏背景
        let bar = UINavigationBar.appearance()
    
        bar.backIndicatorImage = UIImage(named: "back")
        bar.backIndicatorTransitionMaskImage = UIImage(named: "back")
        bar.barTintColor = ThemeColor
        bar.tintColor = UIColor.whiteColor()
        bar.translucent = false
        
        // 2.设置导航栏文字属性
        bar.titleTextAttributes = [ NSForegroundColorAttributeName : UIColor.whiteColor(),
                                    NSFontAttributeName            : UIFont.systemFontOfSize(18) ];
        
        // 3.按钮
        let item = UIBarButtonItem.appearance()
        
        for state: UIControlState in [.Normal, .Highlighted, .Disabled] {
            item.setTitleTextAttributes([NSFontAttributeName : UIFont.systemFontOfSize(12) ], forState: state)
        }
        
    }
}