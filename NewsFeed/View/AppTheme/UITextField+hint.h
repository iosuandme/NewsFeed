//
//  UITextField+hint.h
//  KidneyPat
//
//  Created by WorkHarder on 7/16/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef BOOL (^FYCheckBlock)(NSString *text);

@interface UITextField (hint)

@property (nonatomic, copy) FYCheckBlock checkBlock;
@property (nonatomic, copy) NSString *errorHint;
@property (nonatomic, retain) UIButton *errorButton;

@end
