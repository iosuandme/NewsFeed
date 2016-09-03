//
//  NotificationsViewController.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/16/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

import ReactiveCocoa
import DZNEmptyDataSet
import MJRefresh

class NotificationsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, CollectionCellAction, SVLEmptyListDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var viewModel = NotificationViewModel()
    var emptyStyle: EmptyListStyle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeViews()
        viewModel.dataSourceNotification.0.observeNext { (type) in
            switch type {
            case let .ReloadData(noMoreData):
                self.collectionView.reloadData()
                if self.viewModel.messagesForView.count > 0 {
                    self.collectionView.scrollToItemAtIndexPath( NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Bottom, animated: true)
                }
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
            default: break
            }
        }
        viewModel.loadNextPageAction.apply(.LoadFirstPage).start()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.messagesForView.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NotificationCellIdentifier, forIndexPath: indexPath) as! NotificationCell
        
        cell.configureCell(withBaseData: viewModel.messagesForView[indexPath.row], collectionView: collectionView, indexPath: indexPath, delegate: self)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        viewModel.didSelectCell(atIndexPath: indexPath)
    }
    
    // MARK: CollectionCellAction
    
    func collectionView(collectionView: UICollectionView, didTriggerAction: Int, atIndexPath indexPath: NSIndexPath) {

    }
    
    func configurationsForEmpty() -> (image: EmptyImageType, title: String?, description: String?, buttonTitle: String?, didTapButton: (() -> Void)?) {
        return (.NoNotification, "Empty Result", "there is nothing", nil, nil)
    }
    
    // MARK: Private Methods
    
    let NotificationCellIdentifier = "NotificationCell"
    func initializeViews() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        self.collectionView.backgroundColor = UIColor(red: 232.0/255.0, green: 233.0/255.0, blue: 234.0/255.0, alpha: 1)
        self.collectionView.showsVerticalScrollIndicator = false
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumLineSpacing = 1
        layout.itemSize = CGSizeMake(Main_Screen_Width, 86)
        
        self.collectionView.registerNib(UINib(nibName: NotificationCellIdentifier, bundle: nil), forCellWithReuseIdentifier: NotificationCellIdentifier)
        
        emptyStyle = EmptyListStyle(withScrollView: collectionView, delegate: self)
        
        collectionView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: { 
            self.viewModel.loadNextPageAction.apply(.LoadNextPage).start()
        })
    }
}
