//
//  UIImage+HLUIAutoTest.m
//  HLUIAutoTest
//
//  Created by 刘华龙 on 2018/8/28.
//  Copyright © 2018年 liuhualong. All rights reserved.
//

#import "UIImage+HLUIAutoTest.h"
#import "HLUIAutoTest.h"
#import <objc/runtime.h>

@implementation UIImage (HLUIAutoTest)
+ (void)load
{
    BOOL isAutoTestUI = YES;
    if (isAutoTestUI)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [object_getClass(self) swizzleSelector:@selector(imageNamed:) withAnotherSelector:@selector(tb_imageNamed:)];
            [object_getClass(self) swizzleSelector:@selector(imageWithContentsOfFile:) withAnotherSelector:@selector(tb_imageWithContentsOfFile:)];
            [self swizzleSelector:@selector(accessibilityIdentifier) withAnotherSelector:@selector(tb_accessibilityIdentifier)];
        });
    }
}

#pragma mark - Method Swizzling

+ (UIImage *)tb_imageNamed:(NSString *)imageName{
    UIImage *image = [UIImage tb_imageNamed:imageName];
    image.accessibilityIdentifier = imageName;
    return image;
}

+ (UIImage *)tb_imageWithContentsOfFile:(NSString *)path
{
    UIImage *image = [UIImage tb_imageWithContentsOfFile:path];
    NSArray *components = [path pathComponents];
    if (components.count > 0) {
        image.accessibilityIdentifier = components.lastObject;
    }
    else {
        image.accessibilityIdentifier = path;
    }
    return image;
}

- (id)assetName {return nil;}

- (NSString *)tb_accessibilityIdentifier {
    NSString *tb_accessibilityIdentifier = [self tb_accessibilityIdentifier];
    if (tb_accessibilityIdentifier.length == 0 && [self respondsToSelector:@selector(imageAsset)]) {
        tb_accessibilityIdentifier = [(id)self.imageAsset assetName];
        self.accessibilityIdentifier = tb_accessibilityIdentifier;
    }
    
    return tb_accessibilityIdentifier;
}

@end
