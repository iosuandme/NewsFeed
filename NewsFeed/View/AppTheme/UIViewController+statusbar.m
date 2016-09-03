
//
//  UIViewController+statusbar.m
//  NewsFeed
//
//  Created by WorkHarder on 8/16/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

#import "UIViewController+statusbar.h"
#import <Aspects/Aspects.h>

@implementation UIViewController (statusbar)

+ (void)load {
    [UIViewController aspect_hookSelector:@selector(preferredStatusBarStyle) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info){
        UIStatusBarStyle style = UIStatusBarStyleLightContent;
        [[info originalInvocation] setReturnValue:&style];
    } error:nil];
}

@end
