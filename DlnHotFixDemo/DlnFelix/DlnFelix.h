//
//  DlnFelix.h
//  DlnHotFixDemo
//
//  Created by DahaoJiang on 2019/5/7.
//  Copyright © 2019 Dln. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <JavaScriptCore/JavaScriptCore.h>
NS_ASSUME_NONNULL_BEGIN

@interface DlnFelix : NSObject

/**
 添加方法
 */
+ (void)fixIt;

+ (void)evalString:(NSString *)javascriptString;

@end

NS_ASSUME_NONNULL_END
