//
//  HotFixManager.m
//  DlnHotFixDemo
//
//  Created by DahaoJiang on 2019/5/6.
//  Copyright © 2019 Dln. All rights reserved.
//

#import "HotFixManager.h"
#import <objc/runtime.h>
#import "AssociationKey.h"

@implementation HotFixManager

static HotFixManager *mgr;

+(instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mgr = [[HotFixManager alloc] init];
    });
    return mgr;
}

- (void)setAssociatedObjectWithObject:(NSObject *)obj {
    
    objc_setAssociatedObject(self, VCAssociationKey, obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)getObjcWithAssociateKey:(NSString *)key {
    const char * str = key.UTF8String;
    return objc_getAssociatedObject(self, VCAssociationKey);
}




@end
