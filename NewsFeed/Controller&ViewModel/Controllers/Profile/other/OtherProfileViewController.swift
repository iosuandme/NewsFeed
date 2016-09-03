//
//  OtherProfileViewController.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/21/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

import ReactiveCocoa
import CSStickyHeaderFlowLayout
import MJRefresh

class OtherProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, CollectionCellAction  {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var messageButton: UIButton!
    
    var header: BaseActionReusableView?
    var viewModel: ProfileViewModel!
    let NewsCellIdentifier = "OtherProfileCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeViews()
        
        messageButton.rac_signalForControlEvents(.TouchUpInside).subscribeNext { [weak self] (_) in
            if let strongSelf = self {
                let user = strongSelf.viewModel.user
                PageRouter.showChatRoom(forUser: user.objectId, nickname: user.nickname, avatarURL: user.thumbURL)
            }
        }
        
        viewModel.userInfo.signal.observeNext { (data) in
            self.header?.updateCell(withBaseData: data)
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
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        viewModel.dataSourceOperation.apply(self.viewModel.dataSource.count > 0 ? .ReloadVisible(collectionView.indexPathsForVisibleItems()) : .LoadFirstPage).start()
        viewModel.refreshModel()
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView.mj_footer.hidden = viewModel.dataSource.count == 0
        return viewModel.dataSource.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NewsCellIdentifier, forIndexPath: indexPath) as! OtherProfileCell
        
        cell.configureCell(withBaseData: viewModel.dataSource[indexPath.row], collectionView: collectionView, indexPath: indexPath, delegate: self)
        cell.configureCell(withRemoteOrLocalData: viewModel.dataSource[indexPath.row])
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let height = OtherProfileCell.heightFor(viewModel.dataSource[indexPath.row])
        return CGSizeMake(Main_Screen_Width, height)
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        if kind == CSStickyHeaderParallaxHeader {
            let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: OtherProfileHeaderIdentifier, forIndexPath: indexPath) as! OtherProfileHeader
            
            let newPath = NSIndexPath(forItem: -1, inSection: indexPath.section)
            view.configureCell(withBaseData: viewModel.userInfo.value, collectionView: collectionView, indexPath: newPath, delegate: self)
            self.header = view
            
            return view
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        viewModel.showNewsDetail.apply(indexPath.row).start()
    }
    
    // MARK: CollectionCellAction
    
    func collectionView(collectionView: UICollectionView, didTriggerAction: Int, atIndexPath indexPath: NSIndexPath) {
        if indexPath.row < 0 {
            switch OtherProfileHeader.CellAction(rawValue: didTriggerAction)! {
            case .Menu:
                PageRouter.showSideBar()
            case .Search:
                print("search button clicked")
            case .More:
                print("more button clicked")
            case .Follow:
                viewModel.followAction.apply().start({ (event) in
                    switch event {
                    case let .Failed(.ProducerError(err)):
                        Toast.showError(err.localizedDescription)
                    case .Completed:
                        Toast.showSuccess(self.viewModel.user.info.follow == .FollowedByMe ? "follow success" : "unfollow success")
                    default:
                        print(event)
                    }
                })
            }
        } else {
            switch OtherProfileCell.CellAction(rawValue: didTriggerAction)! {
            case .Share:
                print("share button clicked at indexPath: \(indexPath)")
            case .Comment:
                viewModel.showCommentPage(forNewsAtIndexPath: indexPath)
            case .Like:
                viewModel.likeNewsAction.apply(indexPath.row).start({ (event) in
                    switch event {
                    case let .Failed(.ProducerError(error)):
                        Toast.showError(error.localizedDescription)
                    default:
                        break
                    }
                })
            }
        }
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
    
    // MARK: Rotate & Layout
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        relayoutCollectionView(toInterfaceOrientation)
    }
    
    let OtherProfileHeaderIdentifier = "OtherProfileHeader"
    func initializeViews() {
        messageButton.hidden = (viewModel.user.objectId == User_Bmob.currentUser()?.objectId)
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        self.collectionView.backgroundColor = UIColor(red: 232.0/255.0, green: 233.0/255.0, blue: 234.0/255.0, alpha: 1)
        self.collectionView.showsVerticalScrollIndicator = false
        
        // Setup Header & Cell
        self.collectionView?.registerNib(UINib(nibName: OtherProfileHeaderIdentifier, bundle: nil), forSupplementaryViewOfKind: CSStickyHeaderParallaxHeader, withReuseIdentifier: OtherProfileHeaderIdentifier)
        self.collectionView.registerNib(UINib(nibName: NewsCellIdentifier, bundle: nil), forCellWithReuseIdentifier: NewsCellIdentifier)
        
        relayoutCollectionView(UIApplication.sharedApplication().statusBarOrientation)
        
        collectionView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {
            self.loadNews(.LoadNextPage)
        })
    }
    
    func relayoutCollectionView(orientation: UIInterfaceOrientation) {
        
        let width = UIInterfaceOrientationIsPortrait(orientation) ? min(view.bounds.width, view.bounds.height) : max(view.bounds.width, view.bounds.height);
        
        let layout = collectionView.collectionViewLayout as! CSStickyHeaderFlowLayout
        
        layout.parallaxHeaderReferenceSize = CGSizeMake(width, 464)
        layout.parallaxHeaderMinimumReferenceSize = CGSizeMake(width, 88)
        layout.parallaxHeaderAlwaysOnTop = true
        
        layout.minimumLineSpacing = 2
        layout.sectionInset = UIEdgeInsetsMake(2, 0, 0, 0)
    }

}
