//
//  HLUIAutoTest.h
//  HLUIAutoTest
//
//  Created by 刘华龙 on 2018/8/28.
//  Copyright © 2018年 liuhualong. All rights reserved.
//

#import <UIKit/UIKit.h>
static NSString * const kAutoTestUIKey = @"isAutoTestUI";

@interface HLUIAutoTest : NSObject <UIGestureRecognizerDelegate>

@property (nonatomic, getter=isLongPressEnabled) BOOL longPressEnabled;
+ (instancetype)sharedInstance;

@end

@interface NSObject (HLUIAutoTest)

+ (void)swizzleSelector:(SEL)originalSelector withAnotherSelector:(SEL)swizzledSelector;

@end
