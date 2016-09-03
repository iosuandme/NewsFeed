//
//  Toast.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/10/16.
//  Copyright © 2016 Kidney. All rights reserved.
//
import SVProgressHUD

class Toast: NSObject {
    
    override static func initialize() {
        SVProgressHUD.setDefaultStyle(.Custom)
        SVProgressHUD.setFont(UIFont.systemFontOfSize(14))
        SVProgressHUD.setBackgroundColor(ThemeColor)
        SVProgressHUD.setForegroundColor(UIColor.whiteColor())
        SVProgressHUD.setDefaultMaskType(.Black)
        SVProgressHUD.setMinimumDismissTimeInterval(1.2)
        SVProgressHUD.setBackgroundLayerColor(UIColor.redColor())
    }
    
    static func show(status: String) -> Void {
        SVProgressHUD.showWithStatus(status)
    }

    static func showInfo(status: String) -> Void {
        SVProgressHUD.showInfoWithStatus(status)
    }
    
    static func showError(status: String) -> Void {
        SVProgressHUD.showInfoWithStatus(status)
    }
    
    static func showSuccess(status: String) -> Void {
        SVProgressHUD.showSuccessWithStatus(status)
    }
    
    static func dismiss() -> Void {
        SVProgressHUD.dismiss()
    }
}
