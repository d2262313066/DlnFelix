//
//  DlnFelix.m
//  DlnHotFixDemo
//
//  Created by DahaoJiang on 2019/5/7.
//  Copyright © 2019 Dln. All rights reserved.
//

#import "DlnFelix.h"
#import "Aspects.h"
#import "HotFixManager.h"
#import <objc/message.h>
#import "ParamsHandler.h"
@implementation DlnFelix
static JSContext *_context;

+ (DlnFelix *)sharedInstance {
    static DlnFelix *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

+ (JSContext *)context {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _context = [[JSContext alloc] init];
        [_context setExceptionHandler:^(JSContext *context, JSValue *value) {
            NSLog(@"Oops: %@", value);
        }];
    });
    return _context;
}

+ (void)evalString:(NSString *)javascriptString {
    [[self context] evaluateScript:javascriptString];
}


+ (void)_fixWithMethod:(BOOL)isClassMethod aspectionOptions:(AspectOptions)option instanceName:(NSString *)instanceName selectorName:(NSString *)selectorName fixImpl:(JSValue *)fixImpl {
    Class klass = NSClassFromString(instanceName);
    if (isClassMethod) {
        klass = object_getClass(klass);
    }
    SEL sel = NSSelectorFromString(selectorName);
    [klass aspect_hookSelector:sel withOptions:option usingBlock:^(id<AspectInfo> aspectInfo){
        /**
         instance               实例
         originalInvocation     NSInvocation
         arguments              参数个数，传多少个有多少个
         */
        [fixImpl callWithArguments:@[aspectInfo.instance, aspectInfo.originalInvocation, aspectInfo.arguments]];
    } error:nil];
}


