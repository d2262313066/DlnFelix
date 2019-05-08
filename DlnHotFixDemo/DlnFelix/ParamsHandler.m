//
//  ParamsHandler.m
//  DlnHotFixDemo
//
//  Created by DahaoJiang on 2019/5/7.
//  Copyright © 2019 Dln. All rights reserved.
//

#import "ParamsHandler.h"
#import <objc/message.h>
@implementation ParamsHandler

- (id)initWithDictionary:(NSDictionary *)dic {
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}


- (id)fixIt {
    NSObject *obj;
    if ([self.type isEqualToString:@"instance"]) { //实例方法,将JS传过来的json字符串转化为iOS对象
        Class class = NSClassFromString(self.cls);
        
        if (_parameters.count == 0) {
            obj = ((NSObject* (*) (id,SEL)) objc_msgSend) ([class alloc],sel_registerName(self.selector.UTF8String));
        } else if (_parameters.count == 1) {
            obj = ((NSObject* (*) (id,SEL,NSObject *)) objc_msgSend) ([class alloc],sel_registerName(self.selector.UTF8String),_parameters[0]);
        } else if (_parameters.count == 2) {
            obj = ((NSObject* (*) (id,SEL,NSObject *,NSObject *)) objc_msgSend) ([class alloc],sel_registerName(self.selector.UTF8String),_parameters[0],_parameters[1]);
        }
    } else if ([self.type isEqualToString:@"class"]) { //类方法
        Class class = NSClassFromString(self.cls);
        if (_parameters.count == 0) {
            obj = ((NSObject* (*) (id,SEL)) objc_msgSend) (class,sel_registerName(self.selector.UTF8String));
        } else if (_parameters.count == 1) {
            obj = ((NSObject* (*) (id,SEL,NSObject *)) objc_msgSend) (class,sel_registerName(self.selector.UTF8String),_parameters[0]);
        } if (_parameters.count == 2) {
            obj = ((NSObject* (*) (id,SEL,NSObject *,NSObject *)) objc_msgSend) (class ,sel_registerName(self.selector.UTF8String),_parameters[0],_parameters[1]);
        }
    }
    
    return obj;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"class"]) {
        _cls = value;
    }
}

-(id)valueForUndefinedKey:(NSString *)key {
    return nil;
}


@end
