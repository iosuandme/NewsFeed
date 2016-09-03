//
//  AJTagsCell.h
//  TagDemo
//
//  Created by AlienJunX on 16/3/10.
//  Copyright © 2016年 com.alienjun.demo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AJTagsCell : UICollectionViewCell

@property (weak, nonatomic) UIView *bgView;

- (void)setTitleStr:(NSString *)title color:(UIColor *)color;

@end
