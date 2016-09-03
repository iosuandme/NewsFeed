//
//  AJTagsView.h
//  TagDemo
//
//  Created by AlienJunX on 16/3/10.
//  Copyright © 2016年 com.alienjun.demo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AJTagsCell.h"
#import "AJTagModel.h"

@protocol AJTagsViewDelegate <NSObject>

//选中的标签
- (NSMutableArray *)tagsSelectedList;

//全部标签
- (NSMutableArray *)tagsOriginDataList;

@end

@interface AJTagsView : UICollectionView

@property (strong, nonatomic) NSMutableArray *originDataList;
@property (strong, nonatomic) NSMutableArray *selectedList;

- (void)reloadDataInfo;

- (NSArray<NSString *> *)tagsSelectedList;

@end
