//
//  WMMenuView+frame.m
//  NewsFeed
//
//  Created by WorkHarder on 8/18/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

#import "WMMenuView+frame.h"
#import <Aspects/Aspects.h>
#import <WMPageController/WMMenuView.h>

@implementation WMMenuView (frame)


/**
 *  hack WMMenuView: Dangerous，if the version updated you must check this
 */
+ (void)load {
    [WMMenuView aspect_hookSelector:NSSelectorFromString(@"calculateItemFrames") withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info) {
        
        WMMenuView *weakSelf = [info instance];
        
        CGFloat contentWidth = [weakSelf itemMarginAtIndex:0];
        
        for (int i = 0; i < [weakSelf.dataSource numbersOfTitlesInMenuView:weakSelf]; i++) {
            CGFloat itemW = 60.0;
            if ([weakSelf.delegate respondsToSelector:@selector(menuView:widthForItemAtIndex:)]) {
                itemW = [weakSelf.delegate menuView:weakSelf widthForItemAtIndex:i];
            }
            CGRect frame = CGRectMake(contentWidth, 0, itemW, weakSelf.frame.size.height);
            // 记录frame
            [[weakSelf valueForKey:@"frames"] addObject:[NSValue valueWithCGRect:frame]];
            contentWidth += itemW + [weakSelf itemMarginAtIndex:i+1];
        }
        [[weakSelf valueForKey:@"scrollView"] setContentSize:CGSizeMake(contentWidth, weakSelf.frame.size.height)];
    } error:nil];
}

- (CGFloat)itemMarginAtIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(menuView:itemMarginAtIndex:)]) {
        return [self.delegate menuView:self itemMarginAtIndex:index];
    }
    return 0.0;
}

@end
