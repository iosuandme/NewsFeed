//
//  AJTagsCell.m
//  TagDemo
//
//  Created by AlienJunX on 16/3/10.
//  Copyright © 2016年 com.alienjun.demo. All rights reserved.
//

#import "AJTagsCell.h"
@interface AJTagsCell()

@property (weak, nonatomic) UILabel *label;
@end

@implementation AJTagsCell

- (void)setTitleStr:(NSString *)title color:(UIColor *)color {
    if (self.bgView == nil) {
        UIView *bgView = [[UIView alloc] init];
        [self.contentView addSubview:bgView];
        bgView.translatesAutoresizingMaskIntoConstraints = NO;
        self.bgView = bgView;
        bgView.layer.cornerRadius = 3;
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_bgView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_bgView)]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_bgView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_bgView)]];
    }
    if (self.label == nil) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:14.0];
        label.textColor = UIColor.whiteColor;
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:label];
        self.label = label;
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_label]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_label)]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_label]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_label)]];
    }
    
    self.label.text = title;
    self.bgView.backgroundColor = color;
    if ([color isEqual:[UIColor whiteColor]]) {
        self.label.textColor = [UIColor darkGrayColor];
    } else {
        self.label.textColor = [UIColor whiteColor];
    }
}

@end
