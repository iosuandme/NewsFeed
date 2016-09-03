//
//  SelectTopicsViewController.swift
//  DemoApp
//
//  Created by WorkHarder on 8/6/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

import UIKit
import SDWebImage
import ReactiveCocoa

class TopicCell: BaseActionCell {
    
    @IBOutlet weak var topicBackgroundImageView: UIImageView!
    @IBOutlet weak var topicMaskView: UIView!
    @IBOutlet weak var selectedMaskView: UIView!
    @IBOutlet weak var topicNameLabel: UILabel!

    override func configureCell(withBaseData data: [String : AnyObject?], collectionView: UICollectionView?, indexPath: NSIndexPath, delegate: CollectionCellAction?) {
        super.configureCell(withBaseData: data, collectionView: collectionView, indexPath: indexPath, delegate: delegate)
        
        topicNameLabel.text = data["name"] as? String
        topicBackgroundImageView.sd_setImageWithURL(data["image"] as? NSURL, placeholderImage: ImagePlaceHolder)
        UIView.animateWithDuration(0.25) { () -> Void in
            self.selectedMaskView.alpha = self.selected ? 1 : 0
        }
        
        if selected {
            collectionView!.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition.None)
        } else {
            collectionView!.deselectItemAtIndexPath(indexPath, animated: false)
        }
    }
    
    override func prepareForReuse() {
        self.selectedMaskView.alpha = 0
    }
}

class SelectTopicsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, CollectionCellAction {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var viewModel = SelectTopicsViewModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = true
        
        self.searchTopics()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func continueButtonClicked() {
        let selecteds = self.collectionView.indexPathsForSelectedItems()?.map({ (path: NSIndexPath) -> Int in
            return path.row
        })
        viewModel.likeTopics(selecteds) { (success, error) in
            if success {
                PageRouter.showMainInterface()
            } else {
                Toast.showInfo(error.localizedDescription)
            }
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.topiclistForView.count;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let topicCell = collectionView.dequeueReusableCellWithReuseIdentifier("TopicCell", forIndexPath: indexPath) as! TopicCell
        
        topicCell.selected = viewModel.likedIds.contains(viewModel.topiclist[indexPath.row].objectId)
        topicCell.configureCell(withBaseData: viewModel.topiclistForView[indexPath.row], collectionView: collectionView, indexPath: indexPath, delegate: self)
        
        return topicCell;
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let width = (UIScreen.mainScreen().bounds.size.width - 12*2 - 6*2)/3
        
        return CGSize(width: width, height: width)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        viewModel.likedIds.insert(viewModel.topiclist[indexPath.row].objectId)
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? TopicCell {
            UIView.animateWithDuration(0.25) { () -> Void in
                cell.selectedMaskView.alpha = cell.selected ? 1 : 0
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        viewModel.likedIds.remove(viewModel.topiclist[indexPath.row].objectId)
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? TopicCell {
            UIView.animateWithDuration(0.25) { () -> Void in
                cell.selectedMaskView.alpha = cell.selected ? 1 : 0
            }
        }
    }
    

    // MARK: CollectionCellAction
    
    func collectionView(collectionView: UICollectionView, didTriggerAction: Int, atIndexPath indexPath: NSIndexPath) {

    }

    @IBOutlet weak var searchTextField: UITextField!
    // MARK: Actions
    @IBAction func searchTopics() {
        
        let trimName = self.searchTextField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())

        viewModel.searchTopics.apply(trimName)
            .start(Signal.Observer { event in
                switch event {
                case let .Failed(.ProducerError(err)):
                    Toast.showError(err.localizedDescription)
                case .Next: fallthrough
                case .Completed:
                    self.collectionView.reloadData()
                default:
                    print(event)
                }
        })
        
    }
}
