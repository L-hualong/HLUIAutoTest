//
//  HLUIAutoTest.m
//  HLUIAutoTest
//
//  Created by 刘华龙 on 2018/8/28.
//  Copyright © 2018年 liuhualong. All rights reserved.
//

#import "HLUIAutoTest.h"
#import <objc/runtime.h>

@implementation HLUIAutoTest

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static HLUIAutoTest *_instance;
    dispatch_once(&onceToken, ^{
        _instance = [HLUIAutoTest new];
    });
    return _instance;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([otherGestureRecognizer.view isDescendantOfView:gestureRecognizer.view]) {
        return YES;
    }
    if (![otherGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        return YES;
    }
    return NO;
}

@end

@implementation NSObject (HLUIAutoTest)

+ (void)swizzleSelector:(SEL)originalSelector withAnotherSelector:(SEL)swizzledSelector
{
    Method originalMethod = class_getInstanceMethod(self, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(self, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(self,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(self,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end
