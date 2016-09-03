//
//  PublishNewsViewController.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/15/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

import ImagePicker
import RSKGrowingTextView
import DropDown
import ReactiveCocoa

class PublishNewsViewController: UIViewController {
    
    @IBOutlet weak var keyboardToggleButton: UIButton!
    @IBOutlet weak var selectPicturesButton: UIButton!
    @IBOutlet weak var selectPicturesButtonBig: UIButton!
    @IBOutlet weak var textView: RSKGrowingTextView!
    @IBOutlet weak var accessoryView: UIView!
    @IBOutlet weak var selectTopicButton: UIButton!
    @IBOutlet weak var publishButton: UIButton!
    
    var topics: [Topic_Bmob] = []
    var dropdown = DropDown()
    
    var image: UIImage?
    
    let imagePicker = ImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        keyboardToggleButton.imageView?.contentMode = .ScaleAspectFit
        selectPicturesButton.imageView?.contentMode = .ScaleAspectFit
        textView.inputAccessoryView = accessoryView
        
        selectPicturesButtonBig.layer.borderColor = UIColor.whiteColor().CGColor
        selectPicturesButtonBig.layer.borderWidth = 3
        
        TopicService.searchTopic(byName: nil) { (topics, error) in
            if error == nil {
                self.topics = topics
                self.dropdown.dataSource = topics.map { $0.name }
            }
        }
        
        dropdown.direction = .Bottom
        dropdown.anchorView = selectTopicButton
        dropdown.bottomOffset = CGPoint(x: 0, y: (dropdown.anchorView as! UIView).bounds.height)
        dropdown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.selectTopicButton.setTitle(item, forState: .Normal)
        }
        
        bindActions()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func bindActions() {
        selectPicturesButton.rac_signalForControlEvents(.TouchUpInside)
            .merge(selectPicturesButtonBig.rac_signalForControlEvents(.TouchUpInside))
            .subscribeNext { (_) in
                SLImagePicker.pickImage(fromViewController: self, limit: 1, block: { (images) in
                    self.image = images[0]
                    self.selectPicturesButtonBig.setImage(self.image, forState: .Normal)
                })
            }
        
        selectTopicButton.rac_signalForControlEvents(.TouchUpInside)
            .subscribeNext { (_) in
                self.dropdown.show()
            }
        
        keyboardToggleButton.rac_signalForControlEvents(.TouchUpInside)
            .subscribeNext { (_) in
                if self.textView.isFirstResponder() {
                    self.textView.resignFirstResponder()
                } else {
                    self.textView.becomeFirstResponder()
                }
            }
        
        publishButton.rac_signalForControlEvents(.TouchUpInside)
            .subscribeNext { (_) in
                if self.textView.text.characters.count < 3 {
                    Toast.showInfo("description must longer than three")
                } else if self.image == nil {
                    Toast.showInfo("please choose a photo")
                } else if let index = self.dropdown.indexForSelectedRow  {
                    let topicId = self.topics[index].objectId
                    Toast.show("publishing")
                    NewsService.publishNews(self.image!, text: self.textView.text, relatedToTopic: topicId, block: { (success, error) in
                        if success {
                            self.navigationController?.popViewControllerAnimated(true)
                            Toast.showSuccess("Publish Success!")
                        } else {
                            Toast.showError(error.localizedDescription)
                        }
                    })
                } else {
                    Toast.showInfo("please select a topic for your photo")
                }
            }
    }
    
    // MARK: ViewController Style
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent;
    }
}