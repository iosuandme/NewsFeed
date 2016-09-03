
//
//  CommentViewController.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/23/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

import RSKGrowingTextView
import ReactiveCocoa

class CommentViewController: UIViewController {

    @IBOutlet weak var tagsView: AJTagsView!
    @IBOutlet weak var textView: RSKGrowingTextView!
    @IBOutlet weak var submitButton: UIButton!
    
    var viewModel: CommentViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Comment"
        var idx = 0
        let arr = HashTags.map({ (tagName) -> AJTagModel in
            let ajtag = AJTagModel()
            
            ajtag.color = UIColor.lightGrayColor()
            ajtag.text = tagName
            ajtag.index = idx
            idx += 1
            
            return ajtag
        })
        tagsView.originDataList = NSMutableArray(array: arr)
        tagsView.reloadDataInfo()
        
        RAC(viewModel, "comment") <~ textView.rac_textSignal()
        
        submitButton.rac_signalForControlEvents(.TouchUpInside).subscribeNext { (_) in
            self.viewModel.tags = self.tagsView.tagsSelectedList()
            self.viewModel.commentAction.apply().start { event in
                switch event {
                case let .Failed(.ProducerError(err)):
                    Toast.showError(err.localizedDescription)
                case .Completed:
                    self.navigationController?.popViewControllerAnimated(true)
                    fallthrough
                default:
                    print(event)
                    Toast.dismiss()
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}