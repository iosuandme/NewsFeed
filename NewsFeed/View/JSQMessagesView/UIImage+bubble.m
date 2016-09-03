//
//  UIImage+bubble.m
//  NewsFeed
//
//  Created by WorkHarder on 8/6/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

#import "UIImage+bubble.h"
#import <Aspects/Aspects.h>
#import <objc/runtime.h>

@implementation UIImage (bubble)

+ (void)load {
    __block UIImage *image;
    [objc_getMetaClass("UIImage") aspect_hookSelector:NSSelectorFromString(@"jsq_bubbleCompactImage") withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> info) {
        image = [UIImage imageNamed:@"bubble"];
        [[info originalInvocation] setReturnValue:&image];
    } error:NULL];
}

@end
