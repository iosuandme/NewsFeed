//
//  IntroductionViewController.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/6/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

import UIKit
import ReactiveCocoa

class IntroductionViewController: UIViewController {
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UIStyle
        signInButton.layer.borderColor = UIColor.whiteColor().CGColor
        
        // Actions
        signInButton.rac_signalForControlEvents(.TouchUpInside)
            .merge(closeButton.rac_signalForControlEvents(.TouchUpInside))
            .merge(signUpButton.rac_signalForControlEvents(.TouchUpInside))
            .subscribeNext { [weak self] (sender) in
                
                if let strongSelf = self {
                    NSUserDefaults.standardUserDefaults().setBool(false, forKey: IsFirstTimeLaunchKey)
                    
                    if sender as? UIButton == strongSelf.signUpButton {
                        let vcSignUp = strongSelf.storyboard?.instantiateViewControllerWithIdentifier("RegisterViewController")
                        (strongSelf.presentingViewController as? UINavigationController)?.pushViewController(vcSignUp!, animated: false)
                    }
                    
                    strongSelf.dismissViewControllerAnimated(true, completion: nil)
                }
            }
    }
    
    // MARK: UIStyle
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
}
