
//
//  SLImagePicker.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/22/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

import ImagePicker

class SLImagePicker: NSObject, ImagePickerDelegate {
    
    private static var sharedPicker = SLImagePicker()

    private var imagePicker: ImagePickerController!
    
    private var block: (([UIImage]) -> Void)?
    
    static func pickImage(fromViewController vc: UIViewController, limit: Int = 1, block: (([UIImage]) -> Void)) {
        sharedPicker.pickImage(fromViewController: vc, limit: limit, block: block)
    }
    
    private func pickImage(fromViewController vc: UIViewController, limit: Int = 1, block: (([UIImage]) -> Void)) {
        imagePicker = ImagePickerController()
        self.block = block
        
        (imagePicker.bottomContainer.valueForKey("borderPickerButton") as? UIView)?.backgroundColor = ThemeColor
        imagePicker.bottomContainer.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.9)
        imagePicker.view.backgroundColor = UIColor.whiteColor();
        
        imagePicker.delegate = self
        imagePicker.imageLimit = limit
        imagePicker.galleryView.setValue(limit, forKey: "imageLimit")
        
        vc.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: ImagePickerDelegate
    
    func cancelButtonDidPress(imagePicker: ImagePickerController) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func wrapperDidPress(imagePicker: ImagePickerController, images: [UIImage]) {
        guard images.count > 0 else { return }
        
        block?(images)
    }
    
    func doneButtonDidPress(imagePicker: ImagePickerController, images: [UIImage]) {
        guard images.count > 0 else { return }
        
        block?(images)
        
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
    }
}
