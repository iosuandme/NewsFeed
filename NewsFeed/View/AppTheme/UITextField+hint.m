//
//  UITextField+hint.m
//  KidneyPat
//
//  Created by WorkHarder on 7/16/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

#import "UITextField+hint.h"
#import <objc/runtime.h>

@implementation UITextField (hint)

#pragma mark - Catagory Set/Get

- (FYCheckBlock)checkBlock{
    return objc_getAssociatedObject(self, @selector(checkBlock));
}

-(void)setCheckBlock:(FYCheckBlock)checkBlock{
    objc_setAssociatedObject(self, @selector(checkBlock), checkBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(NSString *)errorHint{
    return objc_getAssociatedObject(self, @selector(errorHint));
}

-(void)setErrorHint:(NSString *)errHint{
    objc_setAssociatedObject(self, @selector(errorHint), errHint, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setErrorButton:(UIButton *)btn {
    objc_setAssociatedObject(self, @selector(errorButton), btn, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIButton *)errorButton {
    return objc_getAssociatedObject(self, @selector(errorButton));
}

@end
