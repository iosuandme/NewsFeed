

//
//  SettingsViewController.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/22/16.
//  Copyright © 2016 Kidney. All rights reserved.
//


class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Settings"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}
