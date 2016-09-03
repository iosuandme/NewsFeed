//
//  SelfProfileViewController.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/7/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

import UIKit
import CSStickyHeaderFlowLayout
import ReactiveCocoa
import MSDynamicsDrawerViewController
import MJRefresh

class SelfProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, CollectionCellAction {

    let spacing: CGFloat = 3.0;
    @IBOutlet weak var collectionView: UICollectionView!

    var viewModel: ProfileViewModel!
    var headers: [String:BaseActionReusableView?] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initilizeCollectionView()
        viewModel.userInfo.signal.observeNext { (data) in
            for header in self.headers.values {
                header?.updateCell(withBaseData: data)
            }
        }
        
        viewModel.dataSourceNotification.0.observeNext { (type) in
            print(type)
            switch type {
            case let .ReloadData(noMoreData):
                self.collectionView.reloadData()
                
                if !noMoreData {
                    self.collectionView.mj_footer.resetNoMoreData()
                }
            case let .InsertItemsAtIndexPaths(indexPaths, noMoreData):
                self.collectionView.insertItemsAtIndexPaths(indexPaths)
                if noMoreData {
                    self.collectionView.mj_footer.endRefreshingWithNoMoreData()
                } else {
                    self.collectionView.mj_footer.endRefreshing()
                }
            case .ReloadItemsAtIndexPaths:
                self.collectionView.reloadData()
            default:
                break
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.dataSourceOperation.apply(self.viewModel.dataSource.count > 0 ? .LoadLatest : .LoadFirstPage).start()
        viewModel.refreshModel()
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView.mj_footer.hidden = viewModel.dataSource.count == 0
        return max(viewModel.dataSource.count, 1)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NewsPicCellIdentifier, forIndexPath: indexPath) as! NewsPicCell
        
        if viewModel.dataSource.count > 0 {
            cell.noneHintLabel.superview?.hidden = true
            
            let dic = viewModel.dataSource[indexPath.row]
            cell.imageView.sd_setImageWithURL(dic["image"] as? NSURL, placeholderImage: ImagePlaceHolder)
            
        } else {
            cell.noneHintLabel.superview?.hidden = false
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        var identifier: String!
        switch kind {
        case CSStickyHeaderParallaxHeader:
            identifier = SelfProfileHeaderIdentifier
        case UICollectionElementKindSectionHeader:
            identifier = SectionHeaderIdentifier
        default:
            assertionFailure("SupplementaryElementOfKind: \(kind) is not allowed")
        }
        
        let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: identifier, forIndexPath: indexPath) as! BaseActionReusableView
        headers[identifier] = view
        
        view.configureCell(withBaseData: viewModel.userInfo.value, collectionView: collectionView, indexPath: indexPath, delegate: self)
        
        return view
        
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        viewModel.showNewsDetail.apply(indexPath.row).start()
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if viewModel.dataSource.count == 0 {
            return CGSizeMake(Main_Screen_Width, Main_Screen_Height - 310 - 40)
        } else {
            let width = (UIScreen.mainScreen().bounds.size.width - 2*spacing)/3;
            return CGSizeMake(width, width);
        }
    }
    
    
    // MARK: Actions
    func collectionView(collectionView: UICollectionView, didTriggerAction: Int, atIndexPath indexPath: NSIndexPath) {
        
        switch (indexPath.row, indexPath.section) {
        case (ParallaxHeaderType, _):
            switch SelfProfileHeader.HeaderAction(rawValue: didTriggerAction)! {
            case .Menu:
                PageRouter.showSideBar()
            case .Message:
                performSegueWithIdentifier("ShowNotifications", sender: nil)
            case .WriteNews:
                PageRouter.showPublishPage()
            }
        case (SectionHeaderType, _):
            switch SectionHeader.HeaderAction(rawValue: didTriggerAction)! {
            case .GridLayout:
                print("did click grid layout button")
            case .ListLayout:
                print("did click list layout button")
            }
        default:
            assertionFailure("this indexpath is not allowed")
        }
    }
    
    // MARK: Rotate
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        relayoutCollectionView(toInterfaceOrientation)
    }
    
    let NewsPicCellIdentifier       = "NewsPicCell"
    let SectionHeaderIdentifier     = "SectionHeader"
    let SelfProfileHeaderIdentifier = "SelfProfileHeader"
    
    func initilizeCollectionView() -> Void {
        self.collectionView.backgroundColor = UIColor.whiteColor()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.showsVerticalScrollIndicator = false

        
        // Setup Headers & Cell
        self.collectionView?.registerNib(UINib(nibName: SelfProfileHeaderIdentifier, bundle: nil), forSupplementaryViewOfKind: CSStickyHeaderParallaxHeader, withReuseIdentifier: SelfProfileHeaderIdentifier)
        self.collectionView?.registerNib(UINib(nibName: SectionHeaderIdentifier, bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: SectionHeaderIdentifier)
        self.collectionView?.registerNib(UINib(nibName: NewsPicCellIdentifier, bundle: nil), forCellWithReuseIdentifier: NewsPicCellIdentifier)
        
        collectionView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {
            self.loadNews(.LoadNextPage)
        })
        
        relayoutCollectionView(UIApplication.sharedApplication().statusBarOrientation)
    }
    
    func relayoutCollectionView(orientation: UIInterfaceOrientation) {
        
        let width = UIInterfaceOrientationIsPortrait(orientation) ? min(view.bounds.width, view.bounds.height) : max(view.bounds.width, view.bounds.height);
        
        let layout = collectionView.collectionViewLayout as! CSStickyHeaderFlowLayout
        
        layout.parallaxHeaderReferenceSize = CGSizeMake(width, 310)
        layout.parallaxHeaderMinimumReferenceSize = CGSizeMake(width, 64)
        layout.parallaxHeaderAlwaysOnTop = true
        
        layout.headerReferenceSize = CGSizeMake(width, 40)
        
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.sectionInset = UIEdgeInsetsMake(1, 0, 1, 0)
        layout.disableStickyHeaders = false;
    }
    
    func loadNews(type: DataSourceOperationType) {
        viewModel.dataSourceOperation.apply(type).startWithFailed { (error) in
            switch error {
            case let .ProducerError(err):
                Toast.showError(err.localizedDescription)
            case .NotEnabled:
                break
            }
        }
    }
    
    // MARK: Style
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
}
