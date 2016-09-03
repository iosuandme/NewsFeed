//
//  NewsDetailViewController.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/18/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

import UITintedButton
import RTIconButton
import ReactiveCocoa

class NewsDetailViewController: UIViewController {

    // Top
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    // Center
    @IBOutlet weak var newsImageView: UIImageView!
    
    // Bottom
    @IBOutlet weak var userAvatarButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var likesButton: RTIconButton!
    @IBOutlet weak var commentsButton: RTIconButton!
    
    
    var viewModel: NewsDetailViewModel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSubviews()
        
        bindSignals()
        bindActions()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "backtransluent"), forBarMetrics: .Default)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.translucent = true
        
        viewModel.viewedNewsAction.apply().start() // viewsCount +1
        viewModel.refreshModel()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: .Default)
    }
    
    // MARK: Bindings
    
    func bindSignals() {
        DynamicProperty(object: titleLabel, keyPath: "text") <~ viewModel.topicName
        DynamicProperty(object: usernameLabel, keyPath: "text") <~ viewModel.nickName
        
        likesButton.rex_title <~ viewModel.likesCount
        commentsButton.rex_title <~ viewModel.commentsCount
        
        viewModel.avatarURLSignal.subscribeNext { (url) in
            self.userAvatarButton.sd_setImageWithURL(url as? NSURL, forState: .Normal, placeholderImage: AvatarPlaceHolder)
        }
        viewModel.imageURLSignal.subscribeNext { (url) in
            self.newsImageView.sd_setImageWithURL(url as? NSURL, placeholderImage: ImagePlaceHolder)
        }
    }
    
    func bindActions() {
        commentsButton.rac_signalForControlEvents(.TouchUpInside).subscribeNext { (_) in
            self.viewModel.showComment()
        }
        
        likesButton.rac_signalForControlEvents(.TouchUpInside).subscribeNext { (_) in
            self.viewModel.likeNewsAction.apply().start({ event in
                switch event {
                case let .Failed(error):
                    switch error {
                    case .NotEnabled: break
                    case let .ProducerError(err):
                        Toast.showError(err.localizedDescription)
                    }
                case .Completed:
                    Toast.showSuccess("like success")
                default: break
                }
            })
        }
    }
    
    // MARK: UIStyle
    
    func configureSubviews() {
        
        likesButton.setImageTintColor(UIColor.whiteColor(), forState: .Normal)
        commentsButton.setImageTintColor(UIColor.whiteColor(), forState: .Normal)
        
        userAvatarButton.layer.cornerRadius = userAvatarButton.bounds.height/2
        userAvatarButton.layer.masksToBounds = true
        userAvatarButton.layer.borderColor = UIColor.whiteColor().CGColor
        userAvatarButton.layer.borderWidth = 2
    }
}
