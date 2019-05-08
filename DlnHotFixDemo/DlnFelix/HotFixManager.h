//
//  HotFixManager.h
//  DlnHotFixDemo
//
//  Created by DahaoJiang on 2019/5/6.
//  Copyright © 2019 Dln. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface HotFixManager : NSObject

+ (instancetype)shareManager;

@property (nonatomic, strong) UIViewController *ViewController;

/**
 替换思路：利用method swizzling在viewDidLoad的时候添加一个动态属性，associatedKey为当前object的名称，将这些东西传到当前singleton，
 singleton方法内动态添加属性，奈何实力有限🤷‍♀️,失败了，setAssociated需要固定地址的一个key，无法动态赋值
 */
- (void)setAssociatedObjectWithObject:(NSObject *)obj DEPRECATED_MSG_ATTRIBUTE("方法太麻烦了，不打算用了");

- (id)getObjcWithAssociateKey:(NSString *)key DEPRECATED_MSG_ATTRIBUTE("方法太麻烦了，不打算用了");


@end

NS_ASSUME_NONNULL_END
