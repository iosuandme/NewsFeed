//
//  SingleChatRoomViewController.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/6/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import ReactiveCocoa
import ChameleonFramework

class SingleChatRoomViewController: JSQMessagesViewController {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var onlineStatusLabel: UILabel!
    @IBOutlet var rightBarButtons: [UIButton]!
    @IBOutlet var newMessageButton: UIButton!
    
    var viewModel: ChatViewModel!
    
    // MARK: UIStyles
    lazy var outgoingBubbleImageData: JSQMessagesBubbleImage = {
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        return bubbleFactory.outgoingMessagesBubbleImageWithColor(ThemeColor)
    }()
    
    lazy var incomingBubbleImageData: JSQMessagesBubbleImage? = {
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        return bubbleFactory.incomingMessagesBubbleImageWithColor(UIColor.whiteColor())
    }()
    
    lazy var bubbleFont: UIFont = {
        return UIFont.systemFontOfSize(13)
    }()
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    func configureInputToolBar() {
        
        inputToolbar.contentView.leftBarButtonItem.hidden = true
        inputToolbar.contentView.leftBarButtonItemWidth = 70
        inputToolbar.contentView.rightBarButtonItemWidth = 45

//        let rightButton = UIButton()
//        rightButton
//        inputToolbar.contentView.rightBarButtonItem =
//        /* 菜单面板按钮 */
//        float xx = 18;
//        barLeftBtnMenu = [[VBFPopFlatButton alloc] initWithFrame:CGRectMake(0,0,xx,xx) buttonType:buttonAddType buttonStyle:buttonRoundedStyle animateToInitialState:NO];
//        [barLeftBtnMenu setTintColor:[UIColor whiteColor]];
//        [barLeftBtnMenu setLineThickness:2];
//        [barLeftBtnMenu setRoundBackgroundColor:[ColorManager ThemeColor]];
//        /* 表情按钮 */
//        [barLeftBtnEmoji setHidden:YES];
//        barLeftBtnEmoji = [[UIButton alloc] initWithFrame:CGRectMake(38, 2, 30, 30)];
//        ViewRadius(barLeftBtnEmoji, HEIGHT(barLeftBtnEmoji)/2);
//        [barLeftBtnEmoji setImage:[UIImage imageNamed:@"ic_chat_emote_normal_1"] forState:UIControlStateNormal];
//        [barLeftBtnEmoji setImage:[UIImage imageNamed:@"ic_chat_keyboard_normal_1"] forState:UIControlStateSelected];
//        
//        [self.inputToolbar.contentView.leftBarButtonContainerView addSubview:barLeftBtnEmoji];
//        [self.inputToolbar.contentView.leftBarButtonContainerView addSubview:barLeftBtnMenu];
//        [barLeftBtnMenu mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.centerY.equalTo(barLeftBtnMenu.superview);
//            make.leading.equalTo(barLeftBtnMenu.superview).offset(5);
//            make.width.height.equalTo(@18);
//            }];
//        UIView *btnMenuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 42, HEIGHT(self.inputToolbar))];
//        [btnMenuView setBackgroundColor:ClearColor];
//        [self.inputToolbar.contentView addSubview:btnMenuView];
    }
    
    // MARK: VC life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.senderId = User_Bmob.currentUser()?.objectId
        self.senderDisplayName = User_Bmob.currentUser()?.nickname ?? "我"
        
