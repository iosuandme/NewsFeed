//
//  LoginViewController.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/6/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ChameleonFramework
import DeformationButton
import DateTools

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signInButtonMaxWidth: NSLayoutConstraint!
    @IBOutlet weak var signInButtonLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var signInButtonContainer: UIView!
    
    lazy var loginButton: DeformationButton = {
        
        let btnWidth = min(Main_Screen_Width-CGFloat(self.signInButtonLeftMargin.constant*2.0), self.signInButtonMaxWidth.constant)
        let btn = DeformationButton(frame: CGRectMake(0, 0, btnWidth, self.signInButtonContainer.bounds.height), withColor: ThemeColor)
      
        btn.forDisplayButton.setTitle("Sign In", forState: .Normal)
        btn.forDisplayButton.setBackgroundImage(UIImage.imageWithColor(ThemeColor, cornerRadius: 3), forState: .Normal)
        
        self.signInButtonContainer.addSubview(btn)
        
        return btn
    }()
    
    let viewModel = LoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.configCheckBlock(viewModel.nameInvalidHint) { [weak self] _ in self?.viewModel.isNameValid.value ?? false }
        passwordTextField.configCheckBlock(viewModel.passInvalidHint) { [weak self] _ in self?.viewModel.isPassValid.value ?? false }
        
        bindSignals()
        bindActions()
        
        // check if first time launch => show Introduction Page
        if (NSUserDefaults.standardUserDefaults().valueForKey(IsFirstTimeLaunchKey) as? Bool) ?? true {
            let introduceVC = storyboard!.instantiateViewControllerWithIdentifier("IntroductionViewController")
            navigationController?.presentViewController(introduceVC, animated: false, completion: nil)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.viewModel.getLastLoginInfo()
    }
    
    // MARK: Bindings
    
    func bindSignals() {
        
        // bind input to viewModel
        RAC(viewModel, "username") <~ usernameTextField.rac_textSignal()
        RAC(viewModel, "password") <~ passwordTextField.rac_textSignal()
        
        // bind viewModel to UI
        RAC(usernameTextField, "text") <~ RACObserve(viewModel, "username")
        RAC(passwordTextField, "text") <~ RACObserve(viewModel, "password")
        
        RACObserve(loginButton, "bgView.hidden").subscribeNext { [weak self] (value) in
            let isNotLoading = (value as! Bool)
            self?.loginButton.userInteractionEnabled = isNotLoading
            
            // disable textfields while loading
            self?.resignFirstResponder()
            self?.usernameTextField.userInteractionEnabled = isNotLoading
            self?.passwordTextField.userInteractionEnabled = isNotLoading
        }
        
        DynamicProperty(object: self.loginButton, keyPath: "enabled") <~ viewModel.isInputValid
        DynamicProperty(object: self.loginButton, keyPath: "forDisplayButton.enabled") <~ viewModel.isInputValid
    }
    
    func bindActions() {
        
        // for login button
        loginButton.rac_signalForControlEvents(.TouchUpInside).subscribeNext { (_) in
        
            self.resignFirstResponder()
            
            let targetDate = NSDate().dateByAddingSeconds(2)
            self.viewModel.loginAction.apply()
                .start(Signal.Observer { [weak self] event in
                    if let strongSelf = self {
                        switch event {
                        case let .Next(user):
                            let jump = {
                                strongSelf.loginButton.isLoading = false
                                
                                if user.hasSelectedTopics {
                                    PageRouter.showMainInterface()
                                } else {
                                    strongSelf.performSegueWithIdentifier("SelectTopics", sender: nil)
                                }
                            }
                            
                            // keep the loading animation for a period of time
                            if NSDate().isLaterThan(targetDate) {
                                jump()
                            } else {
                                strongSelf.bk_performBlock({ (_) in
                                    jump()
                                }, afterDelay: targetDate.secondsLaterThan(NSDate()))
                            }
                            
                            break
                        case .Completed: break
                        case let .Failed(.ProducerError(err)):
                            Toast.showError(err.localizedDescription)
                            fallthrough
                        default:
                            print(event)
                            strongSelf.loginButton.isLoading = false
                        }
                    }
                })
        }
    }

    // MARK: UIStyle
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .Default
    }
}