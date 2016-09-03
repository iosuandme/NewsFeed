//
//  UINavigationItem+backitem.m
//  NewsFeed
//
//  Created by WorkHarder on 8/6/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

#import "UINavigationItem+backitem.h"
#import <Aspects/Aspects.h>

@implementation UINavigationItem (backitem)

+ (void)load {
    
    __block UIBarButtonItem *item;
    [UINavigationItem aspect_hookSelector:@selector(backBarButtonItem) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info){
        
        item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:NULL];
        [[info originalInvocation] setReturnValue:&item];
        
    } error:NULL];

}

@end

