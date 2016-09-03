//
//  NewsCenterContainerViewController.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/17/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

import WMPageController
import ReactiveCocoa

let (TitleTopic, TitleTag) = ("select a topic", "select a tag")

class NewsCenterContainerViewController: WMPageController {
    
    
    var dropDownMenuView: BTNavigationDropdownMenu!
    var selectedTopic: String = TitleTopic
    var selectedTag: String = TitleTag
    var itemstopic: [String]! = []
    var itemstags = ["All"] + HashTags
    
    // MARK: outlets
    
    @IBOutlet weak var dropContainerView: UIView!
    
    // MARK: Init
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.menuViewStyle = .Line
        self.menuHeight = 44
        self.titleColorSelected = UIColor.whiteColor()
        self.titleColorNormal = UIColor.whiteColor().colorWithAlphaComponent(0.6)
        
        self.menuBGColor = ThemeColor
        self.progressColor = UIColor.whiteColor()
        self.titleSizeNormal = 13
        self.titleSizeSelected = 16
        self.menuItemWidth = 100
        self.progressHeight = 4
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.automaticallyAdjustsScrollViewInsets = true
        navigationController?.setStatusBarStyle(.LightContent)
        self.setStatusBarStyle(.LightContent)
        navigationController?.hidesNavigationBarHairline = true
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: WMPageControllerDataSource
    
    override func numbersOfChildControllersInPageController(pageController: WMPageController!) -> Int {
        return 2
    }
    
    override func pageController(pageController: WMPageController!, titleAtIndex index: Int) -> String! {
        return index == 0 ? "People" : "HashTags"
    }
    
    override func pageController(pageController: WMPageController!, viewControllerAtIndex index: Int) -> UIViewController! {
        let vc = storyboard!.instantiateViewControllerWithIdentifier("NewsViewController") as! NewsViewController
        
        switch index {
        case 0:
            vc.pageType = .People
        case 1:
            vc.pageType = .HashTags
        default:
            break
        }
        
        return vc
    }
    
    // MARK: WMPageControllerDelegate
    
    override func pageController(pageController: WMPageController!, didEnterViewController viewController: UIViewController!, withInfo info: [NSObject : AnyObject]!) {
        
        configureTitleView(atIndex: (viewController as! NewsViewController).pageType == .People ? 0 : 1)
    }
    
    // MARK: Actions
    
    @IBAction func didPressBarItem(sender: UIView) {
        let block = {
            switch sender.tag {
            case 10:
                PageRouter.showSideBar()
            case 11:
                PageRouter.showNotifications()
            case 13:
                self.refreshChild()
            default:
                break
            }
        }
        
        if dropDownMenuView.isShown! {
            
            dropDownMenuView.hide()
            
            self.bk_performBlock({ (_) in
                block()
            }, afterDelay: self.dropDownMenuView.animationDuration)
        } else {
            block()
        }
    }
    
    // MARK: titleView => dropdown menu
    
    func configureTitleView(atIndex index: Int) {
        
        if dropDownMenuView == nil {
            let nav = PageRouter.dynamicVC.paneViewController as! UINavigationController
            
            dropDownMenuView = BTNavigationDropdownMenu(navigationController: nav , containerView: PageRouter.dynamicVC.view, title: self.selectedTopic ?? TitleTopic, items: [])
            
            print((currentViewController as? NewsViewController)?.viewModel)
            (currentViewController as? NewsViewController)?.viewModel.loadTopics.apply().start(Signal.Observer { event in
                switch event {
                case let .Next(value):
                    self.itemstopic = value == nil ? [] : ["All"] + value!
                    self.dropDownMenuView.updateItems(self.itemstopic)
                default:
                    break
                }
            })
            
            dropDownMenuView.menuTitleColor = UIColor.whiteColor()
            dropDownMenuView.cellSeparatorColor = UIColor.whiteColor()
            dropDownMenuView.cellBackgroundColor = ThemeColor
            dropDownMenuView.cellTextLabelColor = UIColor.whiteColor()
            dropDownMenuView.maskBackgroundColor = UIColor.blackColor()
            dropDownMenuView.maskBackgroundOpacity = 0.7
            dropDownMenuView.backgroundColor = UIColor.clearColor()
            dropDownMenuView.cellSelectionColor = ThemeColor.darkenByPercentage(0.1)
            dropDownMenuView.selectedCellTextLabelColor = UIColor.whiteColor()
            
            let vv = UIView(frame: CGRectMake(0, 0, Main_Screen_Width - 120, 44))
            vv.addSubview(dropDownMenuView)
            navigationItem.titleView = vv
        }
        
        dropDownMenuView.updateItems(index == 0 ? itemstopic : itemstags)
        dropDownMenuView.setMenuTitle(index == 0 ? TitleTopic : TitleTag)
        dropDownMenuView.setMenuTitle(index == 0 ? selectedTopic : selectedTag)
        dropDownMenuView.layoutSubviews()
        dropDownMenuView.update(selectedString: index == 0 ? selectedTopic ?? TitleTopic : selectedTag ?? TitleTag)
        dropDownMenuView.didSelectItemAtIndexHandler = {[weak self] (indexPath: Int) -> () in
            if index == 0 {
                self?.selectedTopic = (self?.itemstopic[indexPath])!
                (self?.currentViewController as? NewsViewController)?.viewModel.currentTopicNames = [self!.selectedTopic]
            } else {
                self?.selectedTag = (self?.itemstags[indexPath])!
                (self?.currentViewController as? NewsViewController)?.viewModel.currentTagNames = [self!.selectedTag]
            }
            self?.refreshChild()
        }
    }

    func refreshChild() {
        (currentViewController as? NewsViewController)?.loadNews(.LoadFirstPage)
    }
}