// Class方法的话应该是没有keyPath的,修改起来比较简便
+ (void)_runClassWithClassName:(NSString *)className selector:(NSString *)selector parameter1:(NSString *)parameter1 parameter2:(NSString *)parameter2 {
    Class klass = NSClassFromString(className);
    id obj1;
    id obj2;
    if(parameter1) {
        obj1 = [self fixObject:[self transferDictionary:parameter1]];
    }
    if (parameter2) {
       obj2 = [self fixObject:[self transferDictionary:parameter2]];
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [klass performSelector:NSSelectorFromString(selector) withObject:obj1 withObject:obj2];
#pragma clang diagnostic pop
}


//这个方法只能调用当前对象已经写好的方法，比如ViewController里面，如果想操作view，就没办法做到
+ (void)_runInstanceWithInstance:(NSString *)instanceName selector:(NSString *)selector parameter1:(NSString *)parameter1 parameter2:(NSString *)parameter2 {
    [self _runInstanceWithInstance:instanceName keyPath:nil selector:selector parameter1:parameter1 parameter2:parameter2];
}

//添加了keyPath，可以操作对象内的对象啦
+ (void)_runInstanceWithInstance:(NSString *)instanceName keyPath:(NSString *)keyPath selector:(NSString *)selector parameter1:(NSString *)parameter1 parameter2:(NSString *)parameter2 {
    
    //搜索当前实例是否存在,如果存在的话继续
    id instance = [[HotFixManager shareManager] ViewController];
    
    if (!instance) {
        NSLog(@"对象未找到");
        return ;
    }
    if (keyPath) {
        instance = [instance valueForKeyPath:keyPath];
    }
    
    // 1.通过方法调用者创建方法签名；此方法是NSObject 的方法
    NSMethodSignature *sig = [[instance class] instanceMethodSignatureForSelector:NSSelectorFromString(selector)];
    // 2.通过方法签名 生成NSInvocation
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    invocation.target = instance;
    invocation.selector = NSSelectorFromString(selector);
    // 注意 参数必须从2开始 因为0跟1已经被self，_cmd占用了
    // 3.对parameter进行操作
    if(parameter1) {
        id obj1 = [self fixObject:[self transferDictionary:parameter1]];
        [invocation setArgument:&obj1 atIndex:2];
    }
    
    if (parameter2) {
        id obj2 = [self fixObject:[self transferDictionary:parameter2]];
        [invocation setArgument:&obj2 atIndex:3];
    }
    //执行invoke
    [invocation invoke];
}

+ (void)fixIt
{
    // 使用Block可以很方便的将OC中的单个方法(即Block)暴露给JS调用
    [self context][@"fixInstanceMethodBefore"] = ^(NSString *instanceName, NSString *selectorName, JSValue *fixImpl) {
        [self _fixWithMethod:NO aspectionOptions:AspectPositionBefore instanceName:instanceName selectorName:selectorName fixImpl:fixImpl];
    };
    
    [self context][@"fixInstanceMethodReplace"] = ^(NSString *instanceName, NSString *selectorName, JSValue *fixImpl) {
        [self _fixWithMethod:NO aspectionOptions:AspectPositionInstead instanceName:instanceName selectorName:selectorName fixImpl:fixImpl];
    };
    
    [self context][@"fixInstanceMethodAfter"] = ^(NSString *instanceName, NSString *selectorName, JSValue *fixImpl) {
        [self _fixWithMethod:NO aspectionOptions:AspectPositionAfter instanceName:instanceName selectorName:selectorName fixImpl:fixImpl];
    };
    
    [self context][@"fixClassMethodBefore"] = ^(NSString *instanceName, NSString *selectorName, JSValue *fixImpl) {
        [self _fixWithMethod:YES aspectionOptions:AspectPositionBefore instanceName:instanceName selectorName:selectorName fixImpl:fixImpl];
    };
    
    [self context][@"fixClassMethodReplace"] = ^(NSString *instanceName, NSString *selectorName, JSValue *fixImpl) {
        [self _fixWithMethod:YES aspectionOptions:AspectPositionInstead instanceName:instanceName selectorName:selectorName fixImpl:fixImpl];
    };
    
    [self context][@"fixClassMethodAfter"] = ^(NSString *instanceName, NSString *selectorName, JSValue *fixImpl) {
        [self _fixWithMethod:YES aspectionOptions:AspectPositionAfter instanceName:instanceName selectorName:selectorName fixImpl:fixImpl];
    };
    
    //JSContext调用iOS是根据字符串对象进行交互的，原版使用id显然不合适,这里选择使用自定义规则设置字符串替代id
    [self context][@"runVoidClassWithNoParamter"] = ^(NSString *className, NSString *selectorName) {
        [self _runClassWithClassName:className selector:selectorName parameter1:nil parameter2:nil];
    };
    
    [self context][@"runVoidClassWith1Paramter"] = ^(NSString *className, NSString *selectorName, NSString *parameter1) {
        [self _runClassWithClassName:className selector:selectorName parameter1:parameter1 parameter2:nil];
    };
    
    [self context][@"runVoidClassWith2Paramters"] = ^(NSString *className, NSString *selectorName, NSString *parameter1, NSString *parameter2) {
        [self _runClassWithClassName:className selector:selectorName parameter1:parameter1 parameter2:parameter2];
    };
    
    /** 原版的实例方法都是错误的
     思路,实例方法需要配合iOS工程使用，创建单例，用weak引用当前实例，利用返回的字符串进行KVC获取，再使用NSInvocation实现
     */
    [self context][@"runInstanceWithNoParamter"] = ^(NSString *instance, NSString *selectorName) {
       [self _runInstanceWithInstance:instance selector:selectorName parameter1:nil parameter2:nil];
    };
    //JSContext调用iOS是根据字符串对象进行交互的，原版使用id显然不合适,这里选择使用自定义规则设置字符串替代id
    [self context][@"runInstanceWith1Paramter"] = ^(NSString *instance, NSString *selectorName, NSString *parameter1) {
        [self _runInstanceWithInstance:instance selector:selectorName parameter1:parameter1 parameter2:nil];
    };
    
    [self context][@"runInstanceWith2Paramter"] = ^(NSString *instance, NSString *selectorName, NSString *parameter1, NSString *parameter2) {
        [self _runInstanceWithInstance:instance selector:selectorName parameter1:parameter1 parameter2:parameter2];
    };
    
    //跑对象内的对象方法(有点拗口) like ViewController.view.userInteractionEnabled 这样
    [self context][@"runInstanceObjectWithNoParameter"] = ^(NSString *instance, NSString *keyPath, NSString *selectorName) {
        [self _runInstanceWithInstance:instance keyPath:keyPath selector:selectorName parameter1:nil parameter2:nil];
    };
    //跑对象内的对象方法(有点拗口) like ViewController.view.userInteractionEnabled 这样
    [self context][@"runInstanceObjectWith1Parameters"] = ^(NSString *instance, NSString *keyPath, NSString *selectorName,NSString *parameter1) {
        [self _runInstanceWithInstance:instance keyPath:keyPath selector:selectorName parameter1:parameter1 parameter2:nil];
    };
    //跑对象内的对象方法(有点拗口) like ViewController.view.userInteractionEnabled 这样
    [self context][@"runInstanceObjectWith2Parameters"] = ^(NSString *instance, NSString *keyPath, NSString *selectorName,NSString *parameter1, NSString *parameter2) {
        [self _runInstanceWithInstance:instance keyPath:keyPath selector:selectorName parameter1:parameter1 parameter2:parameter2];
    };
    
    [self context][@"runInvocation"] = ^(NSInvocation *invocation) {
        [invocation invoke];
    };
    
    // helper
    [[self context] evaluateScript:@"var console = {}"];
    [self context][@"console"][@"log"] = ^(id message) {
        NSLog(@"Javascript log: %@",message);
    };
}

#pragma mark - helper
/**
 json字符串转换Dic
 */
+ (NSDictionary *)transferDictionary:(NSString *)parameters {
    /**
     传一个json字符串吧，然后在iOS这边进行转码，转码好了之后再拼凑起来
     {"Type":"instance",
     "Class":"NSString",
     "Selector":"initWithString:"
     parameters:["hello world"],
     returnValue:1
     }
     */
    //实例方法需要，Class Selector parameters
    //类方法需要 Class ClassMethod parameters
    
    NSData *data = [parameters dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    return dic;
}

/**
 根据JS的传参进行对象拼接
 */
+ (id)fixObject:(NSDictionary *)dic {
    
    ParamsHandler *handler = [[ParamsHandler alloc] initWithDictionary:dic];
    id obj1 = [handler fixIt];
    
    return obj1;
    
}

@end
