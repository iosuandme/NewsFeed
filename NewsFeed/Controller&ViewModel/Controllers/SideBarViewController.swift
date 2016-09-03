//
//  SideBarViewController.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/7/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

import UIKit
import MSDynamicsDrawerViewController

class SideBarCell: UITableViewCell {
    
    @IBOutlet weak var highlightHintView: UIView?
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        highlightHintView?.alpha = highlighted ? 1 : 0
    }
}

class SideBarViewController: UITableViewController {
    
    weak var dynamicVC: MSDynamicsDrawerViewController?
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var professionLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        avatarImageView?.layer.cornerRadius = avatarImageView.bounds.height/2
        avatarImageView?.layer.borderWidth = 2
        avatarImageView?.layer.borderColor = UIColor.whiteColor().CGColor
        avatarImageView?.clipsToBounds = true
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        tableView.showsVerticalScrollIndicator = false
    }
    
    override func viewWillAppear(animated: Bool) {
        let user = User_Bmob.currentUser()
        nameLabel?.text = user?.nickname
        professionLabel?.text = user?.profession
        followersLabel?.text = String(user!.info.followersCount)
        followingLabel?.text = String(user!.info.followingsCount)
        avatarImageView?.sd_setImageWithURL(user?.thumbURL, placeholderImage: AvatarPlaceHolder)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            PageRouter.showHomePage()
        case 1:
            PageRouter.showNotifications()
        case 2:
            PageRouter.showProfileFor(nil, fromVC: self)
        case 3:
            PageRouter.showProfileFor(User_Bmob.currentUser(), fromVC: self)
        case 4:
            PageRouter.showSettings()
        case 5:
            PageRouter.logout()
        default:
            break
        }
    }

}
