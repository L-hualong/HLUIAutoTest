//
//  UIResponder+HLUIAutoTest.m
//  HLUIAutoTest
//
//  Created by 刘华龙 on 2018/8/28.
//  Copyright © 2018年 liuhualong. All rights reserved.
//

#import "UIResponder+HLUIAutoTest.h"
#import <objc/runtime.h>
#import <HLUIAutoTest/HLUIAutoTest-Swift.h>

@implementation UIResponder (HLUIAutoTest)

-(NSString *)nameWithInstance:(id)instance {
    unsigned int numIvars = 0;
    NSString *key=nil;
    Ivar * ivars = class_copyIvarList([self class], &numIvars);
    for(int i = 0; i < numIvars; i++) {
        Ivar thisIvar = ivars[i];
        const char *type = ivar_getTypeEncoding(thisIvar);
        NSString *stringType =  [NSString stringWithCString:type encoding:NSUTF8StringEncoding];
        //NSLog(@"%@", stringType);
        if (![stringType hasPrefix:@"@"]) {
            continue;
        }
        if ((object_getIvar(self, thisIvar) == instance)) {//此处 crash 不要慌！
            key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
            break;
        }
    }
    free(ivars);
    return key;
}

-(NSString *)swiftNameWithInstance:(id)instance {
    
    NSString *key=nil;
    unsigned int outCount = 0;
    objc_property_t * properties = class_copyPropertyList([self class], &outCount);
    for (unsigned int i = 0; i < outCount; i ++) {
        objc_property_t property = properties[i];
        //属性名
        const char * name = property_getName(property);
        //属性描述
        const char * propertyAttr = property_getAttributes(property);
        NSLog(@"属性描述为 %s 的 %s ", propertyAttr, name);
        //属性的特性
        unsigned int attrCount = 0;
        objc_property_attribute_t * attrs = property_copyAttributeList(property, &attrCount);
        for (unsigned int j = 0; j < attrCount; j ++) {
            objc_property_attribute_t attr = attrs[j];
            const char * name = attr.name;
            const char * value = attr.value;
            NSLog(@"属性的描述：%s 值：%s", name, value);
        }
        free(attrs);
        NSLog(@"\n");
    }
    free(properties);
    return key;
}

- (NSString *)findNameWithInstance:(UIView *) instance
{
    NSString *name = nil;
    id nextResponder = [self nextResponder];
    const char *className = object_getClassName(self);
    NSString *stringClassName =  [NSString stringWithCString:className encoding:NSUTF8StringEncoding];
    //判断是否是swift类
    if ([stringClassName containsString:@"."]) {
        name = [HLSwiftMirrorTool swiftNameWithInstanceWithCla:self instance:instance];
    } else {
        name = [self nameWithInstance:instance];
    }
    if (!name) {
        return [nextResponder findNameWithInstance:instance];
    }
    if ([name hasPrefix:@"_"]) {  //去掉变量名的下划线前缀
        name = [name substringFromIndex:1];
    }
    return name;
}

@end
