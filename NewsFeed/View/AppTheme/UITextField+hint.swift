//
//  UITextField+hint.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/15/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

import Foundation
import Aspects
import ChameleonFramework
import SnapKit

extension UITextField {

    func configCheckBlock(errorHint: String, block: (String? -> Bool)?) -> Void {
        
        if leftView == nil {
            let paddingLeft = self.borderStyle == .None ? 4 : 8
            leftView = UIView(frame: CGRect(x: 0, y: 0, width: paddingLeft, height: paddingLeft))
            leftViewMode = UITextFieldViewMode.Always
            tintColor = ThemeColor
        }
        
        let isFirstTimeConfig = (self.checkBlock == nil)

        self.checkBlock = block
        self.errorHint = errorHint
        
        if isFirstTimeConfig {
            
            self.rac_newTextChannel()
                .merge(RACObserve(self, "text"))
                .delay(0.1)
                .subscribeNext({ [unowned self] (_) in
                    self.updateDisplay()
                })
            
            if self.borderStyle == .None {
                self.addBorder(ofSide: .Bottom, width: 0.5, color: nil)
                self.rac_signalForSelector(#selector(becomeFirstResponder)).merge(self.rac_signalForSelector(#selector(resignFirstResponder))).subscribeNext({ (x) in
                    self.addBorder(ofSide: .Bottom, width: self.editing ? 1 : 0.5, color: self.editing ? ThemeColor : nil)
                })
            }
            
        }
        self.updateDisplay()
    }
    
    func inputIsValid() -> Bool {
        if self.checkBlock != nil {
            return self.checkBlock!(self.text)
        }
        return true
    }
    
    func updateDisplay() {
        
        if self.errorButton == nil {
            
            if self.checkBlock != nil {
                let inset = (bounds.height - 20 )/2
                
                let btnRight = UIButton()
                btnRight.addTarget(self, action: #selector(showErrorInfo(_:)), forControlEvents: .TouchUpInside)
                btnRight.setImage(UIImage(named: "textfield_warning_info")?.tintImageWithColor(FlatYellow()), forState: .Normal)
                btnRight.contentMode = .Center
                btnRight.contentEdgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset)
                
                self.errorButton = btnRight
                self.addSubview(self.errorButton!)
                
                btnRight.snp_makeConstraints(closure: { (make) in
                    make.centerY.trailing.equalTo(self)
                    make.width.height.equalTo(bounds.height)
                })
            }
            
        } else {
            if self.checkBlock == nil {
                self.errorButton?.removeFromSuperview()
                self.errorButton = nil
                self.backgroundColor = UIColor.whiteColor()
            }
        }
        
        if self.errorButton != nil && self.checkBlock != nil {
            let isValid = self.checkBlock!(text)
            
            self.errorButton?.hidden = isValid
            //backgroundColor = isValid ? UIColor.whiteColor() : UIColor.redColor().colorWithAlphaComponent(0.1)
            
            bringSubviewToFront(self.errorButton!)
        }
        
        
    }    

    @IBAction func showErrorInfo(sender: UIButton) -> Void {
        Toast.showError(self.errorHint ?? "输入错误")
    }
    
//    // MARK: Catagory Set/Get
//    
//    private struct AssociatedKeys {
//        static var CheckBlockName = "nf_CheckBlockName"
//        static var ErrorHintName = "nf_ErrorHintName"
//        static var ErrorButtonName = "nf_ErrorButtonName"
//    }
//    
//    var checkBlock: (String? -> Bool)? {
//        get {
//            return objc_getAssociatedObject(self, &AssociatedKeys.CheckBlockName) as? (String? -> Bool)
//        }
//        set {
//            var wrappedObject: AnyObject? = nil
//            if newValue != nil {
////                let wrappedBlock:@convention(block) (String?) -> Bool = { (text) in
////                    return newValue!(text)
////                }
//
//                wrappedObject = unsafeBitCast(
//                    newValue! as @convention(block) (String?) -> Bool,
//                    AnyObject.self
//                )
//            }
//            print(wrappedObject)
//            objc_setAssociatedObject(
//                self,
//                &AssociatedKeys.CheckBlockName,
//                wrappedObject,
//                objc_AssociationPolicy.OBJC_ASSOCIATION_COPY
//            )
//        }
//    }
//    
//    var errorHint: String? {
//        get {
//            return objc_getAssociatedObject(self, &AssociatedKeys.ErrorHintName) as? String
//        }
//        set {
//            if let newValue = newValue {
//                objc_setAssociatedObject(
//                    self,
//                    &AssociatedKeys.ErrorHintName,
//                    newValue as String?,
//                    objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC
//                )
//            }
//        }
//    }
//    
//    var errorButton: UIButton? {
//        get {
//            return objc_getAssociatedObject(self, &AssociatedKeys.ErrorButtonName) as? UIButton
//        }
//        set {
//            if let newValue = newValue {
//                objc_setAssociatedObject(
//                    self,
//                    &AssociatedKeys.ErrorButtonName,
//                    newValue as UIButton?,
//                    objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
//                )
//            }
//        }
//    }
}