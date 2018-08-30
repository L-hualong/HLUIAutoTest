//
//  UIView+HLUIAutoTest.m
//  HLUIAutoTest
//
//  Created by 刘华龙 on 2018/8/28.
//  Copyright © 2018年 liuhualong. All rights reserved.
//

#import "UIView+HLUIAutoTest.h"
#import "UIResponder+HLUIAutoTest.h"
#import "HLUIAutoTest.h"
#import <objc/runtime.h>

#define kiOS8Later SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@implementation UIView (HLUIAutoTest)
+ (void)load
{
    BOOL isAutoTestUI = YES;
    const char *className = object_getClassName(self);
    NSString *stringClassName =  [NSString stringWithCString:className encoding:NSUTF8StringEncoding];
    
    //[HLUIAutoTest sharedInstance].longPressEnabled = YES;
    
    if (isAutoTestUI && [stringClassName isEqualToString:@"UIView"])
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [self swizzleSelector:@selector(accessibilityIdentifier) withAnotherSelector:@selector(tb_accessibilityIdentifier)];
            [self swizzleSelector:@selector(accessibilityLabel) withAnotherSelector:@selector(tb_accessibilityLabel)];
            if ([HLUIAutoTest sharedInstance].isLongPressEnabled) {
                [self swizzleSelector:@selector(addSubview:) withAnotherSelector:@selector(tb_addSubview:)];
            }
        });
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (kiOS8Later) {
            CGFloat previousWidth = self.layer.borderWidth;
            CGColorRef previousColor =  self.layer.borderColor;
            self.layer.borderWidth = 3;
            self.layer.borderColor = [UIColor redColor].CGColor;
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"自动化测试Label" message:self.accessibilityIdentifier preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self.layer.borderWidth = previousWidth;
                self.layer.borderColor = previousColor;
            }];
            [alert addAction:confirmAction];
            [[self viewController] presentViewController:alert animated:YES completion:nil];
        }
    }
}

#pragma mark - Method Swizzling

- (NSString *)tb_accessibilityIdentifier
{
    NSString *accessibilityIdentifier = [self tb_accessibilityIdentifier];
    if (accessibilityIdentifier.length > 0 && [[accessibilityIdentifier substringToIndex:5] isEqualToString:@"iosHL"]) {
        return accessibilityIdentifier;
    }
    else if ([accessibilityIdentifier isEqualToString:@"null"]) {
        accessibilityIdentifier = @"";
    }
    
    NSString *labelStr = [self.superview findNameWithInstance:self];
    
    if (labelStr && ![labelStr isEqualToString:@""]) {
        labelStr = [NSString stringWithFormat:@"iosHL%@",labelStr];
    }
    else {
        if ([self isKindOfClass:[UILabel class]]) {//UILabel 使用 text
            labelStr = [NSString stringWithFormat:@"iosHL%@",((UILabel *)self).text?:@""];
        }
        else if ([self isKindOfClass:[UIImageView class]]) {//UIImageView 使用 image 的 imageName
            labelStr = [NSString stringWithFormat:@"iosHL%@",((UIImageView *)self).image.accessibilityIdentifier?:[NSString stringWithFormat:@"image%ld",(long)((UIImageView *)self).tag]];
        }
        else if ([self isKindOfClass:[UIButton class]]) {//UIButton 使用 button 的 text 和 image
            labelStr = [NSString stringWithFormat:@"iosHL%@%@",((UIButton *)self).titleLabel.text?:@"",((UIButton *)self).imageView.image.accessibilityIdentifier?:@""];
        }
        else if (accessibilityIdentifier) {// 已有 label，则在此基础上再次添加更多信息
            labelStr = [NSString stringWithFormat:@"iosHL%@",accessibilityIdentifier];
        }
        if ([self isKindOfClass:[UIButton class]]) {
            self.accessibilityValue = [NSString stringWithFormat:@"iosHL%@",((UIButton *)self).currentBackgroundImage.accessibilityIdentifier?:@""];
        }
    }
    if ([labelStr isEqualToString:@"()"] || [labelStr isEqualToString:@"(null)"] || [labelStr isEqualToString:@"null"]) {
        labelStr = @"";
    }
    [self setAccessibilityIdentifier:labelStr];
    return labelStr;
}

- (NSString *)tb_accessibilityLabel
{
    if ([self isKindOfClass:[UIImageView class]]) {//UIImageView 特殊处理
        NSString *name = [self.superview findNameWithInstance:self];
        if (name) {
            self.accessibilityIdentifier = [NSString stringWithFormat:@"iosHL%@",name];
        }
        else {
            self.accessibilityIdentifier = [NSString stringWithFormat:@"iosHL%@",((UIImageView *)self).image.accessibilityIdentifier?:[NSString stringWithFormat:@"image%ld",(long)((UIImageView *)self).tag]];
        }
    }
    if ([self isKindOfClass:[UITableViewCell class]]) {//UITableViewCell 特殊处理
        self.accessibilityIdentifier = [NSString stringWithFormat:@"iosHL%@",((UITableViewCell *)self).reuseIdentifier];
    }
    return [self tb_accessibilityLabel];
}

- (void)tb_addSubview:(UIView *)view {
    if (!view) {
        return;
    }
    [self tb_addSubview:view];
    UILongPressGestureRecognizer *longPress = objc_getAssociatedObject(view, _cmd);
    if (!longPress) {
        longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:view action:@selector(longPress:)];
        longPress.delegate = [HLUIAutoTest sharedInstance];
        [view addGestureRecognizer:longPress];
        objc_setAssociatedObject(view, _cmd, longPress, OBJC_ASSOCIATION_RETAIN);
    }
}

- (UIViewController*)viewController {
    for (UIView* next = self; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}
@end
