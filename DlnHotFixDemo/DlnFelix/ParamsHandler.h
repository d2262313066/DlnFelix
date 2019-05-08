//
//  ParamsHandler.h
//  DlnHotFixDemo
//
//  Created by DahaoJiang on 2019/5/7.
//  Copyright © 2019 Dln. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ParamsHandler : NSObject

/** 字典处理 */
- initWithDictionary:(NSDictionary *)dic;

/** 处理JS返回回来的Json字符串，返回基本对象 */
- (id)fixIt;

@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *cls;
@property (nonatomic, strong) NSString *selector;
@property (nonatomic, strong) NSArray *parameters;
@property (nonatomic, strong) NSString *keyPath;

@end

NS_ASSUME_NONNULL_END