        self.collectionView.backgroundColor = UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 235.0/255.0, alpha: 1)
        self.collectionView.collectionViewLayout.messageBubbleFont = bubbleFont
        self.collectionView.showsVerticalScrollIndicator = false
        
        self.newMessageButton.hidden = true
        self.view.addSubview(self.newMessageButton)
        self.newMessageButton.snp_makeConstraints { (make) in
            make.top.equalTo(self.topLayoutGuide).offset(20)
            make.trailing.equalTo(self.view)
        }
        self.newMessageButton.layer.shadowOpacity = 1.0
        self.newMessageButton.layer.shadowColor = FlatRed().CGColor
        self.newMessageButton.layer.shadowRadius = 5
        self.newMessageButton.layer.shadowOffset = CGSizeMake(-5, 0)
        self.view.bringSubviewToFront(self.newMessageButton)
        
        self.newMessageButton.rac_signalForControlEvents(.TouchUpInside).subscribeNext { (_) in
            self.viewModel.clearNewMessages()
            self.newMessageButton.hidden = true
            self.finishReceivingMessage()
        }
        
        for btn in rightBarButtons {
            btn.imageView?.contentMode = .Center
        }
        
        DynamicProperty(object: titleLabel, keyPath: "text") <~ viewModel.chatRoomTitle
        viewModel.refreshModel.apply().start { (event) in
            switch event {
            case let .Failed(.ProducerError(err)):
                Toast.showError(err.localizedDescription)
            case .Completed:
                
                self.collectionView.reloadData()
            default:
                print(event)
            }
        }
        
        viewModel.newMessages.signal.observeOn(UIScheduler()).observeNext { (type) in
            let chatRoomHeight = Main_Screen_Height-64-self.inputToolbar.bounds.height
            switch type {
            case (.New,_) where self.collectionView.contentSize.height - self.collectionView.contentOffset.y - chatRoomHeight < 10:
                self.finishReceivingMessage()
            case (.New, let hint):
                self.newMessageButton.hidden = false
                self.newMessageButton.setTitle(hint, forState: .Normal)
                fallthrough
            case (.History, _):
                let bottomOffset = max(self.collectionView.contentSize.height, chatRoomHeight) - self.collectionView.contentOffset.y;
                let orignalOffset = self.collectionView.contentOffset
                
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                
                self.collectionView.performBatchUpdates({
                    self.collectionView.reloadSections(NSIndexSet(index: 0))
                    
                    }, completion: { (finished) in
                        if type.0 == .New {
                            self.collectionView.contentOffset = orignalOffset
                        } else {
                            self.collectionView.contentOffset = CGPointMake(0, max(self.collectionView.contentSize.height - bottomOffset, 0))
                        }
                        
                        CATransaction.commit()
                    })
            }
        }
        
        bindActions()
    }
    
    // MARK: JSQMessages CollectionView DataSource
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.messages.count
    }
    
    // 为 cellForItemAtIndexPath: 服务
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return viewModel.messages[indexPath.item]
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let msg = self.collectionView(collectionView, messageDataForItemAtIndexPath: indexPath)
        
        return msg.senderId() == self.senderId ? outgoingBubbleImageData : incomingBubbleImageData
    }

    // 头像
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let msg = self.collectionView(collectionView, messageDataForItemAtIndexPath: indexPath)
        
        let pic = viewModel.heads[msg.senderId()]
        if pic is JSQMessagesAvatarImage {
            return pic as! JSQMessagesAvatarImage
        } else if pic == nil {
        
            viewModel.loadAvatar(viewModel.users[msg.senderId()]!).apply()
                .observeOn(UIScheduler())
                .start { (event) in
                    switch event {
                    case .Completed:
                        collectionView.reloadData()
                    case let .Failed(.ProducerError(err)):
                        Toast.showError(err.localizedDescription)
                    default:
                        print(event)
                    }
            }
        }
        
        return viewModel.holder;
    }
    

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let msg = viewModel.messages[indexPath.item]
        (cell as? JSQCellState)?.update(Message_Bmob.MessageState.initWithRawValue(msg.messageState ?? 0, progress: 0))
        
        return cell
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 200 && viewModel.hasMoreHistory && !self.viewModel.loadNextPageAction.executing.value {
            self.viewModel.loadNextPageAction.apply(0).start()
        }
    }
    
    
    // MARK: bindings
    
    func bindActions() {

        self.rac_signalForSelector(#selector(viewWillAppear(_:))).subscribeNext { (_) in
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            if self.viewModel.messages.count == 0 {
                self.viewModel.loadNextPageAction.apply(0).start()
            }
        }
    }
    
    // MARK: Actions
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        viewModel.sendText(text) { (indexPath, state) in
            if indexPath == nil {
                self.finishSendingMessage()
            } else {
                let cell = self.collectionView.cellForItemAtIndexPath(indexPath!) as? JSQMessagesCollectionViewCellOutgoing
                cell?.update(state)
            }
        }
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        SLImagePicker.pickImage(fromViewController: self) { (images) in
            if images.count > 0 {
                self.viewModel.sendImage(images[0]) { (indexPath, state) in
                    if indexPath == nil {
                        self.finishSendingMessage()
                    } else {
                        let cell = self.collectionView.cellForItemAtIndexPath(indexPath!) as? JSQMessagesCollectionViewCellOutgoing
                        cell?.update(state)
                    }
                }
            }
        }
    }
    
    @IBAction func rightItemClick(sender: UIButton) {
        print(sender.tag)
    }
}
