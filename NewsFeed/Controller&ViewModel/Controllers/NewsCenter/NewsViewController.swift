//
//  NewsViewController.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/17/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

import ReactiveCocoa
import Result
import MJRefresh

class NewsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, CollectionCellAction, SVLEmptyListDelegate {
    
    enum PageType {
        case People, HashTags
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addButton: UIButton!
    var emptyStyle: EmptyListStyle!
    
    let NewsCellIdentifier = "NewsCenterCell"
    var pageType = PageType.People
    
    var viewModel = NewsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeViews()
        
        addButton.rac_signalForControlEvents(.TouchUpInside)
            .subscribeNext { (_) in
                PageRouter.showPublishPage()
            }
        
        viewModel.dataSourceNotification.0.observeOn(UIScheduler()).observeNext { (type) in
            switch type {
            case let .ReloadData(noMoreData):
                self.collectionView.reloadData()
                if self.viewModel.newsDatasource.count > 0 {
                    self.collectionView.scrollToItemAtIndexPath( NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Bottom, animated: true)
                }
                if !noMoreData {
                    self.collectionView.mj_footer.resetNoMoreData()
                } else {
                    self.collectionView.mj_footer.endRefreshingWithNoMoreData()
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
        
        if viewModel.newsDatasource.count > 0 {
            viewModel.reloadVisible.apply(self.collectionView.indexPathsForVisibleItems()).start()
        } else {
            loadNews(.LoadFirstPage)
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.newsDatasource.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NewsCellIdentifier, forIndexPath: indexPath) as! NewsCenterCell
        
        cell.configureCell(withBaseData: viewModel.newsDatasource[indexPath.row], collectionView: collectionView, indexPath: indexPath, delegate: self)
        cell.configureCell(withRemoteOrLocalData: viewModel.newsDatasource[indexPath.row])
        
        cell.contentView.backgroundColor = indexPath.row % 2 == 1 ? UIColor(red: 248/255.0, green: 248/255.0, blue: 248/255.0, alpha: 1) : UIColor.whiteColor()
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if viewModel.newsDatasource[indexPath.row]["comments"] == nil {
            viewModel.loadComments().apply(indexPath.row).start(Signal.Observer { event in

                switch event {
                case let .Failed(.ProducerError(err)):
                    Toast.showError(err.localizedDescription)
                case let .Next(index):
                    collectionView.performBatchUpdates({ 
                        collectionView.reloadItemsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)])
                    }, completion:nil)
                default:
                    print(event)
                }
            })
        }
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let height = NewsCenterCell.heightFor(viewModel.newsDatasource[indexPath.row])
        return CGSizeMake(Main_Screen_Width, height)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        viewModel.showNewsDetail.apply(indexPath.row).start()
    }
    
    // MARK: CollectionCellAction
    
    func collectionView(collectionView: UICollectionView, didTriggerAction: Int, atIndexPath indexPath: NSIndexPath) {
        switch didTriggerAction {
        case NewsCenterCell.NewsCellAction.Share.rawValue:
            print("share button clicked at indexPath: \(indexPath)")
        case NewsCenterCell.NewsCellAction.Comment.rawValue:
            viewModel.showCommentPage(forNewsAtIndexPath: indexPath)
        case NewsCenterCell.NewsCellAction.Like.rawValue:
            viewModel.likeNewsAction.apply(indexPath.row).start({ (event) in
                switch event {
                case let .Failed(.ProducerError(error)):
                    Toast.showError(error.localizedDescription)
                default:
                    break
                }
            })
        case NewsCenterCell.NewsCellAction.Avatar.rawValue:
            viewModel.showProfileFor(indexPath, vc: self)
        default:
            break
        }
    }
    
    // MARK: Private Methods
    
    func initializeViews() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self

        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.backgroundColor = UIColor.whiteColor()
        self.collectionView.registerNib(UINib(nibName: NewsCellIdentifier, bundle: nil), forCellWithReuseIdentifier: NewsCellIdentifier)
        
        self.emptyStyle = EmptyListStyle(withScrollView: self.collectionView, delegate: self)
        
        collectionView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {
            self.loadNews(.LoadNextPage)
        })
    }
    
    // MARK: EmptyListStyle
    
    func configurationsForEmpty() -> (image: EmptyImageType, title: String?, description: String?, buttonTitle: String?, didTapButton: (() -> Void)?) {
        return (.AddNews, "Empty Result", "there is nothing", "Add one", {
            PageRouter.showPublishPage()
        })
    }

    func loadNews(type: DataSourceOperationType) {
        var action: Action<DataSourceOperationType, (), NSError>
        if pageType == .People {
            action = viewModel.dataSourceOperationWithTopic
        } else {
            action = viewModel.dataSourceOperationWithTag
        }
        
        action.apply(type).startWithFailed({ (error) in
            switch error {
            case let .ProducerError(err):
                Toast.showError(err.localizedDescription)
            case .NotEnabled:
                break
            }
        })
    }
}
