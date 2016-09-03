//
//  RegisterViewController.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/24/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

import DeformationButton
import ReactiveCocoa

class RegisterViewController: UIViewController {
    
    
    @IBOutlet weak var avatarButton: UIButton!
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var professionTextField: UITextField!
    
    
    @IBOutlet weak var signUpButtonMaxWidth: NSLayoutConstraint!
    @IBOutlet weak var signUpButtonLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var signUpButtonContainer: UIView!
    var avatarImage: UIImage?
    
    lazy var signupButton: DeformationButton = {
        
        let btnWidth = min(Main_Screen_Width-CGFloat(self.signUpButtonLeftMargin.constant*2.0), self.signUpButtonMaxWidth.constant)
        let btn = DeformationButton(frame: CGRectMake(0, 0, btnWidth, self.signUpButtonContainer.bounds.height), withColor: ThemeColor)
        
        btn.forDisplayButton.setTitle("Sign Up", forState: .Normal)
        btn.forDisplayButton.setBackgroundImage(UIImage.imageWithColor(ThemeColor, cornerRadius: 3), forState: .Normal)
        
        self.signUpButtonContainer.addSubview(btn)
        
        return btn
    }()
    
    lazy var viewModel: RegisterViewModel = {
        return RegisterViewModel()
    }()
    
    // MARK: VC life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        configureSubviews()
        
        bindSignals()
        bindActions()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.hidesNavigationBarHairline = true
        navigationController?.setStatusBarStyle(.LightContent)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: Bindings
    
    func bindSignals() {
        
        // bind input to viewModel
        RAC(viewModel, "username") <~ usernameTextField.rac_textSignal()
        RAC(viewModel, "password") <~ passwordTextField.rac_textSignal()
        RAC(viewModel, "nickname") <~ nicknameTextField.rac_textSignal()
        RAC(viewModel, "profession") <~ professionTextField.rac_textSignal()
        RAC(viewModel, "avatar") <~ avatarButton.rac_signalForSelector(#selector(UIButton.setImage(_:forState:))).map{ $0.first() as! UIImage }
        
        // bind viewModel to UI
        RACObserve(signupButton, "bgView.hidden").subscribeNext { (value) in
            let isNotLoading = (value as! Bool)
            self.signupButton.userInteractionEnabled = isNotLoading
            
            self.resignFirstResponder()
            self.avatarButton.userInteractionEnabled = isNotLoading
            self.usernameTextField.userInteractionEnabled = isNotLoading
            self.passwordTextField.userInteractionEnabled = isNotLoading
            self.nicknameTextField.userInteractionEnabled = isNotLoading
            self.professionTextField.userInteractionEnabled = isNotLoading
        }
        
        DynamicProperty(object: self.signupButton, keyPath: "enabled") <~ viewModel.isInputValid
        DynamicProperty(object: self.signupButton, keyPath: "forDisplayButton.enabled") <~ viewModel.isInputValid
    }
    
    func bindActions() {
        // choose avatar image
        avatarButton.rac_signalForControlEvents(.TouchUpInside).subscribeNext { (_) in
            SLImagePicker.pickImage(fromViewController: self) { (images) in
                self.avatarButton.setImage(images[0], forState: .Normal)
            }
        }
        
        // for signup button
        signupButton.rac_signalForControlEvents(.TouchUpInside).subscribeNext { (_) in
            let targetDate = NSDate().dateByAddingSeconds(2)
            self.resignFirstResponder()
            self.viewModel.registerAction.apply()
                .start(Signal.Observer { event in
                    switch event {
                    case .Next:
                        let jump = {
                            self.signupButton.isLoading = false
                            self.performSegueWithIdentifier("SelectTopics", sender: nil)
                        }
                        
                        if NSDate().isLaterThan(targetDate) {
                            jump()
                        } else {
                            self.bk_performBlock({ (_) in
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
                        self.signupButton.isLoading = false
                    }
                })
        }
    }
    
    // MARK: UIStyle
    
    func configureSubviews() {
        
        title = "News Feed"
        
        // textfields
        usernameTextField.configCheckBlock(viewModel.nameInvalidHint) { _ in self.viewModel.isNameValid.value }
        passwordTextField.configCheckBlock(viewModel.passInvalidHint) { _ in self.viewModel.isPassValid.value }
        professionTextField.configCheckBlock("", block: nil)
        nicknameTextField.configCheckBlock("", block: nil)
        
        
        // buttons
        let inset = CGFloat(2)
        avatarButton.contentEdgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset)
        avatarButton.imageView!.layer.cornerRadius = avatarButton.bounds.height/2 - inset
        avatarButton.imageView!.clipsToBounds = true
    }
}
