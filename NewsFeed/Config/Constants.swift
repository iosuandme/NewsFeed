//
//  Constants.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/7/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

import Foundation

let Bmob_App_Key     = "31aebd0888a63e165d8552c6b8b2dec8"

let Encrypt_Key     = "9dff7c158e5bfe0d3994d3eefb920b40"
let Encrypt_IV      = "e10d6c6a043a8188e10d6c6a043a8188"

let AppIdentifier   = NSBundle.mainBundle().bundleIdentifier!

let IsFirstTimeLaunchKey = "NewsFeed.IsFirstTimeLaunchKey"
let ReceiveMessageNotification = "NewsFeed.NewMessage.SingleChatRoom"

let Main_Screen_Width = UIScreen.mainScreen().bounds.size.width
let Main_Screen_Height = UIScreen.mainScreen().bounds.size.height

let HashTags = ["Cool", "Fantastic", "Glorious", "Pretty", "Fuck", "Goddess", "Make it", "Soso", "Tmall", "The One", "World Fame", "Fish", "Oceanside", "Brilliant"]

var ImagePlaceHolder: UIImage {
    return UIImage(named: "image_holder")!
}

var AvatarPlaceHolder: UIImage {
    return UIImage(named: "avatar_holder")!
}

func SharedAppDelegate() -> AppDelegate {
    return UIApplication.sharedApplication().delegate as! AppDelegate
}


let (ParallaxHeaderType, SectionHeaderType) = (-1, -2)
func ParallaxHeaderIndexPath(forSection section: Int) -> NSIndexPath {
    return NSIndexPath(forRow: ParallaxHeaderType, inSection: section)
}
func SectionHeaderIndexPath(forSection section: Int) -> NSIndexPath {
    return NSIndexPath(forRow: SectionHeaderType, inSection: section)
}

enum LoadDataType {
    case Refresh, LoadNextPage, LoadLatest
}

// error list
let DeallocError = NSError(domain: "bmob", code: 300, userInfo: [NSLocalizedDescriptionKey:"already dealloced"])
let NilError = NSError(domain: "bmob", code: 301, userInfo: [NSLocalizedDescriptionKey:"object is nil"])

func ParameterError(description: String) -> NSError {
    return NSError(domain: "parameter", code: 400, userInfo: [NSLocalizedDescriptionKey:description])
}

enum DataSourceOperationType {
    case LoadFirstPage                  // => usually corresponding to reloadData() & scrollToTop
    case LoadNextPage                   // => usually corresponding to reloadData()
    case LoadLatest                     // => usually corresponding to reloadData() (& keep the contentOffset)
    case ReloadVisible([NSIndexPath])   // => usually corresponding to reloadData()
}

enum DataSourceNotificationType {
    case ReloadData(Bool)
    
    case InsertSections(NSIndexSet, Bool)
    case DeleteSections(NSIndexSet)
    case ReloadSections(NSIndexSet)
    case MoveSection(Int, Int)
    
    case InsertItemsAtIndexPaths([NSIndexPath], Bool)
    case DeleteItemsAtIndexPaths([NSIndexPath])
    case ReloadItemsAtIndexPaths([NSIndexPath])
    case MoveItemAtIndexPath(NSIndexPath, NSIndexPath)
    
    case ReloadSupplementaryView(String, NSIndexPath)
}

